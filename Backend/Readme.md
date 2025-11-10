UniShare Backend
===============

This README explains how to run the UniShare Backend, how to run the database (PostgreSQL), which packages the project depends on, and the common commands to prepare and start the application on Windows (cmd.exe).

Project overview
----------------
- Project: Backend (ASP.NET Core Web API targeting .NET 9)
- DbContext: `Backend.Persistence.ApplicationContext`
- Database provider: PostgreSQL (Npgsql)
- Swagger is configured for API exploration in development

Required NuGet packages (from `Backend.csproj`)
----------------------------------------------
The project currently references the following relevant packages:
- Aspire.Hosting.PostgreSQL (v9.5.2)
- Microsoft.AspNetCore.OpenApi (v9.0.9)
- Microsoft.EntityFrameworkCore (v9.0.10)
- Microsoft.EntityFrameworkCore.Tools (v9.0.10) - development toolset
- Npgsql.EntityFrameworkCore.PostgreSQL (v9.0.4)
- Swashbuckle.AspNetCore (v9.0.6)

These packages are declared in `Backend.csproj` and will be restored automatically by `dotnet restore`.

Configuration (connection string)
---------------------------------
The default connection string is in `appsettings.json`:

Host=localhost;Database=UniShare;Username=postgres;Password=admin

You can either use this default (if you run PostgreSQL with these credentials) or update the connection string in `appsettings.json` or provide a different configuration for your environment (for example via environment variables or user secrets).

Run PostgreSQL (two options)
----------------------------

Install PostgreSQL (for example from https://www.postgresql.org/download/), then create a database and user that match your connection string or update `appsettings.json` accordingly from pgAdmin.

Applying EF Core migrations (create or update database schema)
-------------------------------------------------------------
The repository contains migrations under the `Migrations/` folder.

1) Install dotnet-ef (if not already installed):

```cmd
dotnet tool install --global dotnet-ef
```

2) From the `Backend` project directory, restore packages and apply migrations:

```cmd
cd "Project\Backend"
dotnet restore
dotnet ef database update
```

This will run the migrations and create/update the database schema in the PostgreSQL instance defined by your connection string.

If you add new migrations during development:

```cmd
dotnet ef migrations add InitialCreate
dotnet ef database update
```

Notes and troubleshooting
------------------------
- If the database update fails with a connection error, verify PostgreSQL is running and the connection string matches the server host/port and credentials.
- If using Docker on Windows and port 5432 is already taken, change the host port mapping (for example `-p 5433:5432`) and update your connection string Host=localhost;Port=5433;...
- If you see EF or runtime errors related to your `ApplicationContext` or model classes, ensure your code compiles (`dotnet build`) and that migrations are up-to-date.

Useful commands summary
-----------------------
- Restore packages: `dotnet restore`
- Build project: `dotnet build`
- Run app: `dotnet run`
- Apply migrations: `dotnet ef database update`
- Add migration: `dotnet ef migrations add YourName`

Where to look next
------------------
- `appsettings.json` — current connection string
- `Persistence/ApplicationContext.cs` — EF DbContext and DbSet definitions
- `Migrations/` — existing EF Core migrations

