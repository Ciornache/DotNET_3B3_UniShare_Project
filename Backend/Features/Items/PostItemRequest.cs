namespace Backend.Features.Items;

public record PostItemRequest(Guid OwnerId,string Name,string Description,string Category,string Condition,string?ImageUrl);