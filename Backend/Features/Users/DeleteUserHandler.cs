using Backend.Data;
using Backend.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Backend.Features.Users;

public class DeleteUserHandler(
    UserManager<User> userManager,
    ApplicationContext context)
{
    public async Task<IResult> Handle(DeleteUserRequest request)
    {
        var user = await userManager.FindByEmailAsync(request.Email);
        
        if (user == null) {
            return Results.NotFound(new { message = "User not found" });
        }

        var refreshTokens = await context.RefreshTokens
            .Where(rt => rt.UserId == user.Id)
            .ToListAsync();
        
        if (refreshTokens.Any()) {
            context.RefreshTokens.RemoveRange(refreshTokens);
        }

        var emailTokens = await context.EmailConfirmationTokens
            .Where(et => et.UserId == user.Id)
            .ToListAsync();
        
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

        await context.SaveChangesAsync();

        return Results.Ok(new
        {
            message = "User deleted successfully",
            email = request.Email,
            refreshTokensDeleted = refreshTokens.Count,
            emailTokensDeleted = emailTokens.Count
        });
    }
}

