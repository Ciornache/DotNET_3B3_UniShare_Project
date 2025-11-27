using Backend.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Backend.Features.Bookings;

public class GetUserBookingsHandler(ApplicationContext dbContext) : IRequestHandler<GetUserBookingsRequest, IResult>
{
    public Task<IResult> Handle(GetUserBookingsRequest request, CancellationToken cancellationToken)
    {
        var bookings = dbContext.Bookings
            .Where(b => b.BorrowerId == request.UserId)
            .ToListAsync(cancellationToken);
        
        return bookings.ContinueWith(task => Results.Ok(task.Result), cancellationToken);
    }
}