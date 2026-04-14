using Ergo.WorkSession.Application.DTOs;
using Ergo.WorkSession.Application.Interfaces;
using Ergo.WorkSession.Domain.Entities;
using Ergo.WorkSession.Domain.Enums;
using Ergo.WorkSession.Domain.Interfaces;
using Microsoft.Extensions.Caching.Memory;

namespace Ergo.WorkSession.Application.Services
{
    public class SessionOrchestrator : ISessionOrchestrator
    {
        private readonly ISessionRepository _sessionRepository;
        private readonly IReferencePoseRepository _referencePoseRepository;
        private readonly IPomodoroRepository _pomodoroRepository; 
        private readonly IAIEngineClient _aiEngineClient;
        private readonly IMemoryCache _cache;

        private readonly MemoryCacheEntryOptions _cacheOptions = new MemoryCacheEntryOptions()
            .SetSlidingExpiration(TimeSpan.FromHours(4));

        public SessionOrchestrator(
            ISessionRepository sessionRepository,
            IReferencePoseRepository referencePoseRepository,
            IPomodoroRepository pomodoroRepository, 
            IAIEngineClient aiEngineClient,
            IMemoryCache cache)
        {
            _sessionRepository = sessionRepository;
            _referencePoseRepository = referencePoseRepository;
            _pomodoroRepository = pomodoroRepository;
            _aiEngineClient = aiEngineClient;
            _cache = cache;
        }

        #region Gestión de Posturas

        public async Task<IEnumerable<ReferencePoseDto>> GetSavedPosturesAsync(Guid userId)
        {
            var poses = await _referencePoseRepository.GetPersistentByUserIdAsync(userId);
            return poses.Select(p => new ReferencePoseDto(p.Id, p.Alias ?? "Sin Nombre", p.IsPersistent, p.CreatedAt));
        }

        public async Task<ReferencePoseDto> CreatePostureProfileAsync(CreatePostureRequest request)
        {
            var newPose = new ReferencePose(request.UserId, request.Vector, request.Alias, request.IsPersistent);
            await _referencePoseRepository.AddAsync(newPose);
            return new ReferencePoseDto(newPose.Id, newPose.Alias!, newPose.IsPersistent, newPose.CreatedAt);
        }

        public async Task DeletePostureAsync(Guid postureId, Guid userId)
        {
            var pose = await _referencePoseRepository.GetByIdAsync(postureId);
            if (pose != null && pose.UserId == userId)
            {
                await _referencePoseRepository.DeleteAsync(postureId);
            }
        }

        #endregion

        #region Calibración e IA

        public async Task<CalibrationResultDto> ComputeCalibrationAsync(List<byte[]> images)
        {
            var aiResult = await _aiEngineClient.CalibrateAsync(images);
            return new CalibrationResultDto(aiResult.Vector, aiResult.Message);
        }

        #endregion

        #region Ciclo de Vida de Sesión (Core - Optimizado)

        public async Task<WorkSessionDto> StartSessionAsync(StartSessionRequest request)
        {
            var activeSession = await _sessionRepository.GetActiveSessionByUserIdAsync(request.UserId);
            if (activeSession != null)
            {
                _cache.Remove($"Session_Vector_{activeSession.Id}");
                activeSession.EndSession();
                await _sessionRepository.UpdateAsync(activeSession);
            }

            Guid? finalPostureId = null;
            double[]? vectorToCache = null;

            if (request.Mode == SessionMode.Monitoring || request.Mode == SessionMode.Hybrid)
            {
                if (request.PostureId.HasValue)
                {
                    var existing = await _referencePoseRepository.GetByIdAsync(request.PostureId.Value);
                    if (existing == null) throw new KeyNotFoundException("La postura solicitada no existe.");

                    finalPostureId = existing.Id;
                    vectorToCache = existing.Vector;
                }
                else if (request.TemporaryVector != null)
                {
                    var tempPose = new ReferencePose(
                        request.UserId,
                        request.TemporaryVector,
                        $"Temp Session {DateTime.Now:HH:mm}",
                        isPersistent: false
                    );
                    await _referencePoseRepository.AddAsync(tempPose);

                    finalPostureId = tempPose.Id;
                    vectorToCache = tempPose.Vector;
                }
                else
                {
                    throw new InvalidOperationException("Modo Monitoreo requiere Postura o Vector.");
                }
            }

            var newSession = new Domain.Entities.WorkSession(request.UserId, request.Mode, finalPostureId);
            await _sessionRepository.AddAsync(newSession);

            if (vectorToCache != null)
            {
                _cache.Set($"Session_Vector_{newSession.Id}", vectorToCache, _cacheOptions);
            }

            return new WorkSessionDto(newSession.Id, "Running", newSession.Mode, newSession.StartTime);
        }

        public async Task<MonitorResultDto> ProcessFrameAsync(Guid sessionId, byte[] image)
        {
            var session = await _sessionRepository.GetByIdAsync(sessionId);
            if (session == null || !session.IsActive)
                throw new KeyNotFoundException("Sesión no encontrada o finalizada.");

            if (session.Mode == SessionMode.PomodoroOnly)
                return new MonitorResultDto(0, false, "Modo Pomodoro activo. Imagen ignorada.");

            if (!_cache.TryGetValue($"Session_Vector_{sessionId}", out double[]? referenceVector))
            {
                if (session.ReferencePoseId == null)
                    throw new InvalidOperationException("Estado corrupto: Sesión monitoreo sin referencia.");

                var pose = await _referencePoseRepository.GetByIdAsync(session.ReferencePoseId.Value);
                referenceVector = pose!.Vector;

                _cache.Set($"Session_Vector_{sessionId}", referenceVector, _cacheOptions);
            }

            var aiResult = await _aiEngineClient.CompareAsync(image, referenceVector!);

            session.AddEvent(aiResult.Score, !aiResult.IsCorrect, aiResult.Message);
            await _sessionRepository.UpdateAsync(session);

            return new MonitorResultDto(aiResult.Score, !aiResult.IsCorrect, aiResult.Message);
        }

        public async Task PauseSessionAsync(Guid sessionId) => await Task.CompletedTask;

        public async Task ResumeSessionAsync(Guid sessionId) => await Task.CompletedTask;

        public async Task<object> StopSessionAsync(Guid sessionId)
        {
            var session = await _sessionRepository.GetByIdAsync(sessionId);
            if (session != null && session.IsActive)
            {
                session.EndSession();
                await _sessionRepository.UpdateAsync(session);

                _cache.Remove($"Session_Vector_{sessionId}");
            }

            return new { message = "Sesión finalizada", finalScore = session?.ScoreAverage };
        }

        public async Task<PomodoroSettingsResponse?> GetPomodoroSettingsAsync(Guid userId)
        {
            var settings = await _pomodoroRepository.GetByUserIdAsync(userId);
            if (settings == null) return null;

            return new PomodoroSettingsResponse(
                settings.UserId,
                settings.WorkDuration,
                settings.BreakDuration,
                settings.AutoStart,
                settings.Repetitions
            );
        }

        public async Task UpdatePomodoroSettingsAsync(PomodoroSettingsRequest request)
        {
            var settings = await _pomodoroRepository.GetByUserIdAsync(request.UserId);
            
            if (settings == null)
            {
                settings = new PomodoroSettings
                {
                    UserId = request.UserId,
                    WorkDuration = request.WorkDuration,
                    BreakDuration = request.BreakDuration,
                    AutoStart = request.AutoStart,
                    Repetitions = request.Repetitions
                };
                await _pomodoroRepository.AddAsync(settings);
            }
            else
            {
                settings.WorkDuration = request.WorkDuration;
                settings.BreakDuration = request.BreakDuration;
                settings.AutoStart = request.AutoStart;
                settings.Repetitions = request.Repetitions;
                settings.LastUpdated = DateTime.UtcNow;
                
                await _pomodoroRepository.UpdateAsync(settings);
            }
        }

        public object? GetSessionStatus(Guid sessionId) => null;

        #endregion
    }
}