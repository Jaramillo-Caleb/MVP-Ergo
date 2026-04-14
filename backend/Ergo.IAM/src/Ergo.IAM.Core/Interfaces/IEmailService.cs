namespace Ergo.IAM.Core.Interfaces;

public interface IEmailService
{
    Task SendPasswordResetCodeAsync(string email, string code);
}