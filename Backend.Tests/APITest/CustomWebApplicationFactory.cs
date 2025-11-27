using Backend.Persistence;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.VisualStudio.TestPlatform.TestHost;

namespace Backend.Tests.APITest;

/// <summary>
/// Custom WebApplicationFactory for integration tests.
/// Configures the test server with an in-memory database and other test-specific services.
/// </summary>
public class CustomWebApplicationFactory : WebApplicationFactory<Program>
{
    public CustomWebApplicationFactory()
    {
        // Use a consistent test environment
        Environment.SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", "Testing");
    }

    /// <summary>
    /// Configures the web host for testing by:
    /// - Using an in-memory database instead of the production database
    /// - Clearing existing database registrations
    /// </summary>
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");

        // Keep initial service setup minimal; main override happens in ConfigureTestServices
        builder.ConfigureServices(services =>
        {
            var descriptor = services.Where(d =>
                d.ServiceType == typeof(DbContextOptions<ApplicationContext>) ||
                d.ServiceType == typeof(ApplicationContext) ||
                d.ImplementationType == typeof(ApplicationContext)
            ).ToList();
            foreach (var d in descriptor)
            {
                services.Remove(d);
            }

            services.AddDbContext<ApplicationContext>(options =>
            {
                options.UseInMemoryDatabase("InMemoryDbForTesting");
            });

        });
    }
}