# Get build image
FROM mcr.microsoft.com/dotnet/sdk:5.0@sha256:bce1e40a24da092c31513337a39a1b9f923e32884a57dd71cbe4c2f8d1f4b067 AS build
WORKDIR /app

# Copy source
COPY . ./

# Bring in metadata via --build-arg for build
ARG IMAGE_VERSION=unknown

# Restore packages
RUN dotnet restore

# Add SQLite migration
RUN export PATH="$PATH:/root/.dotnet/tools" && \
    dotnet tool install --global dotnet-ef && \
    dotnet ef migrations add ${IMAGE_VERSION} --project src/GRA.Data.SQLite/GRA.Data.SQLite.csproj

# Build project and run tests
RUN dotnet test

# Publish release project
RUN dotnet publish -c Release -o "/app/publish/"

# Copy release-publish.bash script
RUN cp /app/release-publish.bash "/app/publish/"

# Get runtime image
FROM mcr.microsoft.com/dotnet/aspnet:5.0@sha256:8bc0d840eff650cef285d28c3503e7bb87cd92828ac42ad24a1396dd5870d49d AS publish
WORKDIR /app

# Install curl for health monitoring
RUN apt-get update \
	&& apt-get install --no-install-recommends -y curl=7.64.0-4+deb10u2 \
	&& rm -rf /var/lib/apt/lists/*

# Bring in metadata via --build-arg to publish
ARG BRANCH=unknown
ARG IMAGE_CREATED=unknown
ARG IMAGE_REVISION=unknown
ARG IMAGE_VERSION=unknown

# Configure image labels
LABEL branch=$branch \
    maintainer="Maricopa County Library District developers <development@mcldaz.org>" \
    org.opencontainers.image.authors="Maricopa County Library District developers <development@mcldaz.org>" \
    org.opencontainers.image.created=$IMAGE_CREATED \
    org.opencontainers.image.description="The Great Reading Adventure open-source tool for managing dynamic library reading programs" \
    org.opencontainers.image.documentation="http://manual.greatreadingadventure.com/" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.revision=$IMAGE_REVISION \
    org.opencontainers.image.source="https://github.com/MCLD/greatreadingadventure" \
    org.opencontainers.image.title="Great Reading Adventure" \
    org.opencontainers.image.url="http://greatreadingadventure.com/" \
    org.opencontainers.image.vendor="Maricopa County Library District" \
    org.opencontainers.image.version=$IMAGE_VERSION

# Default image environment variable settings
ENV org.opencontainers.image.created=$IMAGE_CREATED \
    org.opencontainers.image.revision=$IMAGE_REVISION \
    org.opencontainers.image.version=$IMAGE_VERSION

# Copy source
COPY --from=build "/app/publish/" .

# Persist shared directory
VOLUME ["/app/shared"]

# Port 80 for http
EXPOSE 80

# Configure health check
HEALTHCHECK CMD curl --fail http://localhost/health/ || exit

# Set entrypoint
ENTRYPOINT ["dotnet", "GRA.Web.dll"]
