using Ergo.WorkSession.Domain.Enums;

namespace Ergo.WorkSession.Application.DTOs
{
    public record CreatePostureRequest(
        Guid UserId,
        string Alias,
        double[] Vector, 
        bool IsPersistent
    );

    public record StartSessionRequest(
        Guid UserId,
        SessionMode Mode,
        int DurationMinutes,
        Guid? PostureId,           
        double[]? TemporaryVector  
    );

    public record WorkSessionDto(
        Guid SessionId,
        string Status,
        SessionMode Mode,
        DateTime StartTime
    );

    public record ReferencePoseDto(
        Guid Id,
        string Alias,
        bool IsPersistent,
        DateTime CreatedAt
    );

    public record CalibrationResultDto(
        double[] Vector,
        string Message
    );

    public record MonitorResultDto(
        double Score,
        bool IsAlert,
        string Message
    );

    public record PomodoroSettingsRequest(
        Guid UserId,
        int WorkDuration,
        int BreakDuration,
        bool AutoStart,
        int Repetitions
    );

    public record PomodoroSettingsResponse(
        Guid UserId,
        int WorkDuration,
        int BreakDuration,
        bool AutoStart,
        int Repetitions
    );
    }