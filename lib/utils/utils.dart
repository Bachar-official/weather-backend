abstract class Utils {
  static String pickLocalizedCondition(
    Map<String, dynamic> map,
    String locale,
  ) {
    final localized = map['lang_$locale'];
    if (localized is List && localized.isNotEmpty) {
      final v = (localized.first as Map)['value'];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    final xx = map['lang_xx'];
    if (xx is List && xx.isNotEmpty) {
      final v = (xx.first as Map)['value'];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    final desc = map['weatherDesc'];
    if (desc is List && desc.isNotEmpty) {
      final v = (desc.first as Map)['value'];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return '';
  }

  static bool isDay(DateTime t, String sunriseHHmm, String sunsetHHmm) {
    int minutes(String hhmm) {
      final p = hhmm.split(':');
      return int.parse(p[0]) * 60 + int.parse(p[1]);
    }

    final sr = minutes(sunriseHHmm);
    final ss = minutes(sunsetHHmm);
    final cur = t.hour * 60 + t.minute;
    return cur >= sr && cur < ss;
  }

  static String formatTimeAmPm(DateTime dateTime, {String separator = ' '}) {
    final hour24 = dateTime.hour;
    final minute = dateTime.minute;

    final period = hour24 >= 12 ? 'PM' : 'AM';
    var hour12 = hour24 % 12;
    if (hour12 == 0) hour12 = 12; // 00:xx -> 12 AM, 12:xx -> 12 PM

    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr$separator$period';
  }
}
