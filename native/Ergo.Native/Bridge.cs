using System.Runtime.InteropServices;
namespace Ergo.Native;

public static class Bridge
{
    private static VisionService? _visionService;
    private static MathEngine? _mathEngine;

    [UnmanagedCallersOnly(EntryPoint = "init_native_engine")]
    public static void InitEngine()
    {
        _visionService = new VisionService(); 
        _mathEngine = new MathEngine();
    }

    [UnmanagedCallersOnly(EntryPoint = "process_frame")]
    public static CalculationResult ProcessFrame(IntPtr imagePtr, int width, int height, IntPtr referencePtr)
    {
        var currentLandmarks = _visionService.ExtractLandmarks(imagePtr, width, height);

        var currentVector = _mathEngine.Flatten(currentLandmarks);

        double[] referenceVector = new double[15];
        Marshal.Copy(referencePtr, referenceVector, 0, 15);

        return _mathEngine.Compare(currentVector, referenceVector);
    }
}