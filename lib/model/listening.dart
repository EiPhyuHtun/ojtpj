import 'package:jlpt_quiz/questionScreen.dart';

class Listening {
  final String startTime;   // e.g. "00:01:02"  or "62" (seconds)
  final String endTime;     // e.g. "00:01:17"  or "77"

  Listening({required this.startTime, required this.endTime});

  /// Convert to DurationRange right here for convenience
  DurationRange toRange() => DurationRange(
        start: _parseToDuration(startTime),
        end:   _parseToDuration(endTime),
      );

Duration _parseToDuration(String s) {
  // Trim any whitespace first
  s = s.trim();

  // 1) Plain seconds: "62"
  if (!s.contains(':')) {
    final secs = int.tryParse(s);
    if (secs != null) return Duration(seconds: secs);
    throw FormatException('Invalid seconds value: $s');
  }

  // 2) Split HH / MM / SS
  final parts = s.split(':').map(int.parse).toList();

  // Accept "MM:SS" or "HH:MM:SS"
  if (parts.length == 2) {
    final [mm, ss] = parts;
    return Duration(minutes: mm, seconds: ss);
  } else if (parts.length == 3) {
    final [hh, mm, ss] = parts;
    return Duration(hours: hh, minutes: mm, seconds: ss);
  }

  throw FormatException('Unsupported duration format: $s');
}
}
