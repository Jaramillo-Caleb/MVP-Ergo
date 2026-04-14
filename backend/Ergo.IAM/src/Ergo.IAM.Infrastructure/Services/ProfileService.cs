using Ergo.IAM.Core.Interfaces; 
using Ergo.IAM.Core.Common;
using Ergo.IAM.Core.Entities;  
using System.IO;

namespace Ergo.IAM.Infrastructure.Services;

public class ProfileService : IProfileService
{
    private readonly IUserRepository _userRepository;
    private readonly LocalFileStorageService _fileStorage;

    public ProfileService(IUserRepository userRepository, LocalFileStorageService fileStorage)
    {
        _userRepository = userRepository;
        _fileStorage = fileStorage;
    }

    public async Task<(bool Success, string Message, string? Path)> UpdateProfileAsync(
        Guid userId, string fullName, DateTime birthDate, string gender, string location, 
        string occupation, Stream? imageStream, string? fileName)
    {
        var user = await _userRepository.GetByIdAsync(userId);
        if (user == null) return (false, "Usuario no encontrado", null);

        string? avatarPath = null;
        if (imageStream != null && !string.IsNullOrEmpty(fileName))
        {
            var ext = Path.GetExtension(fileName).ToLower();
            if (!SecurityConstants.AllowedExtensions.Contains(ext))
                return (false, "Extensión de imagen no permitida", null);

            avatarPath = await _fileStorage.SaveFileAsync(imageStream, fileName);
        }

        if (user.Profile == null) 
        {
            user.Profile = new UserProfile 
            {
                UserId = userId,
                FullName = fullName,
                BirthDate = birthDate,
                Gender = gender,
                Location = location,
                Occupation = occupation,
                AvatarPath = avatarPath
            };
        }
        else
        {
            user.Profile ??= new UserProfile { UserId = userId };
            user.Profile.FullName = fullName;
            user.Profile.BirthDate = birthDate;
            user.Profile.Gender = gender;
            user.Profile.Location = location;
            user.Profile.Occupation = occupation;
            if (avatarPath != null) user.Profile.AvatarPath = avatarPath;
        }

        await _userRepository.SaveChangesAsync();

        return (true, "Perfil actualizado", avatarPath);
    }
} 