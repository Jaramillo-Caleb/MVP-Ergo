using Ergo.IAM.Core.Interfaces;
using Ergo.IAM.Core.Common;
using Microsoft.Extensions.Options;
using MimeKit;
using MailKit.Net.Smtp;
using MailKit.Security;

namespace Ergo.IAM.Infrastructure.Services;

public class MailKitEmailService : IEmailService
{
    private readonly EmailSettings _settings;

    public MailKitEmailService(IOptions<EmailSettings> settings)
    {
        _settings = settings.Value;
    }

    public async Task SendPasswordResetCodeAsync(string email, string code)
    {
        var message = new MimeMessage();
        message.From.Add(new MailboxAddress(_settings.FromName, _settings.FromEmail));
        message.To.Add(new MailboxAddress("", email));
        message.Subject = "Código de recuperación - Ergo Desktop";

        var bodyBuilder = new BodyBuilder
        {
            HtmlBody = $@"
                <div style='font-family: sans-serif; max-width: 600px; margin: auto; border: 1px solid #eee; padding: 20px;'>
                    <h2 style='color: #333;'>Recuperación de contraseña</h2>
                    <p>Has solicitado restablecer tu contraseña en <strong>Ergo Desktop</strong>.</p>
                    <div style='background: #f4f4f4; padding: 20px; text-align: center; font-size: 24px; letter-spacing: 5px; font-weight: bold; color: #4A90E2;'>
                        {code}
                    </div>
                    <p style='color: #666; font-size: 12px; margin-top: 20px;'>
                        Este código expirará en 15 minutos. Si no solicitaste esto, ignora este correo.
                    </p>
                </div>"
        };

        message.Body = bodyBuilder.ToMessageBody();

        using var client = new SmtpClient();
        try 
        {
            await client.ConnectAsync(_settings.Host, _settings.Port, SecureSocketOptions.StartTls);
            await client.AuthenticateAsync(_settings.UserName, _settings.Password);
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }
        catch (Exception ex)
        {
            throw new Exception("Error al enviar el correo electrónico", ex);
        }
    }
}