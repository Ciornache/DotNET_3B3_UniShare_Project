namespace Backend.Validators;
using Backend.Data;
using Microsoft.AspNetCore.Identity;

public class EmailValidator : IUserValidator<User>
{
    public Task<IdentityResult> ValidateAsync(UserManager<User> manager, User user)  {
        if (user.Email != null) {
            bool isValid = System.Text.RegularExpressions.Regex.IsMatch(user.Email,
                @"^[^@\s]+@student.uaic.ro$",
                System.Text.RegularExpressions.RegexOptions.IgnoreCase);
            if (isValid) {
                return Task.FromResult(IdentityResult.Success);
            }

            return Task.FromResult(IdentityResult.Failed(new IdentityError
            {
                Code = "InvalidEmailDomain",
                Description = "Email must belong to the student.uaic.ro domain."
            }));
        }
        return Task.FromResult(IdentityResult.Failed(new IdentityError()
        {
            Code = "InvalidEmail",
            Description = "Email cannot be null."
        }));
    }
}