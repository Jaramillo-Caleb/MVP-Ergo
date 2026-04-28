using System;
using Ergo.Native.Core;

namespace Ergo.Native.Services;

public class MathEngine
{
    private const int LandmarkCount = 5;
    private const int VectorSize = LandmarkCount * 3;
    private const double FrameSize = 256.0;

    public double[] FlattenAndNormalize(double[][] landmarks)
    {
        double[] flattened = new double[VectorSize];
        for (int i = 0; i < landmarks.Length; i++)
        {
            flattened[i * 3 + 0] = landmarks[i][0];
            flattened[i * 3 + 1] = landmarks[i][1];
            flattened[i * 3 + 2] = landmarks[i][2];
        }
        return flattened;
    }

    public CalculationResult Compare(double[] current, double[] reference, double threshold)
    {
        // Puntos: 0:Nose, 1:L-Eye, 2:R-Eye, 3:L-Shoulder, 4:R-Shoulder
    
        double refScale = GetDist(reference, 3, 4); // distancia hombros como unidad
        double curScale = GetDist(current, 3, 4);
    
        // Evitar división por cero
        if (refScale < 1e-6 || curScale < 1e-6)
            return new CalculationResult { Score = 1.0, IsAlert = 0, MessagePtr = IntPtr.Zero };

        double scaleRatio = curScale / refScale;
        if (scaleRatio > 1.8 || scaleRatio < 0.4)
            return new CalculationResult { Score = 1.0, IsAlert = 0, MessagePtr = IntPtr.Zero };
    
        // --- 1. SLOUCH: ratio altura cara/hombros (normalizado por escala) ---
        // Qué tan "alto" está el centro de los ojos respecto a los hombros
        double refEyeMidY   = (reference[1*3+1] + reference[2*3+1]) / 2.0;
        double refShoulderMidY = (reference[3*3+1] + reference[4*3+1]) / 2.0;
        double refHeightRatio = (refShoulderMidY - refEyeMidY) / refScale;
    
        double curEyeMidY   = (current[1*3+1] + current[2*3+1]) / 2.0;
        double curShoulderMidY = (current[3*3+1] + current[4*3+1]) / 2.0;
        if (curEyeMidY - refEyeMidY > 0.15)
            return new CalculationResult { Score = 1.0, IsAlert = 0, MessagePtr = IntPtr.Zero };
        double curHeightRatio = (curShoulderMidY - curEyeMidY) / curScale;
    
        double slouchDiff = Math.Abs(curHeightRatio - refHeightRatio);
        double scoreSlouch = Math.Clamp(1.0 - (slouchDiff * 2.5), 0.0, 1.0);
    
        // --- 2. FORWARD HEAD: nariz relativa a hombros en Y (encorvamiento hacia adelante) ---
        double refNoseToShoulderY = (reference[0*3+1] - refShoulderMidY) / refScale;
        double curNoseToShoulderY = (current[0*3+1]   - curShoulderMidY) / curScale;
    
        double forwardDiff = Math.Abs(curNoseToShoulderY - refNoseToShoulderY);
        double scoreForward = Math.Clamp(1.0 - (forwardDiff * 2.5), 0.0, 1.0);
    
        // --- 3. TILT: ángulo de inclinación lateral de los ojos ---
        double dx = current[2*3+0] - current[1*3+0];
        double dy = current[2*3+1] - current[1*3+1];
        double anguloOjos = Math.Atan2(dy, dx) * (180.0 / Math.PI);
        double anguloNormalizado = dx < 0
            ? (anguloOjos > 0 ? anguloOjos - 180.0 : anguloOjos + 180.0)
            : anguloOjos;
            
        double scoreTilt = Math.Clamp(1.0 - (Math.Abs(anguloNormalizado) / 35.0), 0.0, 1.0);
    
        // --- Score final ponderado ---
        double finalScore = (scoreSlouch * 0.40) +
                            (scoreForward * 0.40) +
                            (scoreTilt    * 0.20);
    
        return new CalculationResult
        {
            Score = finalScore,
            IsAlert = (finalScore < threshold) ? 1 : 0,
            MessagePtr = IntPtr.Zero
        };
    }

    private double GetDist(double[] data, int p1, int p2)
    {
        double dx = data[p1 * 3] - data[p2 * 3];
        double dy = data[p1 * 3 + 1] - data[p2 * 3 + 1];
        double dz = data[p1 * 3 + 2] - data[p2 * 3 + 2];
        return Math.Sqrt(dx * dx + dy * dy + dz * dz);
    }

    public static CalculationResult NoUser() => new() { Score = 1.0, IsAlert = 0 };
}
