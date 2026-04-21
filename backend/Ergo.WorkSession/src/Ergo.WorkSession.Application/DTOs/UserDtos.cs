using System;

namespace Ergo.WorkSession.Application.DTOs
{
    public record UserDto(
        Guid Id,
        string Email,
        string FullName,
        DateTime BirthDate,
        string? Gender,
        string? Location,
        string? Occupation,
        string? AvatarPath,
        DateTime CreatedAt);

    public record UserProfileRequest(
        string Email,
        string FullName,
        DateTime BirthDate,
        string? Gender,
        string? Location,
        string? Occupation);
}
