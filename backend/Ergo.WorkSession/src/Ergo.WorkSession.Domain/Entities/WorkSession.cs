using Ergo.WorkSession.Domain.Enums;

namespace Ergo.WorkSession.Domain.Entities
{
    public class WorkSession
    {
        public Guid Id { get; private set; }
        public Guid UserId { get; private set; }
        public User? User { get; private set; }

        public SessionMode Mode { get; private set; }

        public Guid? ReferencePoseId { get; private set; }

        public DateTime StartTime { get; private set; }
        public DateTime? EndTime { get; private set; }

        public bool IsActive => EndTime == null;

        public double? ScoreAverage { get; private set; }

        private readonly List<PostureEvent> _events = new();
        public IReadOnlyCollection<PostureEvent> Events => _events.AsReadOnly();

        protected WorkSession() { }

        public WorkSession(Guid userId, SessionMode mode, Guid? referencePoseId)
        {
            Id = Guid.NewGuid();
            UserId = userId;
            Mode = mode;
            ReferencePoseId = referencePoseId;
            StartTime = DateTime.UtcNow;

            if (mode != SessionMode.PomodoroOnly && referencePoseId == null)
            {
                throw new InvalidOperationException("Para modos de monitoreo se requiere una Postura de Referencia.");
            }
        }

        public void AddEvent(double score, bool isAlert, string? message)
        {
            if (!IsActive) throw new InvalidOperationException("No se pueden agregar eventos a una sesión cerrada.");

            if (Mode == SessionMode.PomodoroOnly) throw new InvalidOperationException("El modo Pomodoro no admite eventos de postura.");

            var ev = new PostureEvent(this.Id, score, isAlert, message);
            _events.Add(ev);
        }

        public void EndSession()
        {
            if (!IsActive) return;

            EndTime = DateTime.UtcNow;

            ScoreAverage = _events.Any() ? _events.Average(e => e.Score) : null;
        }
    }
}