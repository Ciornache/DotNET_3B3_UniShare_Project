using Backend.Data;
using Backend.Features.Users;
using Backend.Validators;
using Microsoft.AspNetCore.Identity;
using Moq;

namespace Backend.Tests;

public class EmailValidatorTests
{
    [Fact]
    public void Given_When_Then()
    {
        var user = new User { Email = "myemail@email.com" };
        var userManager = GetMockUserManager();
        
        var validator = new EmailValidator();
        var result = validator.ValidateAsync(userManager,user);
        
        Assert.False(result.Result.Succeeded);
        Assert.Contains(result.Result.Errors, e => e.Code == "InvalidEmailDomain");
    }
    
    private UserManager<User> GetMockUserManager()
    {
        var store = new Mock<IUserStore<User>>();
        return new UserManager<User>(store.Object, null, null, null, null, null, null, null, null);
    }
}