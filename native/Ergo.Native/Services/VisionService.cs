using Microsoft.ML.OnnxRuntime;
using Microsoft.ML.OnnxRuntime.Tensors;
using OpenCvSharp;

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

    public double[][] ExtractLandmarks(IntPtr imagePtr, int width, int height)
    {
        // 1. Crear Mat de OpenCV desde el puntero de memoria (Zero-copy)
        using Mat frame = Mat.FromPixelData(height, width, MatType.CV_8UC4, imagePtr);
        using Mat rgbFrame = new Mat();
        Cv2.CvtColor(frame, rgbFrame, ColorConversionCodes.BGRA2RGB);

        // 2. Preprocesamiento para MediaPipe Pose (256x256 es el estándar)
        using Mat resized = new Mat();
        Cv2.Resize(rgbFrame, resized, new Size(256, 256));
        
        // 3. Normalizar imagen a float [0, 1]
        var inputTensor = new DenseTensor<float>(new[] { 1, 256, 256, 3 });
        for (int y = 0; y < 256; y++)
        {
            for (int x = 0; x < 256; x++)
            {
                var pixel = resized.At<Vec3b>(y, x);
                inputTensor[0, y, x, 0] = pixel.Item0 / 255f;
                inputTensor[0, y, x, 1] = pixel.Item1 / 255f;
                inputTensor[0, y, x, 2] = pixel.Item2 / 255f;
            }
        }

        // 4. Inferencia
        var inputs = new List<NamedOnnxValue> { NamedOnnxValue.CreateFromTensor("input_1", inputTensor) };
        using IDisposableReadOnlyCollection<DisposableNamedOnnxValue> results = _session.Run(inputs);
        
        var output = results.First().AsEnumerable<float>().ToArray();

        // 5. Filtrado de puntos específicos (x, y, z)
        double[][] filtered = new double[5][];
        for (int i = 0; i < _mapping.Length; i++)
        {
            int idx = _mapping[i] * 3;
            // Guardamos coordenadas normalizadas
            filtered[i] = [ output[idx], output[idx + 1], output[idx + 2] ];
        }

        return filtered;
    }

    public void Dispose() => _session?.Dispose();
}