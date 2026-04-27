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
    public static CalculationResult ProcessFrame(IntPtr imagePtr, int size, IntPtr referencePtr)
    {
        if (_visionService == null || _mathEngine == null)
            return new CalculationResult { Score = 0, IsAlert = false, MessagePtr = IntPtr.Zero };

        try 
        {
            double[][] landmarks = _visionService.ExtractLandmarks(imagePtr, size);
            double[] currentVector = _mathEngine.FlattenAndNormalize(landmarks);

            double[] referenceVector = new double[15];
            Marshal.Copy(referencePtr, referenceVector, 0, 15);

            return _mathEngine.Compare(currentVector, referenceVector);
        }
        catch (Exception ex)
        {
            Log($"Error en ciclo de procesamiento: {ex.Message}");
            return new CalculationResult { Score = 0, IsAlert = true, MessagePtr = IntPtr.Zero };
        }
    }

    [UnmanagedCallersOnly(EntryPoint = "extract_vectors")]
    public static unsafe int ExtractVectors(byte** imagesPtr, int* sizesPtr, int count, double* outputVectorsPtr)
    {
        Log($"--- [C#]: Inicio ExtractVectors Directo. Count: {count}");
    
        if (_visionService == null || _mathEngine == null) return 0;
    
        int successfulExtractions = 0;
    
        for (int i = 0; i < count; i++)
        {
            try 
            {
                // Acceso directo por punteros (como en C++)
                byte* currentImageBytes = imagesPtr[i];
                int size = sizesPtr[i];
    
                if (currentImageBytes == null || size <= 0) {
                    Log($"--- [C# ERROR]: Frame {i} tiene puntero nulo o tamaño 0");
                    continue;
                }
    
                Log($"--- [C#]: Procesando frame {i} ({size} bytes)...");
    
                // Convertimos el puntero crudo a IntPtr para el VisionService
                IntPtr imgIntPtr = (IntPtr)currentImageBytes;
                double[][] landmarks = _visionService.ExtractLandmarks(imgIntPtr, size);
                
                if (landmarks == null || landmarks.Length == 0) continue;
    
                double[] vector = _mathEngine.FlattenAndNormalize(landmarks);
                
                // Copiar el vector al buffer de salida
                // Cada vector ocupa 15 doubles (15 * 8 bytes)
                double* dest = outputVectorsPtr + (successfulExtractions * 15);
                for (int j = 0; j < 15; j++) {
                    dest[j] = vector[j];
                }
                
                successfulExtractions++;
                Log($"--- [C#]: Frame {i} OK.");
            }
            catch (Exception ex)
            {
                Log($"--- [C# CRITICAL] Frame {i}: {ex.Message}");
            }
        }
        
        Log($"--- [C#]: Total exitosos: {successfulExtractions}");
        return successfulExtractions;
    }
}