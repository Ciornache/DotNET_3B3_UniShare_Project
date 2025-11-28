using Backend.Data;
using Backend.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Backend.Validators;

public class EmailValidator : IUserValidator<User>
{
    private readonly ApplicationContext dbContext;

    public EmailValidator(ApplicationContext dbContext)
    {
        this.dbContext = dbContext;
    }

    public async Task<IdentityResult> ValidateAsync(UserManager<User> manager, User user)
    {
        var university = await dbContext.Universities
            .FirstOrDefaultAsync(u => u.Id == user.UniversityId);

        if (university == null || string.IsNullOrWhiteSpace(university.EmailDomain))
        {
            return IdentityResult.Failed(new IdentityError
            {
                Code = "InvalidUniversity",
                Description = "University or its email domain is invalid."
            });
        }

        if (string.IsNullOrEmpty(user.Email))
        {
            return IdentityResult.Failed(new IdentityError
            {
                Code = "InvalidEmail",
                Description = "Email cannot be null."
            });
        }

        string domain = university.EmailDomain.Split('@').Last();

        bool isValid = Regex.IsMatch(user.Email,
            $@"^[^@\s]+@(?:student\.)?{Regex.Escape(domain)}$");

        if (!isValid)
        {
            return IdentityResult.Failed(new IdentityError
            {
                Code = "InvalidEmailDomain",
                Description = $"Email must belong to the {domain} domain."
            });
        }

        return IdentityResult.Success;
    }
}