using System.Runtime.InteropServices;
using System.Reflection; 
using System.IO;         
using Ergo.Native.Core;    
using Ergo.Native.Services; 

namespace Ergo.Native;

public static class Bridge
{
    private static bool _isResolverInitialized = false;
    private static VisionService? _visionService;
    private static MathEngine? _mathEngine;


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
            }
            catch (Exception)
            {
            }
        }
    }

    [UnmanagedCallersOnly(EntryPoint = "process_frame")]
    public static CalculationResult ProcessFrame(IntPtr imagePtr, int size, IntPtr referencePtr, double threshold)
    {
        if (_visionService == null || _mathEngine == null)
            return new CalculationResult { Score = 0, IsAlert = 0, MessagePtr = IntPtr.Zero };

        try 
        {
            double[][]? landmarks = _visionService.ExtractLandmarks(imagePtr, size);
            
            // Si no hay usuario detectado, retornar score 1.0 (No alertar)
            if (landmarks == null) return MathEngine.NoUser();

            double[] currentVector = _mathEngine.FlattenAndNormalize(landmarks);

            double[] referenceVector = new double[15];
            Marshal.Copy(referencePtr, referenceVector, 0, 15);

            return _mathEngine.Compare(currentVector, referenceVector, threshold);
        }
        catch (Exception)
        {
            return new CalculationResult { Score = 1.0, IsAlert = 0, MessagePtr = IntPtr.Zero };
        }
    }

    [UnmanagedCallersOnly(EntryPoint = "extract_vectors")]
    public static unsafe int ExtractVectors(byte** imagesPtr, int* sizesPtr, int count, double* outputVectorsPtr)
    {
        if (_visionService == null || _mathEngine == null) {
            return 0;
            }
    
        int successfulExtractions = 0;
    
        for (int i = 0; i < count; i++)
        {
            try 
            {
                byte* currentImageBytes = imagesPtr[i];
                int size = sizesPtr[i];
    
                if (currentImageBytes == null || size <= 0) continue;
    
                IntPtr imgIntPtr = (IntPtr)currentImageBytes;
                double[][]? landmarks = _visionService.ExtractLandmarks(imgIntPtr, size);
                
                if (landmarks == null) {
                    continue;
                }
    
                double[] vector = _mathEngine.FlattenAndNormalize(landmarks);
                
                double* dest = outputVectorsPtr + (successfulExtractions * 15);
                for (int j = 0; j < 15; j++) {
                    dest[j] = vector[j];
                }
                
                successfulExtractions++;
            }
            catch (Exception)
            {
            }
        }       
        return successfulExtractions;
    }
}
