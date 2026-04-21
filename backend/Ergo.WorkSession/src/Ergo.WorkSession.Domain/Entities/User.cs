using System;
using System.Collections.Generic;

namespace Ergo.WorkSession.Domain.Entities
{
    public class User
    {
        public Guid Id { get; set; }
        public string Email { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public DateTime BirthDate { get; set; }
        public string? Gender { get; set; }
        public string? Location { get; set; }
        public string? Occupation { get; set; }
        public string? AvatarPath { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<WorkSession> WorkSessions { get; set; } = new List<WorkSession>();
    }
}
