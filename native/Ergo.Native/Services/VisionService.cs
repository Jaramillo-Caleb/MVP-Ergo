using Microsoft.ML.OnnxRuntime;
using Microsoft.ML.OnnxRuntime.Tensors;
using OpenCvSharp;

using System.Runtime.InteropServices;

namespace Ergo.Native.Services;

public class VisionService : IDisposable
{
    private readonly InferenceSession _session;
    // MoveNet: 0:Nose, 1:L-Eye, 2:R-Eye, 5:L-Shoulder, 6:R-Shoulder
    private readonly int[] _mapping = { 0, 1, 2, 5, 6 };

    public VisionService(string modelPath)
    {
        var options = new SessionOptions();
        options.AppendExecutionProvider_CPU(0);
        _session = new InferenceSession(modelPath, options);

        foreach (var input in _session.InputMetadata)
    
        foreach (var output in _session.OutputMetadata);
    }

    public double[][]? ExtractLandmarks(IntPtr imagePtr, int size)
    {
        if (imagePtr == IntPtr.Zero || size < 100) throw new Exception("Imagen inválida.");

        byte[] buffer = new byte[size];
        Marshal.Copy(imagePtr, buffer, 0, size);

        using Mat frame = Cv2.ImDecode(buffer, ImreadModes.Color);
        if (frame.Empty()) throw new Exception("Error decodificación OpenCV.");

        // MoveNet espera 192x192 int32
        using Mat resized = new Mat();
        Cv2.Resize(frame, resized, new Size(192, 192));

        using Mat lab = new Mat();
        Cv2.CvtColor(resized, lab, ColorConversionCodes.BGR2Lab);

        Mat[] channels = Cv2.Split(lab);
        try 
        {
            using var clahe = Cv2.CreateCLAHE(clipLimit: 2.0, tileGridSize: new Size(8, 8));
            clahe.Apply(channels[0], channels[0]);

            Cv2.Merge(channels, lab);
        }
        finally 
        {
            if (channels != null)
            {
                foreach (var ch in channels) ch?.Dispose();
            }
        }
        using Mat normalized = new Mat();
        Cv2.CvtColor(lab, normalized, ColorConversionCodes.Lab2BGR);

        // Input: [1, 192, 192, 3] de tipo Int32
        var inputTensor = new DenseTensor<byte>(new[] { 1, 192, 192, 4 });
        for (int y = 0; y < 192; y++)
        for (int x = 0; x < 192; x++)
        {
            var pixel = normalized.At<Vec3b>(y, x);
            inputTensor[0, y, x, 0] = pixel.Item2; // R (BGR->RGB)
            inputTensor[0, y, x, 1] = pixel.Item1; // G
            inputTensor[0, y, x, 2] = pixel.Item0; // B 
            inputTensor[0, y, x, 3] = 255;         // A
        }

        var inputs = new List<NamedOnnxValue>
        {
            NamedOnnxValue.CreateFromTensor("pixel_values", inputTensor)
        };

        using var results = _session.Run(inputs);

        // Output: [1, 1, 17, 3] → [y, x, score] normalizados 0-1
        var outputTensor = results.First(r => r.Name == "keypoints");
        float[] output = outputTensor.AsEnumerable<float>().ToArray();

        if (!ValidateUserPresence(output)) return null;

        return ExtractPoints(output);
    }

    private bool ValidateUserPresence(float[] data)
    {
        const float MinScore = 0.3f;
        foreach (int pt in _mapping)
        {
            float score = data[pt * 3 + 2];
            if (score < MinScore) return false;
        }

        // Nariz arriba de hombros (Y normalizado, mayor Y = más abajo)
        float noseY = data[0 * 3 + 0];
        float shoulderY = (data[5 * 3 + 0] + data[6 * 3 + 0]) / 2f;
        if (noseY > shoulderY) return false;

        return true;
    }

    private double[][] ExtractPoints(float[] data)
    {
        double[][] points = new double[_mapping.Length][];
        for (int i = 0; i < _mapping.Length; i++)
        {
            int idx = _mapping[i] * 3;
            // MoveNet: [y, x, score] — guardamos x, y, score como z
            points[i] = new double[]
            {
                (double)data[idx + 1], // x
                (double)data[idx + 0], // y
                (double)data[idx + 2]  // score como "z" para compatibilidad
            };
        }
        return points;
    }

    public void Dispose() => _session?.Dispose();
}
