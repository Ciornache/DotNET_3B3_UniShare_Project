using Backend.Features.Items;
using Backend.Persistence;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Backend.Features.Booking;

public class GetAllBookingsHandler(ApplicationContext dbContext) : IRequestHandler<GetAllItemsRequest, IResult>
{
    public async Task<IResult> Handle(GetAllItemsRequest request, CancellationToken cancellationToken)
    {
        var bookings = await dbContext.Bookings.ToListAsync(cancellationToken);
        return Results.Ok(bookings);
    }
}