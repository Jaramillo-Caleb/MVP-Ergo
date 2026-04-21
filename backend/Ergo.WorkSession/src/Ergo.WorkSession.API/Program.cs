using Ergo.WorkSession.API.Endpoints;
using Ergo.WorkSession.Application;
using Ergo.WorkSession.Infrastructure;
using Ergo.WorkSession.Infrastructure.Persistence;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.EntityFrameworkCore;
using SQLitePCL;
using System.IO;

var builder = WebApplication.CreateBuilder(args);

var localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
var ergoDataPath = Path.Combine(localAppData, "ErgoProject", "Database");
if (!Directory.Exists(ergoDataPath)) Directory.CreateDirectory(ergoDataPath);
var dbPath = Path.Combine(ergoDataPath, "ergo_local.db");

builder.Configuration["ConnectionStrings:DefaultConnection"] = $"Data Source={dbPath};";

Batteries_V2.Init();

const int MaxFileSize = 20 * 1024 * 1024;

builder.Services.Configure<KestrelServerOptions>(options =>
{
    options.Limits.MaxRequestBodySize = MaxFileSize;
});

builder.Services.Configure<FormOptions>(options =>
{
    options.ValueLengthLimit = int.MaxValue;
    options.MultipartBodyLengthLimit = MaxFileSize;
    options.MultipartHeadersLengthLimit = int.MaxValue;
});

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyHeader()
              .AllowAnyMethod()
              .SetIsOriginAllowed(origin => new Uri(origin).Host == "localhost")
              .AllowCredentials();
    });
});

builder.Services.AddApplicationLayer();
builder.Services.AddInfrastructureLayer(builder.Configuration);
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var dbContext = services.GetRequiredService<SessionDbContext>();
        dbContext.Database.Migrate();
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "Error migrating database.");
    }
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors();

app.MapSessionEndpoints();
app.MapUserEndpoints();
app.Run();
