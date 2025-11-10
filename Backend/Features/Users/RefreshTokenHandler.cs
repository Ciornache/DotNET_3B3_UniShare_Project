using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Backend.Data;
using Backend.Persistence;
using Backend.TokenGenerators;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Backend.Features.Users;

public class RefreshTokenHandler(
    UserManager<Data.User> userManager, 
    ITokenService tokenService,
    ApplicationContext context)
{
    public async Task<IResult> Handle(RefreshTokenRequest request, HttpContext httpContext)
    {
        // Find the refresh token in the database
        var storedRefreshToken = await context.RefreshTokens
            .FirstOrDefaultAsync(rt => rt.Token == request.RefreshToken);
        
        if (storedRefreshToken == null)
        {
            return Results.Unauthorized();
        }

        // Get the user associated with this refresh token
        var user = await userManager.FindByIdAsync(storedRefreshToken.UserId.ToString());
        
        if (user == null)
        {
            return Results.Unauthorized();
        }

        // Check if token is expired
        if (storedRefreshToken.IsExpired)
        {
            return Results.Unauthorized();
        }

        // REUSE DETECTION: If token is already revoked but not expired, it means someone is trying to reuse it
        // This indicates a potential security breach - invalidate the entire token family
        if (storedRefreshToken.IsRevoked)
        {
            await RevokeTokenFamily(storedRefreshToken.TokenFamily, user.Id, "Token reuse detected - potential security breach");
            return Results.Unauthorized();
        }

        // TOKEN ROTATION: Revoke the current token and create a new one in the same family
        storedRefreshToken.IsRevoked = true;
        storedRefreshToken.RevokedAt = DateTime.UtcNow;
        storedRefreshToken.ReasonRevoked = "Rotated to new token";
        
        // Generate new tokens
        var newAccessToken = tokenService.GenerateToken(user);
        var newRefreshTokenString = tokenService.GenerateRefreshToken();
        
        // Create and store new refresh token (child token in the same family)
        var newRefreshToken = new RefreshToken
        {
            Token = newRefreshTokenString,
            UserId = user.Id,
            ExpiresAt = tokenService.GetRefreshTokenExpirationDate(),
            TokenFamily = storedRefreshToken.TokenFamily, // Same family
            ParentTokenId = storedRefreshToken.Id, // Link to parent
            ReplacedByTokenId = null
        };
        
        // Link parent to child
        storedRefreshToken.ReplacedByTokenId = newRefreshToken.Id;
        
        context.RefreshTokens.Add(newRefreshToken);
        await context.SaveChangesAsync();
        
        var response = new LoginUserResponse(
            AccessToken: newAccessToken,
            RefreshToken: newRefreshTokenString,
            ExpiresIn: tokenService.GetAccessTokenExpirationInSeconds()
        );
        
        return Results.Ok(response);
    }
    
    /// <summary>
    /// Revokes all tokens in a token family when reuse is detected
    /// </summary>
    private async Task RevokeTokenFamily(Guid tokenFamily, Guid userId, string reason)
    {
        var familyTokens = await context.RefreshTokens
            .Where(rt => rt.TokenFamily == tokenFamily && rt.UserId == userId)
            .ToListAsync();
        
        foreach (var token in familyTokens)
        {
            if (!token.IsRevoked)
            {
                token.IsRevoked = true;
                token.RevokedAt = DateTime.UtcNow;
                token.ReasonRevoked = reason;
            }
        }
        
        await context.SaveChangesAsync();
    }
}
