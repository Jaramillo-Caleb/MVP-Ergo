using Ergo.WorkSession.Domain.Entities;
using Ergo.WorkSession.Domain.Interfaces;
using Ergo.WorkSession.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Ergo.WorkSession.Infrastructure.Repositories
{
    public class ReferencePoseRepository : IReferencePoseRepository
    {
        private readonly SessionDbContext _context;

        public ReferencePoseRepository(SessionDbContext context)
        {
            _context = context;
        }

        public async Task<ReferencePose?> GetByIdAsync(Guid id)
        {
            return await _context.ReferencePoses.FindAsync(id);
        }

        public async Task<IEnumerable<ReferencePose>> GetPersistentByUserIdAsync(Guid userId)
        {
            return await _context.ReferencePoses
                .Where(x => x.UserId == userId && x.IsPersistent)
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();
        }

        public async Task AddAsync(ReferencePose referencePose)
        {
            await _context.ReferencePoses.AddAsync(referencePose);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(ReferencePose referencePose)
        {
            _context.ReferencePoses.Update(referencePose);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(Guid id)
        {
            var entity = await _context.ReferencePoses.FindAsync(id);
            if (entity != null)
            {
                _context.ReferencePoses.Remove(entity);
                await _context.SaveChangesAsync();
            }
        }
    }
}