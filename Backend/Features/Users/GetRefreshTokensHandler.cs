using Backend.Data;
using Backend.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using MediatR;

namespace Backend.Features.Users;

public class GetRefreshTokensHandler(
    UserManager<User> userManager,
    ApplicationContext context) : IRequestHandler<GetRefreshTokensRequest, IResult>
{
    public async Task<IResult> Handle(GetRefreshTokensRequest request, CancellationToken cancellationToken)
    {
        var user = await userManager.FindByIdAsync(request.UserId.ToString());
        
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
            .ToListAsync(cancellationToken);

        return Results.Ok(new
        {
            userEmail = user.Email,
            userId = user.Id,
            tokens = refreshTokens
        });
    }
}
