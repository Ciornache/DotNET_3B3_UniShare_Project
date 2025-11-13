using Backend.Data;
using Backend.Persistence;
using Backend.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using MediatR;

namespace Backend.Features.Users;

public class SendEmailVerificationHandler(
    UserManager<User> userManager,
    ApplicationContext context,
    IEmailSender emailSender,
    IHashingService hashingService) : IRequestHandler<SendEmailVerificationRequest, IResult>
{
    public async Task<IResult> Handle(SendEmailVerificationRequest request, CancellationToken cancellationToken)
    {
        var user = await userManager.FindByIdAsync(request.UserId.ToString());
        
        if (user == null)
            return Results.BadRequest(new { error = "User not found" });
        
        if (user.EmailConfirmed)
            return Results.BadRequest(new { error = "Email already confirmed" });

        var existingTokens = await context.EmailConfirmationTokens
            .Where(t => t.UserId == user.Id && !t.IsUsed)
            .ToListAsync(cancellationToken);
        
        if (existingTokens.Any())
            context.EmailConfirmationTokens.RemoveRange(existingTokens);
        
        var code = new Random().Next(100000, 999999).ToString();
        var hashedCode = hashingService.HashCode(code);
        var verificationToken = new EmailConfirmationToken
        {
            UserId = user.Id,
            Code = hashedCode,
            ExpiresAt = DateTime.UtcNow.AddMinutes(5),
            IsUsed = false
        };

        context.EmailConfirmationTokens.Add(verificationToken);
        await context.SaveChangesAsync(cancellationToken);

        var subject = "Email Verification Code - UniShare";
        var body = $@"Hello {user.FirstName},

                    Your email verification code is: {code}

                    This code will expire in 5 minutes.

                    If you didn't request this code, please ignore this email.

                    Best regards,
                    UniShare Team";

        try
        {
            await emailSender.SendEmailAsync(user.Email!, subject, body);
            return Results.Ok(new { message = "Verification code sent to your email" });
        }
        catch (Exception ex) {
            return Results.Problem($"Failed to send email: {ex.Message}");
        }
    }
}
