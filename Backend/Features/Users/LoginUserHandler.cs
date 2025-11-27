using Microsoft.AspNetCore.Identity;
using Backend.Persistence;
using Backend.Data;
using Backend.TokenGenerators;
using Backend.Features.Users.Dtos;
using Microsoft.EntityFrameworkCore;
using MediatR;

namespace Backend.Features.Users;

public class LoginUserHandler(
    UserManager<User> userManager, 
    ITokenService tokenService,
    ApplicationContext context) : IRequestHandler<LoginUserRequest, IResult>
{
    public async Task<IResult> Handle(LoginUserRequest request, CancellationToken cancellationToken)
    {
        var user = await userManager.FindByEmailAsync(request.Email);
        
        if (user == null || !await userManager.CheckPasswordAsync(user, request.Password)) 
            return Results.Unauthorized();
        
        var existingTokens = await context.RefreshTokens
            .Where(rt => rt.UserId == user.Id)
            .ToListAsync(cancellationToken);
        
        if (existingTokens.Any())
            context.RefreshTokens.RemoveRange(existingTokens);

        var accessToken = tokenService.GenerateToken(user);
        var refreshTokenString = tokenService.GenerateRefreshToken();
        
        var tokenFamily = Guid.NewGuid();
        
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
        await context.SaveChangesAsync(cancellationToken);
        var isEmailVerified = user.EmailConfirmed;
        var response = new LoginUserResponseDto(
            AccessToken: accessToken,
            RefreshToken: refreshTokenString,
            ExpiresIn: tokenService.GetAccessTokenExpirationInSeconds(),
            EmailVerified: isEmailVerified 
        );
        
        return Results.Ok(response);
    }
}