using MediatR;

namespace Backend.Features.Users;

public record RefreshTokenRequest(string RefreshToken) : IRequest<IResult>;
