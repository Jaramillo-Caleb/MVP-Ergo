using System;

namespace Ergo.IAM.Core.Entities
{
    public class UserProfile
    {
        public Guid Id { get; set; }

        public Guid UserId { get; set; }

        public User? User { get; set; }

        public string FullName { get; set; } = string.Empty;
        public DateTime BirthDate { get; set; }
        public string? Gender { get; set; }      
        public string? Location { get; set; }    
        public string? Occupation { get; set; }  
        public string? AvatarPath { get; set; }
        public int Age => DateTime.Today.Year - BirthDate.Year;
    }
}