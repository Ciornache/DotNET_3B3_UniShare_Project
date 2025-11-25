using Backend.Features.Items.DTO;
using Backend.Persistence;
using Microsoft.EntityFrameworkCore;
using MediatR;

namespace Backend.Features.Items;

public class GetAllUserItemsHandler : IRequestHandler<GetAllUserItemsRequest, IResult>
{
    private readonly ApplicationContext _dbContext;
    public GetAllUserItemsHandler(ApplicationContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IResult> Handle(GetAllUserItemsRequest request, CancellationToken cancellationToken)
    {
        var items = await _dbContext.Items
            .Include(i => i.Owner)
            .Where(item => item.OwnerId == request.UserId)
            .Select(i=> new ItemDto(
                i.Id,
                i.Name,
                i.Description,
                i.Category.ToString(),
                i.Condition.ToString(),
                i.IsAvailable,
                i.ImageUrl,
                i.Owner != null ? (i.Owner.FirstName + " " + i.Owner.LastName).Trim() : string.Empty
            )).ToListAsync(cancellationToken);
        return Results.Ok(items);
    }
}