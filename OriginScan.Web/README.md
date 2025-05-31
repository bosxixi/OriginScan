# OriginScan Web

This is the web application for serving the OriginScan landing page.

## Prerequisites

- .NET 8.0 SDK or later
- Visual Studio 2022 or Visual Studio Code

## Getting Started

1. Clone the repository
2. Navigate to the OriginScan.Web directory
3. Run the following commands:

```bash
dotnet restore
dotnet build
dotnet run
```

The application will be available at:
- HTTP: http://localhost:5000
- HTTPS: https://localhost:5001

## Features

- Serves static files for the OriginScan landing page
- HTTPS support
- CORS enabled
- Development error pages in development environment

## Project Structure

- `wwwroot/` - Contains all static files (HTML, CSS, images)
- `Program.cs` - Main application entry point
- `appsettings.json` - Application configuration
- `Properties/launchSettings.json` - Launch configuration

## Deployment

To deploy the application:

1. Build the release version:
```bash
dotnet publish -c Release
```

2. The published files will be in the `bin/Release/net8.0/publish` directory

3. Deploy the contents of the publish directory to your web server 