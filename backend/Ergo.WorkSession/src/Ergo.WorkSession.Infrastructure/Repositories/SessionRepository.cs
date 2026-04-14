using Ergo.WorkSession.Domain.Interfaces;
using Ergo.WorkSession.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Ergo.WorkSession.Infrastructure.Repositories
{
    public class SessionRepository : ISessionRepository
    {
        private readonly SessionDbContext _context;

        public SessionRepository(SessionDbContext context)
        {
            _context = context;
        }

        public async Task<Domain.Entities.WorkSession?> GetActiveSessionByUserIdAsync(Guid userId)
        {
            return await _context.WorkSessions
                .Include(s => s.Events)
                .FirstOrDefaultAsync(s => s.UserId == userId && s.EndTime == null);
        }

        public async Task<Domain.Entities.WorkSession?> GetByIdAsync(Guid id)
        {
            return await _context.WorkSessions
                .Include(s => s.Events)
                .FirstOrDefaultAsync(s => s.Id == id);
        }

        public async Task AddAsync(Domain.Entities.WorkSession session)
        {
            await _context.WorkSessions.AddAsync(session);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Domain.Entities.WorkSession session)
        {
            _context.WorkSessions.Update(session);
            await _context.SaveChangesAsync();
        }
    }
}