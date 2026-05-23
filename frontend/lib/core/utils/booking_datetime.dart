import 'package:timezone/timezone.dart' as tz;

/// Parses API timestamps (ISO-8601 or `yyyy-MM-dd HH:mm:ss.SSS ZZZZ`).
DateTime? parseApiDateTime(dynamic value) {
  if (value == null) return null;
  if (value is! String || value.trim().isEmpty) return null;

  var parsed = DateTime.tryParse(value.trim());
  if (parsed == null) {
    final normalized = value.trim().replaceFirstMapped(
      RegExp(r' ([+-])(\d{2})(\d{2})$'),
      (m) => ' ${m[1]}${m[2]}:${m[3]}',
    );
    parsed = DateTime.tryParse(normalized);
  }
  return parsed?.toUtc();
}

tz.Location resolveBookingLocation(String? iana) {
  if (iana != null && iana.isNotEmpty) {
    try {
      return tz.getLocation(iana);
    } catch (_) {}
  }
  try {
    return tz.getLocation('Asia/Almaty');
  } catch (_) {
    return tz.UTC;
  }
}

/// Wall-clock instant in the booking/venue IANA timezone.
tz.TZDateTime? toBookingLocal(DateTime? utc, String? timezone) {
  if (utc == null) return null;
  return tz.TZDateTime.from(utc.toUtc(), resolveBookingLocation(timezone));
}

String formatTimeHm(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
