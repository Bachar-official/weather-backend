import 'dart:typed_data';
import 'dart:convert';
import 'package:weather_backend/entity/entity.dart';

class WeatherCache {
  Weather? weather;
  List<Holiday> holidays = [];
  Geomagnetic? geomagnetic;
  Uint8List? background;

  int get backgroundVersion => background == null ? 0 : background.hashCode;

  bool get isReady => weather != null;

  /// Payload for WebSocket
  String buildUpdatePayload() {
    return jsonEncode({
      'type': 'update',
      'weather': weather?.toMap(),
      'holidays': holidays.map((e) => e.toJson()).toList(),
      'geomagnetic': geomagnetic?.toJson(),
      'backgroundHash': backgroundVersion,
    });
  }
}
