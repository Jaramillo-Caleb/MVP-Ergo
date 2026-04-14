using Ergo.IAM.Api.DTOs;
using Ergo.IAM.Core.Entities;
using Ergo.IAM.Core.Interfaces;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Ergo.IAM.Infrastructure.Services;

namespace Ergo.IAM.Api.Endpoints
{
    public static class AuthEndpoints
    {
        public static void MapAuthEndpoints(this IEndpointRouteBuilder app)
        {
            var group = app.MapGroup("/api/auth").WithTags("Auth");

            group.MapPost("/register", async (
                RegisterRequest request,
                IUserRepository userRepository,
                ITokenService tokenService) =>
            {
                if (await userRepository.ExistsAsync(request.Email))
                {
                    return Results.BadRequest("El correo electrónico ya está registrado.");
                }

                var user = new User
                {
                    Email = request.Email,
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                    Provider = "Local"
                };

                await userRepository.AddAsync(user);
                await userRepository.SaveChangesAsync();

                var response = new AuthResponse
                {
                    Token = tokenService.CreateToken(user),
                    Email = user.Email,
                    UserId = user.Id.ToString(),
                    FullName = ""
                };

                return Results.Ok(response);
            });

            group.MapPost("/login", async (
                LoginRequest request,
                IUserRepository userRepository,
                ITokenService tokenService) =>
            {
                var user = await userRepository.GetByEmailAsync(request.Email);

                if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
                {
                    return Results.Unauthorized();
                }

                var response = new AuthResponse
                {
                    Token = tokenService.CreateToken(user),
                    Email = user.Email,
                    UserId = user.Id.ToString(),
                    FullName = user.Profile?.FullName ?? "Usuario"
                };

                return Results.Ok(response);
            });

            group.MapPost("/social-login", async (
                SocialLoginRequest request,
                IUserRepository userRepository,
                ITokenService tokenService,
                ISocialAuthService socialAuthService) =>
            {
                try
                {
                    string email, externalId, fullName;

                    if (request.Provider.ToLower() == "google")
                        (email, externalId, fullName) = await socialAuthService.VerifyGoogleToken(request.Token);
                    else if (request.Provider.ToLower() == "github")
                        (email, externalId, fullName) = await socialAuthService.VerifyGitHubCode(request.Token);
                    else
                        return Results.BadRequest("Proveedor no soportado");

                    var user = await userRepository.GetByEmailAsync(email);

                    if (user == null)
                    {
                        user = new User
                        {
                            Email = email,
                            ExternalId = externalId,
                            Provider = request.Provider,
                            Profile = new UserProfile { FullName = fullName, BirthDate = DateTime.MinValue }
                        };
                        await userRepository.AddAsync(user);
                        await userRepository.SaveChangesAsync();
                    }

                    var response = new AuthResponse
                    {
                        Token = tokenService.CreateToken(user),
                        Email = user.Email,
                        UserId = user.Id.ToString(),
                        FullName = user.Profile?.FullName ?? "Usuario"
                    };

                    return Results.Ok(response);
                }
                catch (Exception)
                {
                    return Results.Unauthorized();
                }
            });

            group.MapPut("/profile", async (
                HttpRequest request,
                ClaimsPrincipal userClaims,
                IProfileService profileService) => 
            {
                var userIdStr = userClaims.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    
                if (string.IsNullOrEmpty(userIdStr) || !Guid.TryParse(userIdStr, out Guid userId)) 
                    return Results.Unauthorized();

                var form = await request.ReadFormAsync();
                var profileImage = form.Files.GetFile("profileImage");

                Stream? stream = profileImage?.OpenReadStream();
                
                _ = DateTime.TryParse(form["BirthDate"], out var birthDate);

                var result = await profileService.UpdateProfileAsync(
                    userId,
                    form["FullName"]!,
                    birthDate,
                    form["Gender"]!,
                    form["Location"]!,
                    form["Occupation"]!,
                    stream,
                    profileImage?.FileName
                );

                if (stream != null) await stream.DisposeAsync();

                return result.Success 
                    ? Results.Ok(new { result.Message, result.Path }) 
                    : Results.BadRequest(new { error = result.Message });
            })
            .RequireAuthorization()
            .DisableAntiforgery();

            group.MapPost("/forgot-password", async (
                ForgotPasswordRequest request,
                IPasswordResetService resetService) =>
            {
                if (string.IsNullOrWhiteSpace(request.Email))
                    return Results.BadRequest("El correo electrónico es requerido.");

                await resetService.RequestResetAsync(request.Email);

                return Results.Ok(new { message = "Si el correo está registrado, recibirás un código en breve." });
            });

            group.MapPost("/reset-password", async (
                ResetPasswordRequest request,
                IPasswordResetService resetService) =>
            {
                if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Code) || string.IsNullOrWhiteSpace(request.NewPassword))
                {
                    return Results.BadRequest("Todos los campos son obligatorios.");
                }

                var success = await resetService.ResetPasswordAsync(
                    request.Email,
                    request.Code,
                    request.NewPassword);
                
                if (!success)
                {
                    return Results.BadRequest(new { error = "El código es inválido o ha expirado." });
                }

                return Results.Ok(new { message = "Contraseña actualizada exitosamente." });
            });

            group.MapGet("/profile", async (
                ClaimsPrincipal userClaims,
                IUserRepository userRepository) =>
            {
                var userIdStr = userClaims.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (string.IsNullOrEmpty(userIdStr) || !Guid.TryParse(userIdStr, out Guid userId))
                    return Results.Unauthorized();

                var user = await userRepository.GetByIdAsync(userId);
                if (user == null || user.Profile == null)
                    return Results.NotFound("Perfil no encontrado.");

                return Results.Ok(new
                {
                    user.Profile.FullName,
                    user.Profile.BirthDate,
                    user.Profile.Gender,
                    user.Profile.Location,
                    user.Profile.Occupation,
                    user.Profile.AvatarPath
                });
            })
            .RequireAuthorization();
        } 
    } 
}