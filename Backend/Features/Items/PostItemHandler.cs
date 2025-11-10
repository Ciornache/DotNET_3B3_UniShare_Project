using Backend.Persistence;
using Backend.Data;

namespace Backend.Features.Items;


public class PostItemHandler(ApplicationContext dbContext)
{
    public async Task<IResult> Handle(PostItemRequest request)    
    {
        var item = new Item
        {
            Id = Guid.NewGuid(),
            OwnerId = request.OwnerId,
            Name = request.Name,
            Description = request.Description,
            Category = request.Category,
            Condition = request.Condition,
            IsAvailable = true,
            CreatedAt = DateTime.UtcNow,
            ImageUrl = request.ImageUrl
        };

        dbContext.Items.Add(item);
        await dbContext.SaveChangesAsync();

        return Results.Created($"/items/{item.Id}", item);
    }
}