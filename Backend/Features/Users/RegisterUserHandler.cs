using AutoMapper;
using Backend.Data;
using Backend.Features.Users.Dtos;
using Microsoft.AspNetCore.Identity;
using MediatR;

namespace Backend.Features.Users;

public class RegisterUserHandler(
    UserManager<User> userManager,
    IMediator mediator,
    IMapper mapper) : IRequestHandler<RegisterUserRequest, IResult>
{
    public async Task<IResult> Handle(RegisterUserRequest request, CancellationToken cancellationToken)
    {
        RegisterUserDto registerUserDto = request.RegisterUserDto;
        var user = mapper.Map<User>(registerUserDto);
        Console.WriteLine(user);
        
        var result = await userManager.CreateAsync(user, registerUserDto.Password);
        
        if (!result.Succeeded)
        {
            return Results.BadRequest(result.Errors);
        }
        
        await mediator.Send(new SendEmailVerificationRequest(user.Id), cancellationToken);
        
        var userDto = mapper.Map<UserDto>(user);
        
        return Results.Created($"/api/users/{user.Id}", new {
            message = "User registered successfully. Please verify your email.",
            entity = userDto
        });

    }
}