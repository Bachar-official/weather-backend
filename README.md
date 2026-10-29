# Weather Backend

[![Dart](https://img.shields.io/badge/Dart-3.12+-00579D?logo=dart)](https://dart.dev)
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
- **Deployment**: Docker (not tested yet)

---

## Installation & Setup

### 1. Clone the repository
```bash
git clone https://github.com/Bachar-official/weather-backend.git
cd weather-backend
```

### 2. Configure Environment variables

Create a `.env` file in the root directory based on `.env.example`:
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

### 3. Install dependencies
```bash
dart pub get
```

## Running the Project
```bash
dart run bin/server.dart
```

## Building executable
```bash
dart compile exe bin/server.dart
```

## API Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /weather | Returns current weather data |
| GET | /holidays | Returns a list of today's holidays |
| GET | /geomagnetic | Returns the current NOAA Planetary K-index data |
| GET | /background | Returns a dynamically generated image/jpeg background. (Returns 403 if Cloudflare features are disabled).

## Contributing
Contributions are welcome! If you'd like to add a new data source, improve the prompt engineering logic, or optimize the caching mechanism:
- Fork the repository.
- Create your feature branch (git checkout -b feature/AmazingFeature).
- Commit your changes (git commit -m 'Add some AmazingFeature').
- Push to the branch (git push origin feature/AmazingFeature).
- Open a Pull Request.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.