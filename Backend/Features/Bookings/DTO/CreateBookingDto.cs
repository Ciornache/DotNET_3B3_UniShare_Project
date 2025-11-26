namespace Backend.Features.Booking.DTO;

public record CreateBookingDto
    (
    Guid Id,
    Guid ItemId,
    Guid BorrowerId,
    DateTime RequestedOn,
    DateTime StartDate,
    DateTime EndDate
);