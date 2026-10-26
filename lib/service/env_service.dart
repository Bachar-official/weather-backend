import 'package:dotenv/dotenv.dart';
import 'package:weather_backend/entity/entity.dart';

abstract class _EnvFields {
  static const city = 'CITY';
  static const locale = 'LOCALE';
  static const cloudflareAccountId = 'CLOUDFLARE_ACCOUNT_ID';
  static const cloudflareToken = 'CLOUDFLARE_TOKEN';
  static const units = 'UNITS';
  static const port = 'PORT';
  static const cronSchedule = 'CRON_SCHEDULE';
  static const weatherApiToken = 'WEATHERAPI_TOKEN';
}

class EnvService {
  late final DotEnv _env;

  EnvService() {
    _env = DotEnv(includePlatformEnvironment: true)..load();
  }

  String _require(String field) {
    final value = _env[field];
    if (value == null || value == 'null') {
      throw StateError('Required environment variable "$field" not set');
    }
    return value;
  }

  Environment getEnvironment() {
    final city = _require(_EnvFields.city);
    final locale = _require(_EnvFields.locale);
    final weatherApiToken = _require(_EnvFields.weatherApiToken);
    final units = _require(_EnvFields.units);
    final cloudflareAccountId = _env[_EnvFields.cloudflareAccountId];
    final cloudflareToken = _env[_EnvFields.cloudflareToken];
    final port = int.parse(_require(_EnvFields.port));
    final cronSchedule = _require(_EnvFields.cronSchedule);

    return Environment(
      city: city,
      locale: locale,
      weatherApiToken: weatherApiToken,
      units: units,
      cloudflareAccountId: cloudflareAccountId,
      cloudflareToken: cloudflareToken,
      port: port,
      cronSchedule: cronSchedule,
    );
  }
}
