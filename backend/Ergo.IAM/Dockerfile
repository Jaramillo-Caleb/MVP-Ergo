FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

COPY ["src/Ergo.IAM.Api/Ergo.IAM.Api.csproj", "src/Ergo.IAM.Api/"]
COPY ["src/Ergo.IAM.Core/Ergo.IAM.Core.csproj", "src/Ergo.IAM.Core/"]
COPY ["src/Ergo.IAM.Infrastructure/Ergo.IAM.Infrastructure.csproj", "src/Ergo.IAM.Infrastructure/"]
RUN dotnet restore "src/Ergo.IAM.Api/Ergo.IAM.Api.csproj"

COPY . .
WORKDIR "/app/src/Ergo.IAM.Api"
RUN dotnet publish "Ergo.IAM.Api.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

RUN apt-get update && apt-get install -y libsqlite3-dev && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/publish .

RUN mkdir -p /app/data

EXPOSE 8080
ENTRYPOINT ["dotnet", "Ergo.IAM.Api.dll"]