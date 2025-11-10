using Microsoft.AspNetCore.Identity;
using Backend.Data;

namespace Backend.Features.Users;

public class GetUserHandler(UserManager<User> userManager)
{
    public async Task<IResult> Handle(GetUserByEmailRequest request)
    {
        var user = await userManager.FindByEmailAsync(request.Email);
        
        if (user == null) {
            return Results.NotFound();
        }
        
        return Results.Ok(user);
    }
}