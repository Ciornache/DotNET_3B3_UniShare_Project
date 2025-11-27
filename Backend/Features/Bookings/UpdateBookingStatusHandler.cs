using Backend.Persistence;
using MediatR;
using System.IdentityModel.Tokens.Jwt;
using Backend.Validators;
using FluentValidation.Results;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;

namespace Backend.Features.Bookings;


//TO DO: am impresia ca aveam nevoie de jwt pentru a valida userul care face update la booking status
//       validatorul trebuie sa verifice ca bookedul la care schimb statusul apartine userului respectiva
//       validatorul trebuie sa verifice ca statusul este unul valid (enum?)
public class UpdateBookingStatusHandler(ApplicationContext dbContext, ILogger<UpdateBookingStatusHandler> logger) : IRequestHandler<UpdateBookingStatusRequest, IResult>
{ 
    public async Task<IResult> Handle(UpdateBookingStatusRequest request, CancellationToken cancellationToken)
    {
        var dto = request.BookingStatusDto;
        var booking = await dbContext.Bookings
            .Include(b => b.Item)
            .FirstOrDefaultAsync(b => b.Id == request.BookingId, cancellationToken);

        booking.Status = dto.Status;
        if (dto.Status == "Approved") booking.ApprovedOn = DateTime.UtcNow;
        if (dto.Status == "Completed") booking.CompletedOn = DateTime.UtcNow;

        await dbContext.SaveChangesAsync(cancellationToken);

        logger.LogInformation("Booking with ID {BookingId} status updated to {NewStatus}.", request.BookingId, dto.Status);
        return Results.Ok(booking);
    }
}