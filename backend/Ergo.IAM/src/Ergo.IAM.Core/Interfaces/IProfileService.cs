using System.IO;
using System.Threading.Tasks;

namespace Ergo.IAM.Core.Interfaces
{
    public interface IProfileService
    {
        Task<(bool Success, string Message, string? Path)> UpdateProfileAsync(
            Guid userId, 
            string fullName, 
            DateTime birthDate, 
            string gender, 
            string location, 
            string occupation, 
            Stream? imageStream, 
            string? fileName
        );
    }
}