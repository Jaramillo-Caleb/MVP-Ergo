using System.Runtime.InteropServices;
using System.Reflection; 
using System.IO;         
using Ergo.Native.Core;    
using Ergo.Native.Services; 

namespace Ergo.Native;

public delegate void LogCallback(IntPtr message);

[StructLayout(LayoutKind.Sequential)]
public struct CalculationResult 
{
    public double Score;
    public bool IsAlert;
    public IntPtr MessagePtr; 
}

public static class Bridge
{
    private static bool _isResolverInitialized = false;
    private static VisionService? _visionService;
    private static MathEngine? _mathEngine;
    private static LogCallback? _logger;

    [UnmanagedCallersOnly(EntryPoint = "register_logger")]
    public static void RegisterLogger(IntPtr callbackPtr)
    {
        _logger = Marshal.GetDelegateForFunctionPointer<LogCallback>(callbackPtr);
        Log("Motor Nativo: Sistema de telemetría unificado activo.");
    }

    public static void Log(string message)
    {
        if (_logger != null)
        {
            IntPtr ptr = Marshal.StringToHGlobalAnsi(message);
            _logger(ptr);
            Marshal.FreeHGlobal(ptr);
        }
    }

    [UnmanagedCallersOnly(EntryPoint = "init_native_engine")]
    public static void InitEngine(IntPtr modelPathPtr)
    {
        if (!_isResolverInitialized)
        {
            try
            {
                 NativeLibrary.SetDllImportResolver(Assembly.GetExecutingAssembly(), (name, assembly, path) =>
                {
                    string libPath = Path.Combine(AppContext.BaseDirectory, name);
                    return File.Exists(libPath) ? NativeLibrary.Load(libPath) : IntPtr.Zero;
                }); 
                _isResolverInitialized = true;
            }
            catch (InvalidOperationException)
            {
                 _isResolverInitialized = true;
            }
        }
        
        string? modelFileName  = Marshal.PtrToStringAnsi(modelPathPtr);
        if (modelFileName != null)
        {
            string fullPath = Path.Combine(AppContext.BaseDirectory, modelFileName );

            try 
            {
                _visionService = new VisionService(fullPath);
                _mathEngine = new MathEngine();
                Log($"Motor Nativo: IA inicializada desde {fullPath}");
            }
            catch (Exception ex)
            {
                Log($"ERROR en inicialización: {ex.Message}");
            }
        }
    }

    [UnmanagedCallersOnly(EntryPoint = "process_frame")]
    public static CalculationResult ProcessFrame(IntPtr imagePtr, int width, int height, IntPtr referencePtr)
    {
        if (_visionService == null || _mathEngine == null)
            return new CalculationResult { Score = 0, IsAlert = false, MessagePtr = IntPtr.Zero };

        // Inferencia
        try 
        {
            // 1. Extracción de landmarks usando tu VisionService (OpenCV + ONNX)
            // Devuelve double[5][]
            double[][] landmarks = _visionService.ExtractLandmarks(imagePtr, width, height);
            
            // 2. Normalización y aplanado (Lógica ex-Python portada a MathEngine)
            double[] currentVector = _mathEngine.FlattenAndNormalize(landmarks);

            // 3. Obtener el vector de referencia enviado desde Dart
            double[] referenceVector = new double[15];
            Marshal.Copy(referencePtr, referenceVector, 0, 15);

            // 4. Comparación mediante Kernel RBF (Devuelve CalculationResult)
            return _mathEngine.Compare(currentVector, referenceVector);
        }
        catch (Exception ex)
        {
            Log($"Error en ciclo de procesamiento: {ex.Message}");
            return new CalculationResult { Score = 0, IsAlert = true, MessagePtr = IntPtr.Zero };
        }
    }
}