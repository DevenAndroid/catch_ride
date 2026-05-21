import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateUtil {
  static const String displayFormat = 'MMM dd, yyyy';

  static String formatDisplayDate(dynamic date) {
    if (date == null) return '';

    DateTime? dateTime = parse(date);

    if (dateTime != null) {
      return DateFormat(displayFormat).format(dateTime);
    }
    return date.toString();
  }

  static String formatRange(dynamic start, dynamic end) {
    if (start == null && end == null) return '';

    DateTime? startDate = parse(start);
    DateTime? endDate = parse(end);

    if (startDate == null && endDate == null) {
      if (start != null && end != null) return "$start - $end";
      if (start != null) return start.toString();
      if (end != null) return end.toString();
      return '';
    }

    if (startDate == null || endDate == null) {
      if (startDate == null && start != null) return start.toString();
      if (endDate == null && end != null) return end.toString();
      
      if (startDate != null) return DateFormat(displayFormat).format(startDate);
      if (endDate != null) return DateFormat(displayFormat).format(endDate);
      return '';
    }

    if (startDate.year == endDate.year) {
      return "${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}";
    }

    return "${DateFormat(displayFormat).format(startDate)} - ${DateFormat(displayFormat).format(endDate)}";
  }

  static String formatRangeString(String? rangeStr) {
    if (rangeStr == null || rangeStr.isEmpty || rangeStr == 'N/A') return '';
    if (rangeStr.contains(' to ')) {
      final parts = rangeStr.split(' to ');
      return formatRange(parts[0], parts[1]);
    }
    if (rangeStr.contains(' - ')) {
      final parts = rangeStr.split(' - ');
      return formatRange(parts[0], parts[1]);
    }
    return formatDisplayDate(rangeStr);
  }

  static String formatDate(dynamic date, {String format = displayFormat}) {
    if (date == null) return '';

    DateTime? dateTime = parse(date);

    if (dateTime != null) {
      return DateFormat(format).format(dateTime);
    }
    return date.toString();
  }

  static String getTimeAgo(DateTime? date) {
    if (date == null) return '';

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

    DateTime? dateTime = parse(date);

    if (dateTime != null) {
      // For full date-time, we might want to keep local/UTC context if it's a real timestamp
      // but for our calendar dates, we treat them as fixed.
      return DateFormat('MMMM d, yyyy, hh:mm a').format(dateTime);
    }
    return date.toString();
  }

  /// Public helper to parse any date format encountered in the app
  static DateTime? parse(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    if (date is! String || date.isEmpty) return null;

    // 1. Try ISO 8601
    DateTime? parsed = DateTime.tryParse(date);
    if (parsed != null) return parsed;

    // 2. Try common display formats
    try {
      return DateFormat('dd MMM yyyy').parse(date);
    } catch (_) {}

    try {
      return DateFormat('d MMM yyyy').parse(date);
    } catch (_) {}

    try {
      return DateFormat('d MMMM yyyy').parse(date);
    } catch (_) {}

    try {
      return DateFormat('MMMM d, yyyy').parse(date);
    } catch (_) {}

    try {
      return DateFormat('MMM d, yyyy').parse(date);
    } catch (_) {}

    try {
      return DateFormat('MMM dd, yyyy').parse(date);
    } catch (_) {}

    // 3. Try standard ISO-like date only
    try {
      return DateFormat('yyyy-MM-dd').parse(date);
    } catch (_) {}

    // 4. Try JS Date.toString() format
    // Example: "Thu May 21 2026 05:30:00 GMT+0530 (India Standard Time)"
    try {
      // We only really need the first part for the date
      final parts = date.split(' ');
      if (parts.length >= 4) {
        final monthStr = parts[1]; // May
        final dayStr = parts[2];   // 21
        final yearStr = parts[3];  // 2026
        final simplified = "$dayStr $monthStr $yearStr";
        return DateFormat('dd MMM yyyy').parse(simplified);
      }
    } catch (e) {
      debugPrint('DateUtil: Failed to parse JS date string: $date');
    }

    return null;
  }
}
 