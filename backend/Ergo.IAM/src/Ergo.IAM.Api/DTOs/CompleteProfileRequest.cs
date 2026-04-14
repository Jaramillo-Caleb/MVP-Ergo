using System;

namespace Ergo.IAM.Api.DTOs
{
    public class CompleteProfileRequest
    {
        public string FullName { get; set; } = string.Empty;
        public DateTime BirthDate { get; set; }
        
        public string? Gender { get; set; }
        public string? Location { get; set; }
        public string? Occupation { get; set; }
    }
}