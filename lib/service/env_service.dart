import 'package:dotenv/dotenv.dart';
import 'package:weather_backend/entity/environment.dart';

abstract class EnvFields {
  static const city = 'CITY';
  static const locale = 'LOCALE';
  static const cloudflareAccountId = 'CLOUDFLARE_ACCOUNT_ID';
  static const cloudflareToken = 'CLOUDFLARE_TOKEN';
  static const pressureUnit = 'PRESSURE_UNIT';
  static const units = 'UNITS';
  static const port = 'PORT';
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
    final city = _require(EnvFields.city);
    final locale = _require(EnvFields.locale);
    final pressureUnit = _require(EnvFields.pressureUnit);
    final units = _require(EnvFields.units);
    final cloudflareAccountId = _env[EnvFields.cloudflareAccountId];
    final cloudflareToken = _env[EnvFields.cloudflareToken];
    final port = int.parse(_require(EnvFields.port));

    return Environment(
      city: city,
      locale: locale,
      pressureUnit: pressureUnit,
      units: units,
      cloudflareAccountId: cloudflareAccountId,
      cloudflareToken: cloudflareToken,
      port: port,
    );
  }
}
