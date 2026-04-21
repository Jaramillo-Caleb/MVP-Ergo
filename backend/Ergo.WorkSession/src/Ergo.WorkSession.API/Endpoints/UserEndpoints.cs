using Ergo.WorkSession.Domain.Entities;
using Ergo.WorkSession.Infrastructure.Persistence;
using Ergo.WorkSession.Application.DTOs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Ergo.WorkSession.API.Endpoints
{
    public static class UserEndpoints
    {
        public static void MapUserEndpoints(this IEndpointRouteBuilder app)
        {
            var group = app.MapGroup("/api/users").WithTags("Users");

            group.MapGet("/me", async (SessionDbContext db) =>
            {
                var user = await db.Users.AsNoTracking().FirstOrDefaultAsync();
                
                if (user == null) return Results.NotFound();

                var dto = new UserDto(
                    user.Id,
                    user.Email,
                    user.FullName,
                    user.BirthDate,
                    user.Gender,
                    user.Location,
                    user.Occupation,
                    user.AvatarPath,
                    user.CreatedAt);

                return Results.Ok(dto);
            });

            group.MapPost("/profile", async ([FromBody] UserProfileRequest request, SessionDbContext db) =>
            {
                var user = await db.Users.FirstOrDefaultAsync();

                if (user == null)
                {
                    user = new User
                    {
                        Id = Guid.NewGuid(),
                        CreatedAt = DateTime.UtcNow
                    };
                    db.Users.Add(user);
                }

                user.Email = request.Email;
                user.FullName = request.FullName;
                user.BirthDate = request.BirthDate;
                user.Gender = request.Gender;
                user.Location = request.Location;
                user.Occupation = request.Occupation;

                await db.SaveChangesAsync();

                var dto = new UserDto(
                    user.Id,
                    user.Email,
                    user.FullName,
                    user.BirthDate,
                    user.Gender,
                    user.Location,
                    user.Occupation,
                    user.AvatarPath,
                    user.CreatedAt);

                return Results.Ok(dto);
            });
        }
    }
}
