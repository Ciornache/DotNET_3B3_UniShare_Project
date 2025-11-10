using Backend.Persistence;

namespace Backend.Features.Items;

public class GetItemHandler(ApplicationContext dbContext)
{
    public async Task<IResult> Handle(GetItemRequest request)
    {
        var item= await dbContext.Items.FindAsync(request.Id);
        if (item == null) {
            return Results.NotFound();
        }
        return Results.Ok(item);
    }
}