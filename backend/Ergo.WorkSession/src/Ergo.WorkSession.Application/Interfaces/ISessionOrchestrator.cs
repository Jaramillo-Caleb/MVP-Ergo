using Ergo.WorkSession.Application.DTOs;

namespace Ergo.WorkSession.Application.Interfaces
{
    public interface ISessionOrchestrator
    {
        Task<IEnumerable<ReferencePoseDto>> GetSavedPosturesAsync(Guid userId);
        Task<ReferencePoseDto> CreatePostureProfileAsync(CreatePostureRequest request);
        Task DeletePostureAsync(Guid postureId, Guid userId);

        Task<CalibrationResultDto> ComputeCalibrationAsync(List<byte[]> images);

        Task<WorkSessionDto> StartSessionAsync(StartSessionRequest request);

        Task<MonitorResultDto> ProcessFrameAsync(Guid sessionId, byte[] image);
        Task PauseSessionAsync(Guid sessionId);
        Task ResumeSessionAsync(Guid sessionId);
        Task<object> StopSessionAsync(Guid sessionId); 

        Task<PomodoroSettingsResponse?> GetPomodoroSettingsAsync(Guid userId);
        Task UpdatePomodoroSettingsAsync(PomodoroSettingsRequest request);

        object? GetSessionStatus(Guid sessionId);
    }
}