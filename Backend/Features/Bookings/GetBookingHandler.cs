using Backend.Persistence;
using MediatR;

namespace Backend.Features.Booking;

public class GetBookingHandler(ApplicationContext dbContext, ILogger<GetBookingHandler> logger) : IRequestHandler<GetBookingRequest, IResult>
{
    public async Task<IResult> Handle(GetBookingRequest request, CancellationToken cancellationToken)
    {
        var booking = dbContext.Bookings.FindAsync(request.BookingId);
        if (booking == null)
        {
            logger.LogError("Booking with ID {BookingId} not found.", request.BookingId);
            return Results.NotFound();
        }
        
        logger.LogInformation("Booking with ID {BookingId} was found.", request.BookingId);
        return Results.Ok(booking);
    }
}