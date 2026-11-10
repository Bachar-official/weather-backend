// lib/service/router/weather_router.dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:weather_backend/service/cache/weather_cache.dart';

const _jsonHeaders = {'content-type': 'application/json'};

class WeatherRouter {
  final WeatherCache _cache;

  WeatherRouter(this._cache);

  Router get router {
    final r = Router();

    r.get('/weather', (Request req) {
      if (_cache.weather == null) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Weather data not ready'}),
        );
      }
      return Response.ok(
        jsonEncode(_cache.weather!.toMap()),
        headers: _jsonHeaders,
      );
    });

    r.get('/holidays', (Request req) {
      return Response.ok(
        jsonEncode(_cache.holidays.map((e) => e.toJson()).toList()),
        headers: _jsonHeaders,
      );
    });

    r.get('/geomagnetic', (Request req) {
      if (_cache.geomagnetic == null) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Geomagnetic data not ready'}),
        );
      }
      return Response.ok(
        jsonEncode(_cache.geomagnetic!.toJson()),
        headers: _jsonHeaders,
      );
    });

    r.get('/background', (Request req) {
      if (_cache.background == null) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Background not ready'}),
        );
      }
      return Response.ok(
        _cache.background!,
        headers: {'content-type': 'image/jpeg'},
      );
    });

    return r;
  }
}
