import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

/// App-wide date format: MM-dd-yyyy hh:mm a
/// Example: 02-19-2026 02:30 PM
class AppDateFormatter {
  static final DateFormat fullFormat = DateFormat('MM-dd-yyyy hh:mm a');
  static final DateFormat dateOnlyFormat = DateFormat('MM-dd-yyyy');
  static DateFormat get dateOnly => dateOnlyFormat;
  static final DateFormat timeOnlyFormat = DateFormat('hh:mm a');

  /// Format a DateTime to the app standard: MM-dd-yyyy hh:mm a
  static String format(DateTime dateTime) {
    return fullFormat.format(dateTime);
  }

  /// Format date only: MM-dd-yyyy
  static String formatDateOnly(DateTime dateTime) {
    return dateOnlyFormat.format(dateTime);
  }

  /// Format time only: hh:mm a
  static String formatTimeOnly(DateTime dateTime) {
    return timeOnlyFormat.format(dateTime);
  }

  /// Format a date range: MM-dd-yyyy — MM-dd-yyyy
  static String formatRange(DateTime start, DateTime end) {
    return '${dateOnlyFormat.format(start)} — ${dateOnlyFormat.format(end)}';
  }
}

/// Reusable date + time picker helper
class AppDatePicker {
  /// Show date picker and return selected date
  static Future<DateTime?> pickDate(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepNavy,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.deepNavy,
            ),
          ),
          child: child!,
        );
      },
    );
    return date;
  }

  /// Show time picker and return selected time
  static Future<TimeOfDay?> pickTime(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) async {
    final time = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepNavy,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.deepNavy,
            ),
          ),
          child: child!,
        );
      },
    );
    return time;
  }

  /// Show date + time picker and return full DateTime
  static Future<DateTime?> pickDateTime(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    final date = await pickDate(context, initialDate: initialDate);
    if (date == null) return null;

    final time = await pickTime(
      context,
      initialTime: initialDate != null
          ? TimeOfDay.fromDateTime(initialDate)
          : TimeOfDay.now(),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  /// Show a date range picker (start & end) as a bottom sheet
  static Future<DateTimeRange?> pickDateRange(
    BuildContext context, {
    DateTimeRange? initialRange,
  }) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepNavy,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.deepNavy,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.deepNavy,
              foregroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    return range;
  }
}

/// A reusable date display chip widget
class DateRangeChip extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const DateRangeChip({
    super.key,
    this.startDate,
    this.endDate,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = startDate != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: hasDate
              ? AppColors.deepNavy.withOpacity(0.08)
              : AppColors.grey200,
          borderRadius: BorderRadius.circular(12),
          border: hasDate
              ? Border.all(color: AppColors.deepNavy.withOpacity(0.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              color: hasDate ? AppColors.deepNavy : AppColors.grey600,
              size: 20,
            ),
            if (hasDate) ...[
              const SizedBox(width: 6),
              Text(
                endDate != null
                    ? '${AppDateFormatter.formatDateOnly(startDate!)} — ${AppDateFormatter.formatDateOnly(endDate!)}'
                    : AppDateFormatter.formatDateOnly(startDate!),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              if (onClear != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
