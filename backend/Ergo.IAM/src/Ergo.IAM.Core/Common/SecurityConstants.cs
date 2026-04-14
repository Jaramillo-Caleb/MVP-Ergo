namespace Ergo.IAM.Core.Common
{
    public static class SecurityConstants
    {
        public static readonly string[] AllowedExtensions = { ".jpg", ".jpeg", ".png" };
        public const long MaxFileSizeInBytes = 2 * 1024 * 1024;
    }
}