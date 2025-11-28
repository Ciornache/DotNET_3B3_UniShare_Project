using AutoMapper;
using Backend.Data;
using Backend.Features.Users.Dtos;
using Backend.Persistence;
using Microsoft.AspNetCore.Identity;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Backend.Features.Users;

public class RegisterUserHandler(
    UserManager<User> userManager,
    IMediator mediator,
    IMapper mapper,
    ApplicationContext dbContext
) : IRequestHandler<RegisterUserRequest, IResult>
{
    public async Task<IResult> Handle(RegisterUserRequest request, CancellationToken cancellationToken)
    {
        var dto = request.RegisterUserDto;

        // verificăm dacă universitatea există
        var university = await dbContext.Universities
            .FirstOrDefaultAsync(u => u.Id == dto.UniversityId, cancellationToken);

        if (university == null)
        {
            return Results.BadRequest(new {
                message = "Invalid university ID."
            });
        }

        // mapăm DTO → User
        var user = mapper.Map<User>(dto);

        // Creăm utilizatorul
        var result = await userManager.CreateAsync(user, dto.Password);

        if (!result.Succeeded)
        {
            return Results.BadRequest(result.Errors);
        }

        // Trimitem email verificare
        await mediator.Send(new SendEmailVerificationRequest(user.Id), cancellationToken);

        var userDto = mapper.Map<UserDto>(user);

        return Results.Created($"/api/users/{user.Id}", new {
            message = "User registered successfully. Please verify your email.",
            entity = userDto
        });
    }
}