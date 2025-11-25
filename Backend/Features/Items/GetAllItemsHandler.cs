using Backend.Features.Items.DTO;
using Backend.Persistence;
using Microsoft.EntityFrameworkCore;
using MediatR;

namespace Backend.Features.Items;

public class GetAllItemsHandler : IRequestHandler<GetAllItemsRequest, IResult>
{
    private readonly ApplicationContext _dbContext;
    public GetAllItemsHandler(ApplicationContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IResult> Handle(GetAllItemsRequest request, CancellationToken cancellationToken)
    {
        var items = await _dbContext.Items
            .Include(i => i.Owner) 
            .Select(i => new ItemDto(
                i.Id,
                i.Name,
                i.Description,
                i.Category.ToString(), 
                i.Condition.ToString(), 
                i.IsAvailable,
                i.ImageUrl, 
                i.Owner != null ? (i.Owner.FirstName + " " + i.Owner.LastName).Trim() : string.Empty
            ))
            .ToListAsync(cancellationToken);
        return Results.Ok(items);
    }
}