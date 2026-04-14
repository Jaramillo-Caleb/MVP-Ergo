using System.ComponentModel.DataAnnotations;

namespace Ergo.WorkSession.Domain.Entities
{
    public class PomodoroSettings
    {
        [Key]
        public Guid UserId { get; set; }
        public int WorkDuration { get; set; } = 25;
        public int BreakDuration { get; set; } = 5;
        public bool AutoStart { get; set; } = false;
        public int Repetitions { get; set; } = 1;
        public DateTime LastUpdated { get; set; } = DateTime.UtcNow;

        public void Update(int work, int breakDuration, bool auto, int reps)
        {
            WorkDuration = work;
            BreakDuration = breakDuration;
            AutoStart = auto;
            Repetitions = reps;
            LastUpdated = DateTime.UtcNow;
        }
    }
}
