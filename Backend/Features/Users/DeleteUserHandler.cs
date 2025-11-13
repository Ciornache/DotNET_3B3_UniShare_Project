using Backend.Data;
using Backend.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using MediatR;

namespace Backend.Features.Users;

public class DeleteUserHandler(
    UserManager<User> userManager,
    ApplicationContext context) : IRequestHandler<DeleteUserRequest, IResult>
{
    public async Task<IResult> Handle(DeleteUserRequest request, CancellationToken cancellationToken)
    {
        var user = await userManager.FindByIdAsync(request.UserId.ToString());
        
        if (user == null) {
            return Results.NotFound(new { message = "User not found" });
        }

        var refreshTokens = await context.RefreshTokens
            .Where(rt => rt.UserId == user.Id)
            .ToListAsync(cancellationToken);
        
        if (refreshTokens.Any()) {
            context.RefreshTokens.RemoveRange(refreshTokens);
        }

        var emailTokens = await context.EmailConfirmationTokens
            .Where(et => et.UserId == user.Id)
            .ToListAsync(cancellationToken);
        
        if (emailTokens.Any()) {
            context.EmailConfirmationTokens.RemoveRange(emailTokens);
        }

        var result = await userManager.DeleteAsync(user);
        
        if (!result.Succeeded)
        {
            return Results.BadRequest(new
            {
                message = "Failed to delete user",
                errors = result.Errors
            });
        }

        await context.SaveChangesAsync(cancellationToken);

        return Results.Ok(new
        {
            message = "User deleted successfully",
            userId = user.Id
        });
    }
}
