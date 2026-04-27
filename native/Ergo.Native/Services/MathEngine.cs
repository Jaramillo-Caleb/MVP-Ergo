using System;
using Ergo.Native.Core;

namespace Ergo.Native.Services;

public class MathEngine
{
    private const double SimilarityThreshold = 0.78;
    private const double Sigma = 7.0; // Sensibilidad de la campana de Gauss

    public double[] FlattenAndNormalize(double[][] landmarks)
    {
        int n = landmarks.Length; // 5 puntos
        double[] flattened = new double[n * 3];

        // 1. Calcular Media (Cálculo del centroide)
        double mX = 0, mY = 0, mZ = 0;
        foreach (var p in landmarks) { mX += p[0]; mY += p[1]; mZ += p[2]; }
        mX /= n; mY /= n; mZ /= n;

        // 2. Calcular Desviación Estándar (Escalamiento)
        double variance = 0;
        foreach (var p in landmarks)
        {
            variance += Math.Pow(p[0] - mX, 2) + Math.Pow(p[1] - mY, 2) + Math.Pow(p[2] - mZ, 2);
        }
        double stdDev = Math.Sqrt(variance / (n * 3));
        if (stdDev < 0.001) stdDev = 1.0; // Evitar división por cero

        // 3. Aplicar Z-Score: (x - media) / stdDev
        for (int i = 0; i < n; i++)
        {
            flattened[i * 3 + 0] = (landmarks[i][0] - mX) / stdDev;
            flattened[i * 3 + 1] = (landmarks[i][1] - mY) / stdDev;
            flattened[i * 3 + 2] = (landmarks[i][2] - mZ) / stdDev;
        }

        return flattened;
    }

    public CalculationResult Compare(double[] current, double[] reference)
    {
        // Distancia Euclidiana entre vectores de 15 dimensiones
        double sumSquares = 0;
        for (int i = 0; i < current.Length; i++)
        {
            sumSquares += Math.Pow(current[i] - reference[i], 2);
        }
        double distance = Math.Sqrt(sumSquares);

        // Convertir distancia a score 0.0 - 1.0 usando Gauss
        double score = Math.Exp(-distance / Sigma);

        return new CalculationResult
        {
            Score = score,
            IsAlert = score < SimilarityThreshold,
            MessagePtr = IntPtr.Zero 
        };
    }
}