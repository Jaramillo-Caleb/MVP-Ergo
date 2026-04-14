namespace Ergo.IAM.Core.Interfaces
{
    public interface IPasswordResetService
    {
        /// <summary>
        /// Genera un código, lo asigna al usuario y dispara el envío del correo.
        /// </summary>
        Task<bool> RequestResetAsync(string email);

        /// <summary>
        /// Valida el código, verifica la expiración y actualiza la contraseña.
        /// </summary>
        Task<bool> ResetPasswordAsync(string email, string code, string newPassword);
    }
}