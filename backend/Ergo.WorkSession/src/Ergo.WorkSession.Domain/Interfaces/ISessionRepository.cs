using Ergo.WorkSession.Domain.Entities;

namespace Ergo.WorkSession.Domain.Interfaces
{
    public interface ISessionRepository
    {
        Task<Entities.WorkSession?> GetActiveSessionByUserIdAsync(Guid userId);

        Task<Entities.WorkSession?> GetByIdAsync(Guid id);

        Task AddAsync(Entities.WorkSession session);

        Task UpdateAsync(Entities.WorkSession session);
    }
}