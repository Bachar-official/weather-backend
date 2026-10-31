# Use latest stable channel SDK.
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code (except anything in .dockerignore) and AOT compile app.
COPY . .
RUN dart compile exe bin/server.dart -o server

# Run stage
FROM debian:bookworm-slim

# Install root sertificates
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy compiled server from build stage
COPY --from=build /app/server /app/server
COPY --from=build /app/docs /app/docs

EXPOSE 8080

CMD ["/app/server"]