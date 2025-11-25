using Backend.Persistence;
using Backend.Data;
using Backend.Features.Items.Enums;
using MediatR;

namespace Backend.Features.Items;

public class PostItemHandler : IRequestHandler<PostItemRequest, IResult>
{
    private readonly ApplicationContext _dbContext;
    public PostItemHandler(ApplicationContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IResult> Handle(PostItemRequest request, CancellationToken cancellationToken)
    {
        if (!Enum.TryParse<ItemCategory>(request.Item.Category, true, out var categoryEnum))
        {
            var validCategories = Enum.GetNames(typeof(ItemCategory));
            return Results.BadRequest(new 
            {
                Error = "Invalid Category value.", 
                Details = $"Category must be one of: {string.Join(", ", validCategories)}" 
            });
        }
        
        if (!Enum.TryParse<ItemCondition>(request.Item.Condition, true, out var conditionEnum))
        {
            var validConditions = Enum.GetNames(typeof(ItemCondition));
            return Results.BadRequest(new 
            {
                Error = "Invalid Condition value.", 
                Details = $"Condition must be one of: {string.Join(", ", validConditions)}" 
            });
        }
        var item = new Item
        {
            Id = Guid.NewGuid(),
            OwnerId = request.Item.OwnerId,
            Name = request.Item.Name,
            Description = request.Item.Description,
            Category = categoryEnum, 
            Condition = conditionEnum, 
            IsAvailable = true,
            CreatedAt = DateTime.UtcNow,
            ImageUrl = request.Item.ImageUrl,
        };

        _dbContext.Items.Add(item);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return Results.Created($"/items/{item.Id}", item);
    }
}