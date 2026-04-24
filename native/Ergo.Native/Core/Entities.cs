using System.Runtime.InteropServices;

namespace Ergo.Native.Core;

[StructLayout(LayoutKind.Sequential)]
public struct CalculationResult
{
    public double Score;
    public bool IsAlert;
    public IntPtr MessagePtr; 
}

[StructLayout(LayoutKind.Sequential)]
public struct BodyVector
{
    public unsafe fixed double Data[15]; // 5 puntos * (x, y, z)
}