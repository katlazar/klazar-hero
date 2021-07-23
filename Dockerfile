### .NET Core 3.1 ANGULAR APP Dockerfile ###

# Build Angular-Client
FROM node:erbium-alpine3.14 AS ang-client
RUN mkdir /app
WORKDIR /app
COPY ./Heroes-Angular/angular-tour-of-heroes/package.json ./
RUN npm install 
COPY /Heroes-Angular/angular-tour-of-heroes .
RUN npm run build --prod

# Build C#-Server 
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS cs-server
WORKDIR /src
COPY ./Heroes-Dotnet/HeroesApi  ./
RUN dotnet publish -c Release /p:EnvironmentName=Production -o dist

# Run Server and Client
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS final
LABEL author="k.lazar@dtpoland.com"
WORKDIR /server

COPY --from=ang-client /app/dist/angular-tour-of-heroes ./AngularApp
COPY --from=cs-server /src/dist/ .
COPY --from=cs-server /src/bin/Release/netcoreapp3.1/ .

EXPOSE 80
ENTRYPOINT ["dotnet", "HeroesApi.dll"]
