/// Weather condition codes WorldWeatherOnline (wttr.in).
enum ConditionCode {
  sunny(113, 'Sunny / Clear'),
  partlyCloudy(116, 'Partly Cloudy'),
  cloudy(119, 'Cloudy'),
  overcast(122, 'Overcast'),
  mist(143, 'Mist'),
  patchyRainNearby(176, 'Patchy rain nearby'),
  patchySnowNearby(179, 'Patchy snow nearby'),
  patchySleetNearby(182, 'Patchy sleet nearby'),
  patchyFreezingDrizzleNearby(185, 'Patchy freezing drizzle nearby'),
  thunderyOutbreaksNearby(200, 'Thundery outbreaks in nearby'),
  blowingSnow(227, 'Blowing snow'),
  blizzard(230, 'Blizzard'),
  fog(248, 'Fog'),
  freezingFog(260, 'Freezing fog'),
  patchyLightDrizzle(263, 'Patchy light drizzle'),
  lightDrizzle(266, 'Light drizzle'),
  freezingDrizzle(281, 'Freezing drizzle'),
  heavyFreezingDrizzle(284, 'Heavy freezing drizzle'),
  patchyLightRain(293, 'Patchy light rain'),
  lightRain(296, 'Light rain'),
  moderateRainAtTimes(299, 'Moderate rain at times'),
  moderateRain(302, 'Moderate rain'),
  heavyRainAtTimes(305, 'Heavy rain at times'),
  heavyRain(308, 'Heavy rain'),
  lightFreezingRain(311, 'Light freezing rain'),
  moderateOrHeavyFreezingRain(314, 'Moderate or heavy freezing rain'),
  lightSleet(317, 'Light sleet'),
  moderateOrHeavySleet(320, 'Moderate or heavy sleet'),
  patchyLightSnow(323, 'Patchy light snow'),
  lightSnow(326, 'Light snow'),
  patchyModerateSnow(329, 'Patchy moderate snow'),
  moderateSnow(332, 'Moderate snow'),
  patchyHeavySnow(335, 'Patchy heavy snow'),
  heavySnow(338, 'Heavy snow'),
  icePellets(350, 'Ice pellets'),
  lightRainShower(353, 'Light rain shower'),
  moderateOrHeavyRainShower(356, 'Moderate or heavy rain shower'),
  torrentialRainShower(359, 'Torrential rain shower'),
  lightSleetShowers(362, 'Light sleet showers'),
  moderateOrHeavySleetShowers(365, 'Moderate or heavy sleet showers'),
  lightSnowShowers(368, 'Light snow showers'),
  moderateOrHeavySnowShowers(371, 'Moderate or heavy snow showers'),
  lightShowersOfIcePellets(374, 'Light showers of ice pellets'),
  moderateOrHeavyShowersOfIcePellets(
    377,
    'Moderate or heavy showers of ice pellets',
  ),
  patchyLightRainInAreaWithThunder(
    386,
    'Patchy light rain in area with thunder',
  ),
  moderateOrHeavyRainInAreaWithThunder(
    389,
    'Moderate or heavy rain in area with thunder',
  ),
  patchyLightSnowInAreaWithThunder(
    392,
    'Patchy light snow in area with thunder',
  ),
  moderateOrHeavySnowInAreaWithThunder(
    395,
    'Moderate or heavy snow in area with thunder',
  );

  /// Number code WWO.
  final int code;
  final String description;
  const ConditionCode(this.code, this.description);

  static ConditionCode? fromCode(int code) {
    for (final value in values) {
      if (value.code == code) return value;
    }
    return null;
  }

  Map<String, dynamic> toMap() => {'code': code, 'description': description};

  static List<Map<String, dynamic>> dictionary() =>
      ConditionCode.values.map((element) => element.toMap()).toList();
}
