// booking_detail_base.dart
// Full booking detail — visible to both vendor and trainer under their bookings list
// Named Booking[Service] in the Dev Packet

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/profile/flows/profile_complete_groom.dart';

class BookingDetailBase extends StatelessWidget {
  final VendorBooking booking;
  final VendorServiceConfig service;
  final bool isVendorView;
  final VoidCallback? onEditReservation;

  const BookingDetailBase({
    super.key,
    required this.booking,
    required this.service,
    this.isVendorView = true,
    this.onEditReservation,
  });

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final s = service;
    final dateStr = DateFormat('EEEE, MMMM d, yyyy · h:mm a').format(b.date);

    return Scaffold(
      appBar: AppBar(title: Text('${s.verbLabel} Booking'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Booking Title/Description ────────────────────────────────
            Text(
              '${b.horseCount} Day${b.horseCount > 1 ? 's' : ''} ${s.verbLabel} ${b.showName}',
              style: AppTextStyles.headlineMedium.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 12),

            // ── Status Banner ────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: b.status.color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: b.status.color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(_statusIcon(b.status), size: 20, color: b.status.color),
                  const SizedBox(width: 10),
                  Text(
                    'Status: ${b.status.label}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: b.status.color,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '# ${b.id}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Party Info (Conditional) ────────────────────────────────
            _sectionLabel(
              isVendorView ? 'Client' : 'Service Provider',
              Icons.person_outline_rounded,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecor(),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.deepNavy.withOpacity(0.1),
                    child: Text(
                      isVendorView ? b.clientName[0] : 'JS',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isVendorView ? b.clientName : 'John Smith',
                          style: AppTextStyles.titleMedium,
                        ),
                        Text(
                          isVendorView ? b.clientRole : 'Vendor · Groom',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (isVendorView) {
                        Get.snackbar('Profile', 'Opening Trainer Profile');
                      } else {
                        Get.to(
                          () =>
                              const ProfilePageGroomScreen(isOwnProfile: false),
                        );
                      }
                    },
                    child: const Text('View Profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Service Details ──────────────────────────────────────────
            _sectionLabel('${s.verbLabel} Details', s.icon),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecor(),
              child: Column(
                children: [
                  _row(Icons.work_outline_rounded, 'Service', b.serviceDetail),
                  _div(),
                  _row(Icons.calendar_today_rounded, 'Date & Time', dateStr),
                  if (b.endDate != null) ...[
                    _div(),
                    _row(Icons.calendar_month_rounded, 'End Date', b.endDate!),
                  ],
                  _div(),
                  _row(Icons.location_on_outlined, 'Location', b.location),
                  if (b.address != null) ...[
                    _div(),
                    _row(Icons.map_outlined, 'Address', b.address!),
                  ],
                  _div(),
                  _row(Icons.flag_outlined, 'Show / Event', b.showName),
                  _div(),
                  _row(
                    Icons.pets_rounded,
                    'Horse(s)',
                    '${b.horseName} · ${b.horseCount} horse${b.horseCount > 1 ? 's' : ''}',
                  ),
                  _div(),
                  _row(
                    Icons.attach_money_rounded,
                    'Rate',
                    '${b.rate} ${s.rateUnit}',
                  ),
                  if (b.notes != null) ...[
                    _div(),
                    _row(Icons.notes_rounded, 'Notes', b.notes!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Payment & Policy ─────────────────────────────────────────
            _sectionLabel('Payment & Policy', Icons.info_outline_rounded),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecor(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row(
                    Icons.payments_outlined,
                    'Accepted',
                    b.paymentMethods?.join(', ') ?? 'Cash, Zelle, In-App',
                  ),
                  _div(),
                  _row(
                    Icons.policy_outlined,
                    'Cancellation',
                    b.cancellationPolicy ?? 'Flexible (24hr notice)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── System Message Log ───────────────────────────────────────
            _sectionLabel('Activity', Icons.history_rounded),
            const SizedBox(height: 10),
            _systemEventLog(b),
            const SizedBox(height: 28),

            // ── Context-sensitive Actions ────────────────────────────────
            ..._buildActions(b, s),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(VendorBooking b, VendorServiceConfig s) {
    if (b.status == BookingStatus.confirmed) {
      return [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () =>
                Get.snackbar('Messages', 'Opening thread with ${b.clientName}'),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text('Message'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
                onEditReservation ??
                () => Get.snackbar(
                  'Edit',
                  'Navigating to Request Form with pre-filled data...',
                ),
            icon: const Icon(Icons.edit_calendar_outlined),
            label: const Text('Change Reservation'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.deepNavy,
              side: const BorderSide(color: AppColors.deepNavy),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => Get.snackbar(
              'Cancel',
              'Cancellation policy: ${b.cancellationPolicy ?? 'Standard'}',
            ),
            child: const Text(
              'Cancel Booking',
              style: TextStyle(
                color: AppColors.softRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ];
    }
    if (b.status == BookingStatus.completed) {
      return [
        Center(
          child: TextButton.icon(
            onPressed: () => Get.snackbar('Coming Soon', 'Receipt / Summary'),
            icon: const Icon(Icons.receipt_long_outlined, size: 18),
            label: const Text('View Service Summary'),
            style: TextButton.styleFrom(foregroundColor: AppColors.deepNavy),
          ),
        ),
      ];
    }
    return [];
  }

  Widget _systemEventLog(VendorBooking b) {
    final events = <Map<String, dynamic>>[
      {
        'icon': Icons.bookmark_border_rounded,
        'text': 'New booking request from ${b.clientName}',
        'time': DateFormat(
          'MMM d, h:mm a',
        ).format(b.date.subtract(const Duration(hours: 2))),
        'color': AppColors.deepNavy,
      },
      if (b.status == BookingStatus.confirmed ||
          b.status == BookingStatus.completed) ...[
        {
          'icon': Icons.check_circle_outline_rounded,
          'text': 'Booking accepted',
          'time': DateFormat(
            'MMM d, h:mm a',
          ).format(b.date.subtract(const Duration(hours: 1))),
          'color': AppColors.successGreen,
        },
      ],
      if (b.status == BookingStatus.declined) ...[
        {
          'icon': Icons.cancel_outlined,
          'text': 'Booking declined',
          'time': DateFormat(
            'MMM d, h:mm a',
          ).format(b.date.subtract(const Duration(minutes: 30))),
          'color': AppColors.softRed,
        },
      ],
      if (b.status == BookingStatus.completed) ...[
        {
          'icon': Icons.star_outline_rounded,
          'text': 'Service completed',
          'time': DateFormat('MMM d').format(b.date),
          'color': AppColors.mutedGold,
        },
      ],
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecor(),
      child: Column(
        children: events.asMap().entries.map((entry) {
          final idx = entry.key;
          final e = entry.value;
          return Column(
            children: [
              if (idx > 0) const Divider(height: 1, color: AppColors.grey100),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      e['icon'] as IconData,
                      size: 16,
                      color: e['color'] as Color,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        e['text'] as String,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      e['time'] as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey400,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  IconData _statusIcon(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:
        return Icons.schedule_rounded;
      case BookingStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case BookingStatus.completed:
        return Icons.star_outline_rounded;
      case BookingStatus.declined:
        return Icons.cancel_outlined;
      case BookingStatus.cancelled:
        return Icons.remove_circle_outline_rounded;
    }
  }

  Widget _sectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.deepNavy),
        const SizedBox(width: 6),
        Text(
          title.toUpperCase(),
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.grey500,
            fontSize: 11,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecor() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AppColors.grey200),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  Widget _row(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.grey500),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
          ),
          Expanded(
            child: Text(
              val,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _div() =>
      const Divider(height: 1, thickness: 1, color: AppColors.grey100);
}
