using Backend.Persistence;

namespace Backend.Features.Items;

public class DeleteItemHandler(ApplicationContext dbContext)
{
    public async Task<IResult> Handle(DeleteItemRequest request)    
    {
        var item = await dbContext.Items.FindAsync(request.Id);
        if (item == null)
        {
            return Results.NotFound();
        }

        dbContext.Items.Remove(item);
        await dbContext.SaveChangesAsync();

        return Results.NoContent();
    }
}