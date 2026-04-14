public interface ISocialAuthService
{
    Task<(string Email, string ExternalId, string FullName)> VerifyGoogleToken(string idToken);
    Task<(string Email, string ExternalId, string FullName)> VerifyGitHubCode(string code);
}