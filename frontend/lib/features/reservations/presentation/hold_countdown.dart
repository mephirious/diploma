String formatHoldCountdown(Duration duration) {
  final clamped = duration.isNegative ? Duration.zero : duration;
  final minutes = clamped.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = clamped.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (clamped.inHours > 0) {
    return '${clamped.inHours}:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}
