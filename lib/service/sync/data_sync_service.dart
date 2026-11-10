// lib/service/sync/data_sync_service.dart
import 'package:cron/cron.dart';
import 'package:logger/web.dart';
import 'package:weather_backend/entity/entity.dart';
import 'package:weather_backend/service/cache/weather_cache.dart';
import 'package:weather_backend/service/net_repo.dart';
import 'package:weather_backend/utils/build_weather_prompt.dart';
import 'package:weather_backend/utils/utils.dart';

class DataSyncService {
  final WeatherCache _cache;
  final NetRepo _netRepo;
  final Environment _env;
  final Logger _logger;
  final Cron _cron = Cron();

  final Function _onDataUpdated; // WsManager callback notification
  final Function _onTimeTick;

  DataSyncService({
    required this._cache,
    required this._netRepo,
    required this._env,
    required this._logger,
    required this._onDataUpdated,
    required this._onTimeTick,
  }) {
    _init();

    _cron.schedule(Schedule.parse(_env.cronSchedule), () async {
      await Future.wait([_updateWeather(), _updateGeomagnetic()]);
      if (_env.isCloudflareFeaturesEnabled) {
        await _updateBackground();
      }
    });

    _cron.schedule(Schedule.parse('0 0 * * *'), () async {
      await _updateHolidays();
    });

    _cron.schedule(Schedule.parse('* * * * *'), () {
      _onTimeTick();
    });
  }

  Future<void> _init() async {
    await Future.wait([
      _updateHolidays(),
      _updateWeather(),
      _updateGeomagnetic(),
    ]);
    if (_env.isCloudflareFeaturesEnabled) {
      await _updateBackground();
    }
  }

  Future<void> _updateWeather() async {
    _logger.d('Updating weather...');
    try {
      _cache.weather = await _netRepo.getWeather();
      _logger.i('Weather updated');
      _onDataUpdated();
    } catch (e, s) {
      _logger.e('Weather update error', error: e, stackTrace: s);
    }
  }

  Future<void> _updateHolidays() async {
    _logger.d('Updating holidays...');
    try {
      _cache.holidays = await _netRepo.getHolidays();
      _logger.i('Holidays updated: ${_cache.holidays.length}');
      _onDataUpdated();
    } catch (e, s) {
      _logger.e('Holidays update error', error: e, stackTrace: s);
    }
  }

  Future<void> _updateGeomagnetic() async {
    _logger.d('Updating geomagnetic...');
    try {
      _cache.geomagnetic = await _netRepo.getGeomagnetic();
      _logger.i('Geomagnetic updated');
      _onDataUpdated();
    } catch (e, s) {
      _logger.e('Geomagnetic update error', error: e, stackTrace: s);
    }
  }

  Future<void> _updateBackground() async {
    _logger.d('Updating background...');
    try {
      _cache.background = await _netRepo.getCloudflareImage(
        buildWeatherPrompt(
          date: DateTime.now(),
          temperature: _cache.weather?.temperature ?? 0,
          conditionCode: _cache.weather?.condition.code ?? 0,
          city: _env.city,
          region: _env.area ?? '',
          countryName: _env
              .country, // Не забудьте добавить это в Environment, если нужно
          sunrise: Utils.formatTimeAmPm(
            _cache.weather?.sunrise ??
                DateTime.now().copyWith(hour: 8, minute: 0),
          ),
          sunset: Utils.formatTimeAmPm(
            _cache.weather?.sunset ??
                DateTime.now().copyWith(hour: 18, minute: 0),
          ),
          holidays: _cache.holidays,
        ),
      );
      _logger.i('Background updated');
      _onDataUpdated();
    } catch (e, s) {
      _logger.e('Background update error', error: e, stackTrace: s);
    }
  }

  void dispose() {
    _cron.close();
  }
}
