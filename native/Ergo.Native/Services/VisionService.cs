namespace Ergo.Native.Services;

var options = new SessionOptions();
var session = new InferenceSession("assets/models/pose_landmark_lite.onnx", options);

public class VisionService
{
    private InferenceSession _session;
    private readonly int[] _relevantLandmarks = { 0, 7, 8, 11, 12 };

    public VisionService(string modelPath)
    {
        _session = new InferenceSession(modelPath);
    }

   public double[][] ExtractLandmarks(IntPtr imagePtr, int width, int height)
    {
        float[] rawOutput = RunInference(imagePtr); 

        double[][] filtered = new double[5][];
        int[] mapping = { 0, 7, 8, 11, 12 };

        for (int i = 0; i < mapping.Length; i++)
        {
            int idx = mapping[i] * 3;
            filtered[i] = [ rawOutput[idx], rawOutput[idx+1], rawOutput[idx+2] ];
        }

        return filtered; 
        }
}