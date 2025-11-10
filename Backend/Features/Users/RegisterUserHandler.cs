using Backend.Persistence;
using Backend.Data;
using Backend.Services;
using Microsoft.AspNetCore.Identity;

namespace Backend.Features.Users;

public class RegisterUserHandler(
    UserManager<User> userManager,
    ApplicationContext context,
    IEmailSender emailSender,
    IHashingService hashingService)
{
    public async Task<IResult> Handle(RegisterUserRequest request)
    {
        var user = new User()
        {
            Email = request.Email,
            UserName = request.Email,
            FirstName = request.FirstName,
            LastName = request.LastName,
            CreatedAt = DateTime.UtcNow
        };
        
        var result = await userManager.CreateAsync(user, request.Password);
        
        if (!result.Succeeded)
        {
            return Results.BadRequest(result.Errors);
        }

        // Automatically send verification email after successful registration
        try
        {
            // Generate 6-digit verification code
            var code = new Random().Next(100000, 999999).ToString();

            // Hash the code before storing
            var hashedCode = hashingService.HashCode(code);

            // Create verification token (5 minutes expiration)
            var verificationToken = new EmailConfirmationToken
            {
                UserId = user.Id,
                Code = hashedCode,
                ExpiresAt = DateTime.UtcNow.AddMinutes(5),
                IsUsed = false
            };

            context.EmailConfirmationTokens.Add(verificationToken);
            await context.SaveChangesAsync();

            // Send email with verification code
            var subject = "Welcome to UniShare - Verify Your Email";
            var body = $@"Hello {user.FirstName},

Welcome to UniShare! Your email verification code is: {code}

This code will expire in 5 minutes.

Please use the /auth/confirm-email endpoint to verify your email address.

Best regards,
UniShare Team";

            await emailSender.SendEmailAsync(request.Email, subject, body);

            return Results.Created($"/Users/{user.Id}", new
            {
                user.Id,
                user.Email,
                user.FirstName,
                user.LastName,
                message = "Registration successful. Please check your email for the verification code."
            });
        }
        catch (Exception ex)
        {
            // User is created but email failed - they can request a new code later
            return Results.Created($"/Users/{user.Id}", new
            {
                user.Id,
                user.Email,
                user.FirstName,
                user.LastName,
                message = "Registration successful but failed to send verification email. Please use /auth/send-verification-code to resend.",
                error = ex.Message
            });
        }
    }
}