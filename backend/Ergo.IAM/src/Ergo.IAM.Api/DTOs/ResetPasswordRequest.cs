namespace Ergo.IAM.Api.DTOs;

public record ResetPasswordRequest(string Email, string Code, string NewPassword);