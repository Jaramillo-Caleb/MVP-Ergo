using Ergo.IAM.Core.Entities;

namespace Ergo.IAM.Core.Interfaces
{
    public interface ITokenService
    {
        string CreateToken(User user);
    }
}