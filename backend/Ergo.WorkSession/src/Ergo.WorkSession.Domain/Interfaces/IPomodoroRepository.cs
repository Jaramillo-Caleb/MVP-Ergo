using Ergo.WorkSession.Domain.Entities;

namespace Ergo.WorkSession.Domain.Interfaces
{
    public interface IPomodoroRepository
    {
        Task<PomodoroSettings?> GetByUserIdAsync(Guid userId);
        Task AddAsync(PomodoroSettings settings);
        Task UpdateAsync(PomodoroSettings settings);
    }
}