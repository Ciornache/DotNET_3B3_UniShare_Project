using Backend.Features.Bookings.Enums;

namespace Backend.Features.Bookings.DTO;

public record UpdateBookingStatusDto(Guid UserId, BookingStatus BookingStatus);
