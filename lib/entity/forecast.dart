import 'condition.dart';

class Forecast {
  final DateTime time;  
  final double temperature; // Environment.units (C or F)
  final Condition condition;
  final bool isDay;

  const Forecast({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.isDay,
  });

  factory Forecast.fromMap(
    Map<String, dynamic> map, {
    required bool metric,
  }) {
    final temp = metric
        ? (map['temp_c'] as num).toDouble()
        : (map['temp_f'] as num).toDouble();

    return Forecast(
      time: DateTime.parse(map['time'] as String),
      temperature: temp,
      condition: Condition.fromMap(
        map['condition'] as Map<String, dynamic>,
      ),
      isDay: map['is_day'] == 1,
    );
  }

  Map<String, dynamic> toMap() => {
        'time': time.toIso8601String(),
        'temperature': temperature,
        'code': condition.code,
        'isDay': isDay,
      };

  @override
  String toString() =>
      'Forecast(time: $time, temperature: $temperature, code: ${condition.code}, isDay: $isDay)';
}