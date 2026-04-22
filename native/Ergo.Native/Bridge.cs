using System.Runtime.InteropServices;

namespace Ergo.Native;

public static class Bridge
{
    [UnmanagedCallersOnly(EntryPoint = "sumar_test")]
    public static int SumarTest(int a, int b)
    {
        return a + b;
    }
}