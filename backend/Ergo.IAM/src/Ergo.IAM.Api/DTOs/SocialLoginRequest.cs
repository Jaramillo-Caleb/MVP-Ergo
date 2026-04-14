namespace Ergo.IAM.Api.DTOs
{
    public class SocialLoginRequest
    {
        public string Provider { get; set; } = string.Empty; 
        public string Token { get; set; } = string.Empty;    
    }
}