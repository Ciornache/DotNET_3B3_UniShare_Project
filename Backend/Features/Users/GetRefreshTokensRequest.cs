using MediatR;

namespace Backend.Features.Users;

public record GetRefreshTokensRequest(Guid UserId) : IRequest<IResult>;
