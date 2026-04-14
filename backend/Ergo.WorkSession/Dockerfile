FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
USER app
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

COPY ["src/Ergo.WorkSession.API/Ergo.WorkSession.API.csproj", "src/Ergo.WorkSession.API/"]
COPY ["src/Ergo.WorkSession.Application/Ergo.WorkSession.Application.csproj", "src/Ergo.WorkSession.Application/"]
COPY ["src/Ergo.WorkSession.Domain/Ergo.WorkSession.Domain.csproj", "src/Ergo.WorkSession.Domain/"]
COPY ["src/Ergo.WorkSession.Infrastructure/Ergo.WorkSession.Infrastructure.csproj", "src/Ergo.WorkSession.Infrastructure/"]

RUN dotnet restore "src/Ergo.WorkSession.API/Ergo.WorkSession.API.csproj"

COPY . .

WORKDIR "/src/src/Ergo.WorkSession.API"
RUN dotnet build "Ergo.WorkSession.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "Ergo.WorkSession.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Ergo.WorkSession.API.dll"]