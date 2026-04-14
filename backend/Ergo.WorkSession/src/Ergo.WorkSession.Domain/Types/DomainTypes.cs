namespace Ergo.WorkSession.Domain.Types
{
    public record CalibrationResult(double[] Vector, string Message);
    public record ComparisonResult(double Score, bool IsCorrect, string Message);
}
