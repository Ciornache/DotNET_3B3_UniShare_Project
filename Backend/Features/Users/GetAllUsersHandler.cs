using Backend.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Backend.Features.Users;

public class GetAllUsersHandler(ApplicationContext dbContext)
{
    public async Task<IResult> Handle(GetAllUsersRequest request)
    {
        var users = await dbContext.Users.AsNoTracking().ToListAsync();
        return Results.Ok(users);
    }
}
