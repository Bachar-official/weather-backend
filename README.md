# Weather Backend

[![Dart](https://img.shields.io/badge/Dart-3.12+-00579D?logo=dart)](https://dart.dev)
[![Docker Ready](https://img.shields.io/badge/Docker-Ready-2CA5E0?logo=docker&logoColor=white)](https://www.docker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A high-performance, lightweight calendar and weather backend written in Dart. Designed to power dynamic frontend widgets, it aggregates real-time weather, local holidays, geomagnetic activity, and **AI-generated contextual backgrounds** tailored to the current conditions.

---

## Key Features

- **Real-time Weather**: Fetches detailed weather data (temperature, conditions, sunrise/sunset) via [WeatherAPI](https://www.weatherapi.com/).
- **Local Holidays**: Automatically scrapes and caches relevant national holidays from Wikipedia.
- **Geomagnetic Activity**: Tracks the Planetary K-index (Kp) via the [NOAA SWPC API](https://www.swpc.noaa.gov/).
- **AI-Generated Backgrounds**: Dynamically generates photorealistic cityscapes using the **Flux-1-schnell** model (via Cloudflare Workers). The prompt intelligently adapts to:
  - Time of day (sunrise, golden hour, deep night with starry skies).
  - Season and temperature (e.g., "wet asphalt" in autumn, "heavy snow" in winter).
  - Local holidays (e.g., New Year garlands, St. George ribbons).
  - Specific weather conditions (mapped via a robust internal enum).

---

## Architecture

The application is built with a clean, layered architecture:
1. **Cron-driven Caching**: An `UpdateService` periodically fetches fresh data in the background, ensuring instant response times for client requests.
2. **Shelf Router**: A lightweight, middleware-friendly HTTP server handles incoming requests.
3. **Smart Prompt Engineering**: The `build_weather_prompt` utility translates raw numeric weather codes and local time into highly optimized, natural-language English prompts for the AI image generator.

---

## Tech Stack

- **Language**: Dart (SDK ^3.12.2)
- **Server**: `shelf`, `shelf_router`, `shelf_cors_headers`
- **HTTP Client**: `dio`
- **Scheduling**: `cron`
- **Configuration**: `dotenv`
- **Logging**: `logger`
- **Deployment**: Docker

---

## Installation & Setup

1. Clone the repository:
```bash
git clone https://github.com/Bachar-official/weather-backend.git
cd weather-backend
```

2. Configure Environment variables: Create a `.env` file in the root directory based on `.env.example`
```env
# Your city here (Required)
CITY=Moscow
# Describe location of your city for image generation (optional)
AREA=Big city in the center of Russia
# Your language (tested on en and ru)
LOCALE=en
# Cloudflare credentials for image generation (optional)
CLOUDFLARE_ACCOUNT_ID=null
CLOUDFLARE_TOKEN=null
# WeatherAPI token here (required)
WEATHERAPI_TOKEN=token
# Temperature, pressure and wind speed (mertic or imperial)
UNITS=metric
# Port where backend lives
PORT=8080
# How often to request the weather (by default, every 15 minutes)
CRON_SCHEDULE=*/15 * * * *
```
> [!IMPORTANT]
> Ensure the PORT variable has no spaces or quotes (e.g., `PORT=8080`, not `PORT = 8080` or `PORT="8080"`), so Docker Compose can read it correctly for port mapping.

### Option A: Docker

This is the easiest way to run the backend. It handles AOT compilation, dependencies, and auto-restarts automatically.

#### 1. Build and run:
```bash
docker-compose up -d --build
```
*(Note: If you are using a newer Docker version, the command might be docker compose up -d --build without the hyphen).*

#### 2. Manage the Service:
- View logs: `docker-compose logs -f`
- Stop the service: `docker-compose stop`
- Update after git pull: `docker-compose up -d --build`
- Completely remove: `docker-compose down`

### Option B: Local Development (Native Dart)

> [!IMPORTANT]
> Please ensure you have Dart SDK installed.

If you want to run or develop the project locally without Docker:

### 1. Install dependencies
```bash
dart pub get
```

### 2. Running the Project in DEBUG mode
```bash
dart run bin/server.dart
```

### 3. Building executable
```bash
dart compile exe bin/server.dart
```

## API Endpoints
The API is fully documented with Swagger. Once the server is running, you can access the interactive documentation at:

```text
http://<your-host-ip>:<PORT>/swagger
```
*(Replace <PORT> with the value from your .env file, default is 8080).*

## Contributing
Contributions are welcome! If you'd like to add a new data source, improve the prompt engineering logic, or optimize the caching mechanism:
- Fork the repository.
- Create your feature branch (git checkout -b feature/AmazingFeature).
- Commit your changes (git commit -m 'Add some AmazingFeature').
- Push to the branch (git push origin feature/AmazingFeature).
- Open a Pull Request.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.