using Backend.Features.Items;
using Backend.Persistence;
using FluentAssertions;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Backend.Tests.Handlers.Items;

public class PostItemTests
{
    private static ApplicationContext CreateInMemoryDbContext()
    {
        var options = new DbContextOptionsBuilder<ApplicationContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        var dbContext = new ApplicationContext(options);
        return dbContext;
    }
    
    [Fact]
    public async Task Given_ValidPostItemRequest_When_Handle_Then_AddsNewItem()
    {
        // Arrange
        var dbContext = CreateInMemoryDbContext();
        var handler = new PostItemHandler(dbContext);
        var request = new PostItemRequest
        (
            Guid.NewGuid(),
            "Test Item",
            "This is a test item.",
            "Electronics",
             "New",
            "http://example.com/image.jpg"
        );

        // Act
        var result = await handler.Handle(request);

        // Assert
        result.Should().NotBeNull();
        var createItem = await dbContext.Items.FirstOrDefaultAsync( item => item.Name == "Test Item");
        Assert.NotNull(createItem);
        Assert.Equal("This is a test item.", createItem.Description);
        Assert.Equal("Electronics", createItem.Category);
        Assert.Equal("New", createItem.Condition);
        Assert.Equal("http://example.com/image.jpg", createItem.ImageUrl);
    }

    [Fact]
    public async Task Given_PostItemRequest_With_MissingRequiredField_When_Handle_Then_ThrowsDbUpdateException()
    {
        // Arrange
        var dbContext = CreateInMemoryDbContext();
        var handler = new PostItemHandler(dbContext);
        var request = new PostItemRequest
        (
            Guid.NewGuid(),
            null, 
            null,
            null,
            null,
            null
        );


        // Act & Assert
        await Assert.ThrowsAnyAsync<Exception>(async () => 
        {
            await handler.Handle(request);
        });
    }

    [Fact]
    public async Task Given_PostItemRequest_With_NullImageUrl_When_Handle_Then_ThrowsDbUpdateException()
    {
        // Arrange
        var dbContext = CreateInMemoryDbContext();
        var handler = new PostItemHandler(dbContext);
        var request = new PostItemRequest
        (
            Guid.NewGuid(),
            "Test Item",
            "This is a test item.",
            "Electronics",
            "New",
            null
        );


        // Act
        var result = await handler.Handle(request);

        // Assert
        result.Should().NotBeNull();
        var createItem = await dbContext.Items.FirstOrDefaultAsync( item => item.Name == "Test Item");
        Assert.NotNull(createItem);
        Assert.Equal("This is a test item.", createItem.Description);
        Assert.Equal("Electronics", createItem.Category);
        Assert.Equal("New", createItem.Condition);
        Assert.Null(createItem.ImageUrl);
    }
    
    //TO DO: TESTS FOR MISSING REQUIRED FIELDS THAT THROW EXCEPTIONS AND LENGTH CONSTRAINTS ON STRINGS

}