using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Ergo.IAM.Core.Interfaces;
using Ergo.IAM.Infrastructure.Persistence.Contexts;
using Ergo.IAM.Infrastructure.Persistence.Repositories;
using Ergo.IAM.Infrastructure.Services; 
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

namespace Ergo.IAM.Infrastructure
{
    public static class DependencyInjection
    {
        public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
        {
            var connectionString = configuration.GetConnectionString("IdentityConnection");
            services.AddDbContext<IdentityDbContext>(options =>
                options.UseSqlite(connectionString));

            services.AddHttpClient();
            services.AddScoped<ISocialAuthService, SocialAuthService>();
            services.AddScoped<IUserRepository, UserRepository>();
            services.AddScoped<ITokenService, TokenService>();
            services.AddScoped<IPasswordResetService, PasswordResetService>();
            services.AddScoped<IEmailService, ConsoleEmailService>();
            services.AddScoped<IEmailService, MailKitEmailService>();

            var jwtKey = configuration["Jwt:Key"]; 
            var issuer = configuration["Jwt:Issuer"] ?? "Ergo.IAM";
            var audience = configuration["Jwt:Audience"] ?? "Ergo.Client";

            services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            })
            .AddJwtBearer(options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    ValidIssuer = issuer,
                    ValidAudience = audience,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
                };
            });

            services.AddAuthorization(); 

            return services;
        }
    }
}