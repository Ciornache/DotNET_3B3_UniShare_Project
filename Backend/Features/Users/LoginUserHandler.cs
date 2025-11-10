using Microsoft.AspNetCore.Identity;
using Backend.Persistence;

namespace Backend.Features.Users;
using Data;
using TokenGenerators;
using Microsoft.EntityFrameworkCore;

public class LoginUserHandler(
    UserManager<Data.User> userManager, 
    ITokenService tokenService,
    ApplicationContext context)
{
    public async Task<IResult> Handle(LoginUserRequest request)
    {
        var user = await userManager.FindByEmailAsync(request.Email);
        
        if (user == null || !await userManager.CheckPasswordAsync(user, request.Password)) 
        {
            return Results.Unauthorized();
        }

        // Check if email is confirmed
        if (!user.EmailConfirmed)
        {
            return Results.BadRequest(new { error = "Please verify your email address before logging in" });
        }

        // Delete all existing refresh tokens for this user (on re-authentication)
        var existingTokens = await context.RefreshTokens
            .Where(rt => rt.UserId == user.Id)
            .ToListAsync();
        
        if (existingTokens.Any())
        {
            context.RefreshTokens.RemoveRange(existingTokens);
        }

        // Generate tokens
        var accessToken = tokenService.GenerateToken(user);
        var refreshTokenString = tokenService.GenerateRefreshToken();
        
        // Create new token family for this login session
        var tokenFamily = Guid.NewGuid();
        
        // Store refresh token in the database
        var refreshToken = new RefreshToken
        {
            Token = refreshTokenString,
            UserId = user.Id,
            ExpiresAt = tokenService.GetRefreshTokenExpirationDate(),
            TokenFamily = tokenFamily,
            ParentTokenId = null,
            ReplacedByTokenId = null
        };
        
        context.RefreshTokens.Add(refreshToken);
        await context.SaveChangesAsync();
        
        var response = new LoginUserResponse(
            AccessToken: accessToken,
            RefreshToken: refreshTokenString,
            ExpiresIn: tokenService.GetAccessTokenExpirationInSeconds()
        );
        
        return Results.Ok(response);
    }
}