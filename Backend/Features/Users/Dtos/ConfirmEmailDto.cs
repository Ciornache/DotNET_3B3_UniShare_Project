namespace Backend.Features.Users.Dtos;

public record ConfirmEmailDto(Guid UserId, string Code);

