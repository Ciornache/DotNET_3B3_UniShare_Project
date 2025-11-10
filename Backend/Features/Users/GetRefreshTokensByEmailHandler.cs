using Backend.Data;
using Backend.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Backend.Features.Users;

public class GetRefreshTokensByEmailHandler(
    UserManager<User> userManager,
    ApplicationContext context)
{
    public async Task<IResult> Handle(GetRefreshTokensByEmailRequest request)
    {
        var user = await userManager.FindByEmailAsync(request.Email);
        
        if (user == null)
        {
            return Results.NotFound(new { message = "User not found" });
        }

        var refreshTokens = await context.RefreshTokens
            .Where(rt => rt.UserId == user.Id)
            .OrderByDescending(rt => rt.CreatedAt)
            .Select(rt => new
            {
                rt.Id,
                rt.Token,
                rt.CreatedAt,
                rt.ExpiresAt,
                rt.IsExpired,
                rt.IsRevoked,
                rt.RevokedAt,
                rt.ReasonRevoked,
                rt.TokenFamily,
                rt.ParentTokenId,
                rt.ReplacedByTokenId
            })
            .ToListAsync();

        return Results.Ok(new
        {
            userEmail = user.Email,
            userId = user.Id,
            tokens = refreshTokens
        });
    }
}

