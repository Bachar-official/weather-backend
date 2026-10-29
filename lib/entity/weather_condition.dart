enum WeatherCondition {
  sunny(1000, 'Sunny', 'Clear'),
  partlyCloudy(1003, 'Partly cloudy', 'Partly cloudy'),
  cloudy(1006, 'Cloudy', 'Cloudy'),
  overcast(1009, 'Overcast', 'Overcast'),
  haze(1012, 'Haze', 'Haze'),
  dustHaze(1015, 'Dust haze', 'Dust haze'),
  blowingDust(1018, 'Blowing dust', 'Blowing dust'),
  dustStorm(1021, 'Dust storm', 'Dust storm'),
  sandstorm(1024, 'Sandstorm', 'Sandstorm'),
  severeSandstorm(1027, 'Severe sandstorm', 'Severe sandstorm'),
  mist(1030, 'Mist', 'Mist'),
  smoke(1033, 'Smoke', 'Smoke'),
  smokyHaze(1036, 'Smoky haze', 'Smoky haze'),
  smog(1039, 'Smog', 'Smog'),
  severeSmog(1042, 'Severe smog', 'Severe smog'),
  saharanDust(1045, 'Saharan dust', 'Saharan dust'),
  dust(1048, 'Dust', 'Dust'),
  patchyRainPossible(1063, 'Patchy rain possible', 'Patchy rain possible'),
  patchySnowPossible(1066, 'Patchy snow possible', 'Patchy snow possible'),
  patchySleetPossible(1069, 'Patchy sleet possible', 'Patchy sleet possible'),
  patchyFreezingDrizzlePossible(
    1072,
    'Patchy freezing drizzle possible',
    'Patchy freezing drizzle possible',
  ),
  thunderyOutbreaksPossible(
    1087,
    'Thundery outbreaks possible',
    'Thundery outbreaks possible',
  ),
  blowingSnow(1114, 'Blowing snow', 'Blowing snow'),
  blizzard(1117, 'Blizzard', 'Blizzard'),
  fog(1135, 'Fog', 'Fog'),
  freezingFog(1147, 'Freezing fog', 'Freezing fog'),
  patchyLightDrizzle(1150, 'Patchy light drizzle', 'Patchy light drizzle'),
  lightDrizzle(1153, 'Light drizzle', 'Light drizzle'),
  freezingDrizzle(1168, 'Freezing drizzle', 'Freezing drizzle'),
  heavyFreezingDrizzle(
    1171,
    'Heavy freezing drizzle',
    'Heavy freezing drizzle',
  ),
  patchyLightRain(1180, 'Patchy light rain', 'Patchy light rain'),
  lightRain(1183, 'Light rain', 'Light rain'),
  moderateRainAtTimes(1186, 'Moderate rain at times', 'Moderate rain at times'),
  moderateRain(1189, 'Moderate rain', 'Moderate rain'),
  heavyRainAtTimes(1192, 'Heavy rain at times', 'Heavy rain at times'),
  heavyRain(1195, 'Heavy rain', 'Heavy rain'),
  lightFreezingRain(1198, 'Light freezing rain', 'Light freezing rain'),
  moderateOrHeavyFreezingRain(
    1201,
    'Moderate or heavy freezing rain',
    'Moderate or heavy freezing rain',
  ),
  lightSleet(1204, 'Light sleet', 'Light sleet'),
  moderateOrHeavySleet(
    1207,
    'Moderate or heavy sleet',
    'Moderate or heavy sleet',
  ),
  patchyLightSnow(1210, 'Patchy light snow', 'Patchy light snow'),
  lightSnow(1213, 'Light snow', 'Light snow'),
  patchyModerateSnow(1216, 'Patchy moderate snow', 'Patchy moderate snow'),
  moderateSnow(1219, 'Moderate snow', 'Moderate snow'),
  patchyHeavySnow(1222, 'Patchy heavy snow', 'Patchy heavy snow'),
  heavySnow(1225, 'Heavy snow', 'Heavy snow'),
  icePellets(1237, 'Ice pellets', 'Ice pellets'),
  lightRainShower(1240, 'Light rain shower', 'Light rain shower'),
  moderateOrHeavyRainShower(
    1243,
    'Moderate or heavy rain shower',
    'Moderate or heavy rain shower',
  ),
  torrentialRainShower(
    1246,
    'Torrential rain shower',
    'Torrential rain shower',
  ),
  lightSleetShowers(1249, 'Light sleet showers', 'Light sleet showers'),
  moderateOrHeavySleetShowers(
    1252,
    'Moderate or heavy sleet showers',
    'Moderate or heavy sleet showers',
  ),
  lightSnowShowers(1255, 'Light snow showers', 'Light snow showers'),
  moderateOrHeavySnowShowers(
    1258,
    'Moderate or heavy snow showers',
    'Moderate or heavy snow showers',
  ),
  lightShowersOfIcePellets(
    1261,
    'Light showers of ice pellets',
    'Light showers of ice pellets',
  ),
  moderateOrHeavyShowersOfIcePellets(
    1264,
    'Moderate or heavy showers of ice pellets',
    'Moderate or heavy showers of ice pellets',
  ),
  patchyLightRainWithThunder(
    1273,
    'Patchy light rain with thunder',
    'Patchy light rain with thunder',
  ),
  moderateOrHeavyRainWithThunder(
    1276,
    'Moderate or heavy rain with thunder',
    'Moderate or heavy rain with thunder',
  ),
  patchyLightSnowWithThunder(
    1279,
    'Patchy light snow with thunder',
    'Patchy light snow with thunder',
  ),
  moderateOrHeavySnowWithThunder(
    1282,
    'Moderate or heavy snow with thunder',
    'Moderate or heavy snow with thunder',
  );

  final int code;
  final String dayCondition;
  final String nightCondition;

  const WeatherCondition(this.code, this.dayCondition, this.nightCondition);

  /// Возвращает английское описание условия в зависимости от времени суток
  String getCondition(bool isNight) => isNight ? nightCondition : dayCondition;

  /// Безопасный поиск условия по коду. Возвращает `overcast` как fallback, если код неизвестен.
  static WeatherCondition fromCode(int code) {
    for (final condition in WeatherCondition.values) {
      if (condition.code == code) return condition;
    }
    return WeatherCondition.overcast;
  }
}
