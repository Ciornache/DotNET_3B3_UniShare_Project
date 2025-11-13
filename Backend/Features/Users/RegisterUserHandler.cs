using Backend.Data;
using Microsoft.AspNetCore.Identity;
using MediatR;

namespace Backend.Features.Users;

public class RegisterUserHandler(
    UserManager<User> userManager,
    IMediator mediator) : IRequestHandler<RegisterUserRequest, IResult>
{
    public async Task<IResult> Handle(RegisterUserRequest request, CancellationToken cancellationToken)
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
        
        await mediator.Send(new SendEmailVerificationRequest(user.Id), cancellationToken);
        return Results.Ok(new {message = "User registered successfully. Please verify your email."});
        
    }
}