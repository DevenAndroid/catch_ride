import 'package:intl/intl.dart';

class DateUtil {
  static const String displayFormat = 'dd MMM yyyy';

  static String formatDisplayDate(dynamic date) {
    if (date == null) return '';

    DateTime? dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else if (date is String) {
      if (date.isEmpty) return '';
      // Try to parse typical formats
      dateTime = DateTime.tryParse(date);
      if (dateTime == null) {
        // Handle custom formats if necessary, e.g., '20 Mar 2026'
        try {
          dateTime = DateFormat('dd MMM yyyy').parse(date);
        } catch (_) {
          try {
            dateTime = DateFormat('yyyy-MM-dd').parse(date);
          } catch (_) {
            return date; // Return as is if we can't parse
          }
        }
      }
    }

    if (dateTime != null) {
      return DateFormat(displayFormat).format(dateTime);
    }
    return date.toString();
  }

  static String formatRange(dynamic start, dynamic end) {
    final s = formatDisplayDate(start);
    final e = formatDisplayDate(end);
    if (s.isEmpty && e.isEmpty) return '';
    if (s.isEmpty) return e;
    if (e.isEmpty) return s;
    return '$s - $e';
  }

  static String formatDate(dynamic date, {String format = displayFormat}) {
    if (date == null) return '';

    DateTime? dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else if (date is String) {
      if (date.isEmpty) return '';
      dateTime = DateTime.tryParse(date);
    }

    if (dateTime != null) {
      return DateFormat(format).format(dateTime);
    }
    return date.toString();
  }

  static String getTimeAgo(DateTime? date) {
    if (date == null) return 'N/A';

    final duration = DateTime.now().difference(date);

    if (duration.inDays > 30) {
      return formatDisplayDate(date);
    } else if (duration.inDays > 0) {
      return '${duration.inDays} ${duration.inDays == 1 ? 'day' : 'days'} ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ${duration.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} ${duration.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
  static String formatDateTime(dynamic date) {
    if (date == null) return '';

    DateTime? dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else if (date is String) {
      if (date.isEmpty) return '';
      dateTime = DateTime.tryParse(date);
    }

    if (dateTime != null) {
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    }
    return date.toString();
  }
}
