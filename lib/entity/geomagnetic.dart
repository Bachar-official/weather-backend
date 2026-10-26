class Geomagnetic {
  final DateTime date;
  final double kp;

  const Geomagnetic({required this.date, required this.kp});

  factory Geomagnetic.fromJson(Map<String, dynamic> json) {
    return Geomagnetic(date: DateTime.parse(json['time_tag']), kp: json['Kp']);
  }

  Map<String, dynamic> toJson() => {'date': date.toIso8601String(), 'kp': kp};

  @override
  String toString() {
    return 'date: $date, kp: $kp';
  }
}
