using Ergo.WorkSession.Domain.Entities;

namespace Ergo.WorkSession.Domain.Interfaces
{
    public interface IReferencePoseRepository
    {
        Task<ReferencePose?> GetByIdAsync(Guid id);

        Task<IEnumerable<ReferencePose>> GetPersistentByUserIdAsync(Guid userId);

        Task AddAsync(ReferencePose referencePose);

        Task UpdateAsync(ReferencePose referencePose);

        Task DeleteAsync(Guid id);
    }
}