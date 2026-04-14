using Ergo.IAM.Core.Entities;

namespace Ergo.IAM.Core.Interfaces
{
    public interface IUserRepository
    {
        Task<User?> GetByEmailAsync(string email);
        Task<User?> GetByIdAsync(Guid id);
        Task AddAsync(User user);
        Task<bool> ExistsAsync(string email);

        Task SaveChangesAsync();
    }
}
