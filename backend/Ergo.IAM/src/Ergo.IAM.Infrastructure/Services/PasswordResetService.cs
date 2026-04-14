using Ergo.IAM.Core.Interfaces;
using Ergo.IAM.Core.Entities;
using BCrypt.Net;

namespace Ergo.IAM.Infrastructure.Services;

public class PasswordResetService : IPasswordResetService
{
    private readonly IUserRepository _userRepository;
    private readonly IEmailService _emailService;

    public PasswordResetService(IUserRepository userRepository, IEmailService emailService)
    {
        _userRepository = userRepository;
        _emailService = emailService;
    }

    public async Task<bool> RequestResetAsync(string email)
    {
        var user = await _userRepository.GetByEmailAsync(email);
        
        if (user == null) 
        {
            return true; 
        }

        var code = new Random().Next(100000, 999999).ToString();
        
        user.ResetCode = code;
        user.ResetCodeExpiry = DateTime.UtcNow.AddMinutes(15);

        await _userRepository.SaveChangesAsync();

        await _emailService.SendPasswordResetCodeAsync(email, code);
        
        return true;
    }

    public async Task<bool> ResetPasswordAsync(string email, string code, string newPassword)
    {
        var user = await _userRepository.GetByEmailAsync(email);

        if (user == null) return false;

        if (user.ResetCode != code) return false;
        if (user.ResetCodeExpiry < DateTime.UtcNow) return false;

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(newPassword);
        
        user.ResetCode = null;
        user.ResetCodeExpiry = null;

        await _userRepository.SaveChangesAsync();
        return true;
    }
}