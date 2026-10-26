import 'dart:convert';
import 'dart:typed_data';

import 'package:cron/cron.dart';
import 'package:logger/web.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:weather_backend/entity/entity.dart';
import 'package:weather_backend/utils/build_weather_prompt.dart';
import 'package:weather_backend/utils/utils.dart';
import 'net_repo.dart';

const jsonHeaders = {'content-type': 'application/json'};

class UpdateService {
  final Environment environment;
  late final Router router;
  late Cron cron;
  late Uint8List? background;
  late Weather? weather;
  final NetRepo netRepo;
  final Logger logger;
  late List<Holiday> holidays;
  late Geomagnetic? geomagnetic;

  UpdateService({
    required this.environment,
    required this.netRepo,
    required this.logger,
  }) {
    cron = Cron();
    background = null;
    weather = null;
    geomagnetic = null;
    holidays = [];
    router = Router()
      ..get('/weather', _weatherHandler)
      ..get('/holidays', _holidaysHandler)
      ..get('/geomagnetic', _geomagneticHandler)
      ..get('/background', _backgroundHandler);

    _init();

    // Requesting weather according to env
    cron.schedule(Schedule.parse(environment.cronSchedule), () async {
      await Future.wait([updateWeather(), updateGeomagnetic()]);
      if (environment.isCloudflareFeaturesEnabled) {
        await updateBackround();
      }
    });

    // Requesting holidays every midnight
    cron.schedule(Schedule.parse('0 0 * * *'), () async {
      await updateHolidays();
    });
  }

  Future<void> _init() async {
    await Future.wait([updateHolidays(), updateWeather(), updateGeomagnetic()]);
    if (environment.isCloudflareFeaturesEnabled) {
      await updateBackround();
    }
  }

  Response _weatherHandler(Request request) {
    if (weather == null) {
      return Response.internalServerError(body: {'Error': 'Weather is null'});
    }
    return Response.ok(jsonEncode(weather!.toMap()), headers: jsonHeaders);
  }

  Response _holidaysHandler(Request request) {
    return Response.ok(
      jsonEncode(holidays.map((e) => e.toJson()).toList()),
      headers: jsonHeaders,
    );
  }

  Response _geomagneticHandler(Request request) {
    if (geomagnetic == null) {
      return Response.internalServerError(
        body: {'Error': 'Geomagnetic is null'},
      );
    }
    return Response.ok(jsonEncode(geomagnetic!.toJson()), headers: jsonHeaders);
  }

  Response _backgroundHandler(Request request) {
    if (background == null) {
      return Response.internalServerError(
        body: {'Error': 'Background is null'},
      );
    }
    return Response.ok(background!, headers: {'Content-type': 'image/jpeg'});
  }

  Future<void> updateWeather() async {
    logger.d('Trying to update weather');
    try {
      final newWeather = await netRepo.getWeather();
      logger.i('Got new weather: $newWeather');
      weather = newWeather;
    } catch (e, s) {
      logger.e('Error while updating weather', error: e, stackTrace: s);
    }
  }

  Future<void> updateHolidays() async {
    logger.d('Trying to update holidays');
    try {
      final newHolidays = await netRepo.getHolidays();
      logger.i('Got ${newHolidays.length} new holidays');
      holidays = newHolidays;
    } catch (e, s) {
      logger.e('Error while updating holidays', error: e, stackTrace: s);
    }
  }

  Future<void> updateGeomagnetic() async {
    logger.d('Trying to update geomagnetic');
    try {
      final newGeomagnetic = await netRepo.getGeomagnetic();
      logger.i('Got new geomagnetic: $newGeomagnetic');
      geomagnetic = newGeomagnetic;
    } catch (e, s) {
      logger.e('Error while updating geomagnetic', error: e, stackTrace: s);
    }
  }

  Future<void> updateBackround() async {
    logger.d('Trying to update background');
    try {
      final newBackground = await netRepo.getCloudflareImage(
        buildWeatherPrompt(
          date: DateTime.now(),
          temperature: weather?.temperature ?? 0,
          conditionRu: weather?.condition.text ?? '',
          city: environment.city,
          region: environment.area ?? '',
          sunrise: Utils.formatTimeAmPm(weather!.sunrise),
          sunset: Utils.formatTimeAmPm(weather!.sunset),
        ),
      );
      logger.i('Got new background');
      background = newBackground;
    } catch (e, s) {
      logger.e('Error while updating background', error: e, stackTrace: s);
    }
  }
}
