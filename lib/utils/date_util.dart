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
}
