using Backend.Data;
using Backend.Persistence;
using Backend.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Backend.Features.Users;

public class ConfirmEmailHandler(
    UserManager<User> userManager,
    ApplicationContext context,
    IHashingService hashingService)
{
    public async Task<IResult> Handle(ConfirmEmailRequest request)
    {
        var user = await userManager.FindByEmailAsync(request.Email);
        
        if (user == null)
        {
            return Results.BadRequest(new { error = "User not found" });
        }

        if (user.EmailConfirmed)
        {
            return Results.BadRequest(new { error = "Email already confirmed" });
        }

        var now = DateTime.UtcNow;

        // Hash the provided code to compare with stored hash
        var hashedCode = hashingService.HashCode(request.Code);
        
        // Find valid, unused, non-expired token with matching hashed code
        var token = await context.EmailConfirmationTokens
            .Where(t => t.UserId == user.Id 
                     && !t.IsUsed 
                     && t.Code == hashedCode
                     && t.ExpiresAt > now)
            .OrderByDescending(t => t.CreatedAt)
            .FirstOrDefaultAsync();

        if (token == null)
        {
            return Results.BadRequest(new { error = "Invalid or expired verification code" });
        }

        // Mark token as used (persist it for audit trail)
        token.IsUsed = true;

        // Confirm user's email
        user.EmailConfirmed = true;
        await userManager.UpdateAsync(user);
        await context.SaveChangesAsync();

        return Results.Ok(new { message = "Email successfully verified" });
    }

    private bool VerifyCode(string providedCode, string hashedCode)
    {
        var hashedProvidedCode = hashingService.HashCode(providedCode);
        return hashedProvidedCode == hashedCode;
    }
}
