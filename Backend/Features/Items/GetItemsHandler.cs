using Backend.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Backend.Features.Items;

public class GetItemsHandler(ApplicationContext dbContext)
{
    public async Task<IResult> Handle()    
    {
        var items = await dbContext.Items.ToListAsync();
        return Results.Ok(items);
    }
}