using MediatR;
using Backend.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Backend.Features.Items;

public class DeleteItemHandler : IRequestHandler<DeleteItemRequest, IResult>
{
    private readonly ApplicationContext _dbContext;
    public DeleteItemHandler(ApplicationContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IResult> Handle(DeleteItemRequest request, CancellationToken cancellationToken)
    {
        var item = await _dbContext.Items.FirstOrDefaultAsync(i => i.Id == request.Id, cancellationToken);
        if (item == null)
        {
            return Results.NotFound();
        }

        _dbContext.Items.Remove(item);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return Results.NoContent();
    }
}