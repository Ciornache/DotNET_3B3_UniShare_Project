using Backend.Features.Users.Dtos;
using Backend.Persistence;
using Microsoft.AspNetCore.Identity;
using Backend.Data;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Backend.Features.Users;

public class GetUserHandler(ApplicationContext context) : IRequestHandler<GetUserRequest, IResult>
{
    public async Task<IResult> Handle(GetUserRequest request, CancellationToken cancellationToken)
    {
        var user = await context.Users
            .Include(u => u.University)
            .Include(u => u.Items)
            .FirstOrDefaultAsync(u => u.Id == request.UserId, cancellationToken);

        if (user == null)
        {
            return Results.NotFound();
        }

        var userDto = new UserDto
        {
            FirstName = user.FirstName,
            LastName = user.LastName,
            UniversityName = user.University?.Name ?? "N/A",
            Items = user.Items?.Select(i => i.Name).ToList() ?? new List<string>()
        };

        return Results.Ok(userDto);
    }
}