using Backend.Data;
using MediatR;
using Microsoft.AspNetCore.Identity;

namespace Backend.Features.Users;

public class AssignAdminRoleHandler(UserManager<User> userManager) : IRequestHandler<AssignAdminRoleRequest, IResult>
{
    public async Task<IResult> Handle(AssignAdminRoleRequest request, CancellationToken cancellationToken)
    {
        var user = await userManager.FindByIdAsync(request.UserId.ToString());
        
        if (user == null)
            return Results.NotFound(new { error = "User not found" });

        var isAlreadyAdmin = await userManager.IsInRoleAsync(user, "Admin");
        if (isAlreadyAdmin)
            return Results.BadRequest(new { error = "User is already an admin" });

        var result = await userManager.AddToRoleAsync(user, "Admin");
        
        if (!result.Succeeded)
            return Results.BadRequest(result.Errors);

        return Results.Ok(new { message = "Admin role assigned successfully", userId = user.Id });
    }
}

