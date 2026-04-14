using Microsoft.Extensions.Configuration;

namespace Ergo.IAM.Infrastructure.Services
{
    public class LocalFileStorageService
    {
        private readonly string _uploadPath;
    
        public LocalFileStorageService(IConfiguration config)
        {
            _uploadPath = config["Storage:UploadPath"] ?? "wwwroot/avatars";
        }
    
        public async Task<string> SaveFileAsync(Stream fileStream, string fileName)
        {
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".webp" };
            var extension = Path.GetExtension(fileName).ToLower();

            if (!allowedExtensions.Contains(extension))
                throw new InvalidOperationException("Tipo de archivo no permitido.");

            if (!Directory.Exists(_uploadPath)) Directory.CreateDirectory(_uploadPath);
    
            var uniqueName = $"{Guid.NewGuid()}{extension}";
            var fullPath = Path.Combine(_uploadPath, uniqueName);
    
            using (var stream = new FileStream(fullPath, FileMode.Create))
            {
                await fileStream.CopyToAsync(stream);
            }
    
            return $"/avatars/{uniqueName}"; 
        }
    }
}