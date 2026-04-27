using Microsoft.ML.OnnxRuntime;
using Microsoft.ML.OnnxRuntime.Tensors;
using OpenCvSharp;

using System.Runtime.InteropServices;

namespace Ergo.Native.Services;

public class VisionService : IDisposable
{
    private readonly InferenceSession _session;
    private readonly int[] _mapping = { 0, 7, 8, 11, 12 }; // Puntos de interés (Nariz, hombros, oídos)

    public VisionService(string modelPath)
    {
        // Configuración de sesión para alto rendimiento
        var options = new SessionOptions();
        options.AppendExecutionProvider_CPU(0); // Optimizado para CPU
        _session = new InferenceSession(modelPath, options);
    }

    public double[][] ExtractLandmarks(IntPtr imagePtr, int size)
    {

        if (imagePtr == IntPtr.Zero || size < 100) 
            throw new Exception("Imagen inválida o demasiado pequeña.");
        // 1. Decodificar
        byte[] buffer = new byte[size];
        Marshal.Copy(imagePtr, buffer, 0, size);

        using Mat frame = Cv2.ImDecode(buffer, ImreadModes.Color);
        if (frame.Empty()) throw new Exception("OpenCV no pudo decodificar el buffer.");

        using Mat rgbFrame = new Mat();
        Cv2.CvtColor(frame, rgbFrame, ColorConversionCodes.BGR2RGB);

        using Mat resized = new Mat();
        Cv2.Resize(rgbFrame, resized, new Size(256, 256));

        // 2. Preprocesamiento (MediaPipe Pose espera NHWC [1, 256, 256, 3])
        var inputTensor = new DenseTensor<float>(new[] { 1, 256, 256, 3 });
        for (int y = 0; y < 256; y++) {
            for (int x = 0; x < 256; x++) {
                var pixel = resized.At<Vec3b>(y, x);
                inputTensor[0, y, x, 0] = pixel.Item0 / 255f;
                inputTensor[0, y, x, 1] = pixel.Item1 / 255f;
                inputTensor[0, y, x, 2] = pixel.Item2 / 255f;
            }
        }

        // 3. Inferencia
        var inputs = new List<NamedOnnxValue> { NamedOnnxValue.CreateFromTensor("input_1", inputTensor) };
        using IDisposableReadOnlyCollection<DisposableNamedOnnxValue> results = _session.Run(inputs);

        // MediaPipe Lite suele tener el tensor de puntos en la primera salida o llamada "ld_3d"
        var outputTensor = results.FirstOrDefault(r => r.Name == "ld_3d") ?? results.First();
        float[] outputData = outputTensor.AsEnumerable<float>().ToArray();

        // 4. Filtrado (MediaPipe Pose tiene 33 o 39 puntos, cada uno con 5 floats)
        // _mapping = { 0, 7, 8, 11, 12 }
        double[][] filtered = new double[_mapping.Length][];
        for (int i = 0; i < _mapping.Length; i++)
        {
            // EL SALTO ES DE 5 EN MEDIAPIPE (x, y, z, visibility, presence)
            int idx = _mapping[i] * 5; 

            if (idx + 2 >= outputData.Length) 
                throw new Exception($"Índice de modelo fuera de rango: {idx}. El tensor tiene {outputData.Length} elementos.");

            filtered[i] = new double[] { 
                (double)outputData[idx], 
                (double)outputData[idx + 1], 
                (double)outputData[idx + 2] 
            };
        }

        return filtered;
    }

    public void Dispose() => _session?.Dispose();
}