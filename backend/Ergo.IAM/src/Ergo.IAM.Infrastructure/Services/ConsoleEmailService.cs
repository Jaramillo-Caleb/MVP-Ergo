using Ergo.IAM.Core.Interfaces;
using Microsoft.Extensions.Logging;

namespace Ergo.IAM.Infrastructure.Services;

public class ConsoleEmailService : IEmailService
{
    private readonly ILogger<ConsoleEmailService> _logger;

    public ConsoleEmailService(ILogger<ConsoleEmailService> logger)
    {
        _logger = logger;
    }

    public Task SendPasswordResetCodeAsync(string email, string code)
    {
        _logger.LogInformation("--- EMAIL SENT ---");
        _logger.LogInformation("To: {Email}", email);
        _logger.LogInformation("Subject: Recuperación de contraseña");
        _logger.LogInformation("Body: Tu código de seguridad es {Code}", code);
        _logger.LogInformation("------------------");
        
        return Task.CompletedTask;
    }
}