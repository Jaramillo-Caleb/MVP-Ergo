using Ergo.IAM.Api.Endpoints; 
using Ergo.IAM.Infrastructure;
using Ergo.IAM.Infrastructure.Persistence.Contexts;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using SQLitePCL;
using Ergo.IAM.Core.Interfaces;
using Ergo.IAM.Infrastructure.Services;
using System.IO;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Ergo.IAM.Core.Common;

var builder = WebApplication.CreateBuilder(args);

string dbPath;
string dbPassword;

if (Environment.GetEnvironmentVariable("DOTNET_RUNNING_IN_CONTAINER") == "true")
{
    dbPath = "/app/data/Identity.db";
    dbPassword = builder.Configuration["DB_PASSWORD"];
}
else
{
    var localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
    var ergoDataPath = Path.Combine(localAppData, "ErgoProject", "Database");
    
    if (!Directory.Exists(ergoDataPath)) 
    {
        Directory.CreateDirectory(ergoDataPath);
    }
    dbPath = Path.Combine(ergoDataPath, "Identity.db");

    var dataProtectionPath = Path.Combine(localAppData, "ErgoProject", "Keys");
    var dp = DataProtectionProvider.Create(new DirectoryInfo(dataProtectionPath));
    var protector = dp.CreateProtector("DatabaseProtector");

    var keyFilePath = Path.Combine(ergoDataPath, "db.key");
    if (File.Exists(keyFilePath))
    {
        dbPassword = protector.Unprotect(File.ReadAllText(keyFilePath));
    }
    else
    {
        dbPassword = Guid.NewGuid().ToString("N") + Guid.NewGuid().ToString("N");
        File.WriteAllText(keyFilePath, protector.Protect(dbPassword));
    }
}

builder.Configuration["ConnectionStrings:IdentityConnection"] = $"Data Source={dbPath};Password={dbPassword};";
Batteries_V2.Init();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.Configure<EmailSettings>(builder.Configuration.GetSection("EmailSettings"));

builder.Services.AddScoped<Ergo.IAM.Infrastructure.Services.LocalFileStorageService>();
builder.Services.AddScoped<IProfileService, Ergo.IAM.Infrastructure.Services.ProfileService>();

builder.Services.AddInfrastructure(builder.Configuration);

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutter",
        policy => policy.AllowAnyOrigin()
                        .AllowAnyMethod()
                        .AllowAnyHeader());
});

var app = builder.Build();

app.UseCors("AllowFlutter");

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var dbContext = services.GetRequiredService<IdentityDbContext>();
        dbContext.Database.Migrate();
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "Ocurrió un error al migrar o crear la base de datos de IAM.");
    }
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();

app.MapAuthEndpoints();

app.Run();