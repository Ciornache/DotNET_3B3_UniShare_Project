namespace Backend.Features.Users;

public record ConfirmEmailRequest(string Email, string Code);

