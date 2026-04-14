namespace Ergo.WorkSession.Domain.Entities
{
    public class PostureEvent
    {
        public int Id { get; private set; }

        public Guid WorkSessionId { get; private set; }
        public DateTime Timestamp { get; private set; }
        public double Score { get; private set; }

        public bool IsAlert { get; private set; }

        public string? Message { get; private set; }

        protected PostureEvent() { }

        public PostureEvent(Guid workSessionId, double score, bool isAlert, string? message)
        {
            WorkSessionId = workSessionId;
            Score = score;
            IsAlert = isAlert;
            Message = message;
            Timestamp = DateTime.UtcNow;
        }
    }
}