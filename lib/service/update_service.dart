import 'dart:convert';
import 'dart:typed_data';

import 'package:cron/cron.dart';
import 'package:logger/web.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:weather_backend/entity/entity.dart';
import 'net_repo.dart';

class UpdateService {
  final Environment environment;
  late final Router router;
  late Cron cron;
  late Uint8List? background;
  late Weather? weather;
  final NetRepo netRepo;
  final Logger logger;

  UpdateService({required this.environment, required this.netRepo, required this.logger}) {
    cron = Cron();
    background = null;
    weather = null;
    router = Router()..get('/weather', _weatherHandler);

    _init();

    // Requesting weather according to env
    cron.schedule(Schedule.parse(environment.cronSchedule), () async {
      await Future.wait([
        updateWeather(),
      ]);
    });

    // Requesting holidays every midnight
    cron.schedule(Schedule.parse('0 0 * * *'), () async {
      // await updateHolidays();
    });
  }

  Future<void> _init() async {
    await Future.wait([
      // updateHolidays(),
      updateWeather(),
      // updateGeomagnetic(),
    ]);

    // await updateBackround();
  }

  Response _weatherHandler(Request request) {
    if (weather == null) {
      return Response.internalServerError(body: {'Error': 'Weather is null'});
    }
    return Response.ok(jsonEncode(weather!.toMap()), headers: {'Content-Type': 'Application/json'});
  }

  Future<void> updateWeather() async {
    logger.d('Trying to update weather');
    try {
      final newWeather = await netRepo.getWeather();
      logger.i('Got new weather: $newWeather');
      weather = newWeather;
    } catch(e, s) {
      logger.e('Error while updating weather', error: e, stackTrace: s);
    }
  }
}
