using MediatR;

namespace Backend.Features.Users;

public record AssignAdminRoleRequest(Guid UserId) : IRequest<IResult>;

