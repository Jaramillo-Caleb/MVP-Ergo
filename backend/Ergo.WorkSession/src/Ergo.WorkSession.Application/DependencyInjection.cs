using Ergo.WorkSession.Application.Interfaces;
using Ergo.WorkSession.Application.Services;
using Microsoft.Extensions.DependencyInjection;

namespace Ergo.WorkSession.Application
{
    public static class DependencyInjection
    {
        public static IServiceCollection AddApplicationLayer(this IServiceCollection services)
        {
            services.AddMemoryCache();
            services.AddScoped<ISessionOrchestrator, SessionOrchestrator>();

            return services;
        }
    }
}