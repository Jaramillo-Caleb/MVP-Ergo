using Ergo.WorkSession.API.Endpoints;
using Ergo.WorkSession.Application;
using Ergo.WorkSession.Infrastructure;
using Ergo.WorkSession.Infrastructure.Persistence;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.EntityFrameworkCore;
using SQLitePCL;
using System.IO; 
using Microsoft.AspNetCore.DataProtection; 

var builder = WebApplication.CreateBuilder(args);

string dbPath;
string dbPassword;

if (Environment.GetEnvironmentVariable("DOTNET_RUNNING_IN_CONTAINER") == "true")
{
    var dbFolder = "/app/data";
    if (!Directory.Exists(dbFolder)) Directory.CreateDirectory(dbFolder);

    dbPath = "/app/data/Session.db";
    dbPassword = builder.Configuration["DB_PASSWORD"];
}
else
{
    var localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
    var ergoDataPath = Path.Combine(localAppData, "ErgoProject", "Database");
    
    if (!Directory.Exists(ergoDataPath)) Directory.CreateDirectory(ergoDataPath);
    
    dbPath = Path.Combine(ergoDataPath, "Session.db");

    var dataProtectionPath = Path.Combine(localAppData, "ErgoProject", "Keys");
    var dp = DataProtectionProvider.Create(new DirectoryInfo(dataProtectionPath));
    var protector = dp.CreateProtector("WorkSessionProtector");

    var keyFilePath = Path.Combine(ergoDataPath, "session_db.key");

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

builder.Configuration["ConnectionStrings:DefaultConnection"] = $"Data Source={dbPath};Password={dbPassword};";

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
    catch(Exception exepcion)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(exepcion, "Ocurrió un error al migrar o crear la base de datos SQLCipher.");
    }
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();
app.MapSessionEndpoints();
app.Run();