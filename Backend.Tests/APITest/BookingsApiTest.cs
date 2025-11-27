namespace Backend.Tests.APITest;

public class BookingsApiTest(CustomWebApplicationFactory factory) : IClassFixture<CustomWebApplicationFactory>
{
    private readonly HttpClient client = factory.CreateClient();

    [Fact]
    public async Task GetAllBookings_ReturnsSuccessStatusCode()
    {
        // Arrange
        var request = new HttpRequestMessage(HttpMethod.Get, "/bookings");
        // Act
        var response = await client.SendAsync(request);
        // Assert
        response.EnsureSuccessStatusCode();
    }

    [Fact]
    public async Task GetAllBookings_ReturnsJsonArray()
    {
        // Arrange
        var request = new HttpRequestMessage(HttpMethod.Get, "/bookings");
        // Act
        var response = await client.SendAsync(request);
        // Assert
        response.EnsureSuccessStatusCode();
        var contentType = response.Content.Headers.ContentType?.MediaType;
        Assert.True(contentType != null && contentType.StartsWith("application/json"), $"Unexpected content type: {contentType}");
        var content = await response.Content.ReadAsStringAsync();
        Assert.NotNull(content);
        Assert.True(content.TrimStart().StartsWith("["), "Expected JSON array response for /bookings");
    }
}

