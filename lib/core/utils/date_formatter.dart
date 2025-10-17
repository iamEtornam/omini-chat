import 'package:intl/intl.dart';

/// Utility class for formatting dates
class DateFormatter {
  /// Format date to time string (e.g., "10:30 AM")
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Format date to short date string (e.g., "Jan 15")
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Format date to full date string (e.g., "January 15, 2024")
  static String formatFullDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }

  /// Format date relative to now
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return formatTime(date);
    } else if (dateDay == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return formatShortDate(date);
    }
  }
}

