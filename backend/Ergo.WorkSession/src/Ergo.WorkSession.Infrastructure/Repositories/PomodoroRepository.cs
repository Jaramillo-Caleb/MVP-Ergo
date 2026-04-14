using Ergo.WorkSession.Domain.Entities;
using Ergo.WorkSession.Domain.Interfaces;
using Ergo.WorkSession.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Ergo.WorkSession.Infrastructure.Repositories
{
    public class PomodoroRepository : IPomodoroRepository
    {
        private readonly SessionDbContext _context;

        public PomodoroRepository(SessionDbContext context)
        {
            _context = context;
        }

        public async Task<PomodoroSettings?> GetByUserIdAsync(Guid userId)
        {
            return await _context.PomodoroSettings
                .FirstOrDefaultAsync(s => s.UserId == userId);
        }

        public async Task AddAsync(PomodoroSettings settings)
        {
            _context.PomodoroSettings.Add(settings);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(PomodoroSettings settings)
        {
            _context.PomodoroSettings.Update(settings);
            await _context.SaveChangesAsync();
        }
    }
}