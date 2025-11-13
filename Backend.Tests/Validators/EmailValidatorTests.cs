using Backend.Data;
using Backend.Features.Users;
using Backend.Validators;
using Microsoft.AspNetCore.Identity;
using Moq;

namespace Backend.Tests;

public class EmailValidatorTests
{
    [Fact]
    public async Task Given_ValidEmailDomain_When_ValidatingEmail_Then_Success()
    {
        var user = new User { Email = "myemail@student.uaic.ro" };
        var userManager = GetMockUserManager();
        
        var validator = new EmailValidator();
        var result = await validator.ValidateAsync(userManager,user);
        
        Assert.True(result.Succeeded);
    }

    [Fact]
    public async Task Given_InvalidEmailDomain_When_ValidatingEmail_Then_InvalidEmailDomainError()
    {
        var user = new User { Email = "myemail@email.com" };
        var userManager = GetMockUserManager();
        
        var validator = new EmailValidator();
        var result = await validator.ValidateAsync(userManager,user);
        
        Assert.False(result.Succeeded);
        Assert.Contains(result.Errors, e => e.Code == "InvalidEmailDomain");
    }
    
    [Fact]
    public async Task Given_NullEmail_When_ValidatingEmail_Then_InvalidEmailError()
    {
        var user = new User { Email = null };
        var userManager = GetMockUserManager();
        
        var validator = new EmailValidator();
        var result = await validator.ValidateAsync(userManager,user);
        
        Assert.False(result.Succeeded);
        Assert.Contains(result.Errors, e => e.Code == "InvalidEmail");
    }
    
    private static UserManager<User> GetMockUserManager()
    {
        var store = new Mock<IUserStore<User>>();
        return new UserManager<User>(store.Object, null, null, null, null, null, null, null, null);
    }
}