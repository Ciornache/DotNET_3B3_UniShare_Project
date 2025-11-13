using MediatR;

namespace Backend.Features.Users;

public record RegisterUserRequest(string Email, string FirstName, string LastName, string Password) : IRequest<IResult>;
