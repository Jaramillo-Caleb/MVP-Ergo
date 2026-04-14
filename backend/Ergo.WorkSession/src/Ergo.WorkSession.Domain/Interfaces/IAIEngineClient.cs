using Ergo.WorkSession.Domain.Types;

namespace Ergo.WorkSession.Domain.Interfaces
{
    public interface IAIEngineClient
    {
        Task<CalibrationResult> CalibrateAsync(List<byte[]> images);
        Task<ComparisonResult> CompareAsync(byte[] image, double[] referenceVector);
    }
}