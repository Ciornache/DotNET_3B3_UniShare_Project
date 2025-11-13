using MediatR;

namespace Backend.Features.Users;

public record SendEmailVerificationRequest(Guid UserId) : IRequest<IResult>;
