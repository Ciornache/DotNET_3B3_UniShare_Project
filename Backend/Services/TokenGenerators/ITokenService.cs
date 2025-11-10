using Backend.Data;

namespace Backend.TokenGenerators;

public interface ITokenService
{
    string GenerateToken(User user);
    string GenerateRefreshToken();
    int GetAccessTokenExpirationInSeconds();
    DateTime GetRefreshTokenExpirationDate();
}