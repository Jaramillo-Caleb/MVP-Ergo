using System;
using System.Linq;

namespace Ergo.Native.Services;

public class MathEngine
{
    private const double SimilarityThreshold = 0.92;
    private const double SigmaTolerance = 5.5;

    public (double Score, bool IsAlert) CompareVectors(double[] current, double[] reference)
    {
        double sumSquares = 0;
        for (int i = 0; i < current.Length; i++)
        {
            double diff = current[i] - reference[i];
            sumSquares += diff * diff;
        }
        double euclideanDistance = Math.Sqrt(sumSquares);

        double score = Math.Exp(-euclideanDistance / SigmaTolerance);

        bool isCorrect = score >= SimilarityThreshold;

        return (score, !isCorrect);
    }

    public double[] Normalize(double[][] landmarks)
    {
        int numPoints = 5;
        double[] flattened = new double[numPoints * 3];

        // 1. Calcular Media (μ) - np.mean
        double meanX = 0, meanY = 0, meanZ = 0;
        foreach (var p in landmarks) { meanX += p[0]; meanY += p[1]; meanZ += p[2]; }
        meanX /= numPoints; meanY /= numPoints; meanZ /= numPoints;

        double sumVariance = 0;
        double[][] centered = new double[numPoints][];
        
        for (int i = 0; i < numPoints; i++)
        {
            centered[i] = [landmarks[i][0] - meanX, landmarks[i][1] - meanY, landmarks[i][2] - meanZ ];
            sumVariance += (centered[i][0] * centered[i][0]) + (centered[i][1] * centered[i][1]) + (centered[i][2] * centered[i][2]);
        }

        double stdDev = Math.Sqrt(sumVariance / (numPoints * 3));
        if (stdDev == 0) stdDev = 1.0;

        for (int i = 0; i < numPoints; i++)
        {
            flattened[i * 3 + 0] = centered[i][0] / stdDev;
            flattened[i * 3 + 1] = centered[i][1] / stdDev;
            flattened[i * 3 + 2] = centered[i][2] / stdDev;
        }

        return flattened;
    }
}