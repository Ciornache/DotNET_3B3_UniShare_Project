using Backend.Persistence;
using Microsoft.EntityFrameworkCore;
using MediatR;

namespace Backend.Features.Users;

public class GetAllUsersHandler(ApplicationContext dbContext) : IRequestHandler<GetAllUsersRequest, IResult>
{
    public async Task<IResult> Handle(GetAllUsersRequest request, CancellationToken cancellationToken)
    {
        var users = await dbContext.Users.AsNoTracking().ToListAsync(cancellationToken);
        return Results.Ok(users);
    }
}
