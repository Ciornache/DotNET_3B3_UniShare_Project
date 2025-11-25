using MediatR;
using Backend.Data;

namespace Backend.Features.Users;

public record GetUserRequest(Guid UserId) : IRequest<IResult>;
