namespace Ergo.WorkSession.Domain.Entities
{
    public class ReferencePose
    {
        public Guid Id { get; private set; }
        public Guid UserId { get; private set; }

        public string? Alias { get; private set; }

        public double[] Vector { get; private set; } = Array.Empty<double>();

        public bool IsPersistent { get; private set; }

        public DateTime CreatedAt { get; private set; }

        protected ReferencePose() { }

        public ReferencePose(Guid userId, double[] vector, string? alias, bool isPersistent)
        {
            Id = Guid.NewGuid();
            UserId = userId;
            Vector = vector ?? throw new ArgumentNullException(nameof(vector));
            Alias = alias;
            IsPersistent = isPersistent;
            CreatedAt = DateTime.UtcNow;
        }

        public void UpdateVector(double[] newVector)
        {
            Vector = newVector ?? throw new ArgumentNullException(nameof(newVector));
            CreatedAt = DateTime.UtcNow; 
        }
    }
}