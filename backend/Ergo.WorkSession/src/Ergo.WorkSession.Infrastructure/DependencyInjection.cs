using Ergo.WorkSession.Domain.Interfaces;
using Ergo.WorkSession.Infrastructure.ExternalServices;
using Ergo.WorkSession.Infrastructure.Persistence;
using Ergo.WorkSession.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Ergo.WorkSession.Infrastructure
{
    public static class DependencyInjection
    {
        public static IServiceCollection AddInfrastructureLayer(
            this IServiceCollection services,
            IConfiguration configuration)
        {
            var connectionString = configuration.GetConnectionString("DefaultConnection")
                                   ?? "Data Source=WorkSession.db";

            services.AddDbContext<SessionDbContext>(options =>
                options.UseSqlite(connectionString));
            services.AddScoped<ISessionRepository, SessionRepository>();
            services.AddScoped<IReferencePoseRepository, ReferencePoseRepository>();
            services.AddScoped<IPomodoroRepository, PomodoroRepository>();
            var aiServiceUrl = configuration["AIEngine:BaseUrl"] ?? "http://localhost:8000";
            services.AddHttpClient<IAIEngineClient, AIEngineClient>(client =>
            {
                client.BaseAddress = new Uri(aiServiceUrl);
                client.Timeout = TimeSpan.FromSeconds(5);
            });

            return services;
        }
    }
}