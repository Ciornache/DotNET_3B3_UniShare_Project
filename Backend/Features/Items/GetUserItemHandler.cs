using Backend.Features.Items.DTO;
using Backend.Persistence;
using Microsoft.EntityFrameworkCore;
using MediatR;

namespace Backend.Features.Items;

public class GetUserItemHandler : IRequestHandler<GetUserItemRequest, IResult>
{
    private readonly ApplicationContext _dbContext;
    public GetUserItemHandler(ApplicationContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IResult> Handle(GetUserItemRequest request, CancellationToken cancellationToken)
    {
        var item = await _dbContext.Items
            .Include(i => i.Owner)
            .Where(i => i.Id == request.ItemId && i.OwnerId == request.UserId)
            .Select(i=>new ItemDto(
                i.Id,
                i.Name,
                i.Description,
                i.Category.ToString(),
                i.Condition.ToString(),
                i.IsAvailable,
                i.ImageUrl,
                i.Owner != null ? (i.Owner.FirstName + " " + i.Owner.LastName).Trim() : string.Empty
            ))
            .FirstOrDefaultAsync(cancellationToken);

        if (item == null)
        {
            return Results.NotFound();
        }

        return Results.Ok(item);
    }
}