class DateTimeHelper {
  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static int remainingDays(DateTime? deadline, {DateTime? from}) {
    if (deadline == null) return 0;
    final today = _dateOnly(from ?? DateTime.now());
    final end = _dateOnly(deadline);
    return end.difference(today).inDays;
  }

  static String remainingDaysLabel(DateTime? deadline, {DateTime? from}) {
    if (deadline == null) return 'No deadline';
    final diff = remainingDays(deadline, from: from);
    if (diff > 0) return '${diff}d left';
    if (diff == 0) return 'Due today';
    return '${-diff}d overdue';
  }

  /// Returns remaining-time ratio in range [0, 1].
  /// 1.0 means all time remains, 0.0 means deadline reached/passed.
  static double remainingTimeRatio(
    DateTime? startDate,
    DateTime? deadline, {
    DateTime? from,
  }) {
    if (deadline == null) return 0.0;

    final now = _dateOnly(from ?? DateTime.now());
    final end = _dateOnly(deadline);

    if (!now.isBefore(end)) {
      return now.isAtSameMomentAs(end) ? 0.0 : 0.0;
    }

    final start = _dateOnly(startDate ?? now);
    final effectiveStart = start.isAfter(end) ? now : start;

    final totalDays = end.difference(effectiveStart).inDays;
    if (totalDays <= 0) return 1.0;

    final remaining = end.difference(now).inDays;
    return (remaining / totalDays).clamp(0.0, 1.0);
  }
}
