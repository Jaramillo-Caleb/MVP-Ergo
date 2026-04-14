namespace Ergo.IAM.Core.Entities
{
    public class User
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public string Email { get; set; } = string.Empty;
        public string? PasswordHash { get; set; } 
        public string? ExternalId { get; set; }   
        public string Provider { get; set; } = "Local"; 
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public string? ResetCode { get; set; }
        public DateTime? ResetCodeExpiry { get; set; }
        public UserProfile? Profile { get; set; }
        public ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
    }
}
