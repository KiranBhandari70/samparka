import 'package:intl/intl.dart';

class DateUtils {
  DateUtils._();

  static String formatEventDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  static String formatEventTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatEventDateTime(DateTime date) {
    return '${formatEventDate(date)} • ${formatEventTime(date)}';
  }

  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  static String formatChatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a').format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE, h:mm a').format(date);
    } else {
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }
}
