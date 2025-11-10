using Backend.Data;
using Backend.Persistence;
using Backend.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Backend.Features.Users;

public class SendEmailVerificationHandler(
    UserManager<User> userManager,
    ApplicationContext context,
    IEmailSender emailSender,
    IHashingService hashingService)
{
    public async Task<IResult> Handle(SendEmailVerificationRequest request)
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

        // Delete any existing unused tokens for this user
        var existingTokens = await context.EmailConfirmationTokens
            .Where(t => t.UserId == user.Id && !t.IsUsed)
            .ToListAsync();
        
        if (existingTokens.Any())
        {
            context.EmailConfirmationTokens.RemoveRange(existingTokens);
        }

        // Generate 6-digit verification code
        var code = new Random().Next(100000, 999999).ToString();

        // Hash the code before storing
        var hashedCode = hashingService.HashCode(code);

        // Create new verification token (5 minutes expiration)
        var verificationToken = new EmailConfirmationToken
        {
            UserId = user.Id,
            Code = hashedCode,
            ExpiresAt = DateTime.UtcNow.AddMinutes(5),
            IsUsed = false
        };

        context.EmailConfirmationTokens.Add(verificationToken);
        await context.SaveChangesAsync();

        // Send email with verification code (plain text - user needs to read it)
        var subject = "Email Verification Code - UniShare";
        var body = $@"Hello {user.FirstName},

Your email verification code is: {code}

This code will expire in 5 minutes.

If you didn't request this code, please ignore this email.

Best regards,
UniShare Team";

        try
        {
            await emailSender.SendEmailAsync(request.Email, subject, body);
            return Results.Ok(new { message = "Verification code sent to your email" });
        }
        catch (Exception ex)
        {
            return Results.Problem($"Failed to send email: {ex.Message}");
        }
    }
}
