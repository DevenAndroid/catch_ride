// booking_request_review_base.dart
// VENDOR reviews an incoming booking request — can Accept or Decline
// Named BookingRequestReview[Service] in the Dev Packet

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_confirmed_base.dart';
import 'package:catch_ride/view/vendor/bookings/flows/booking_denied_base.dart';

class BookingRequestReviewBase extends StatefulWidget {
  final VendorBooking booking;
  final VendorServiceConfig service;
  final bool acceptMode; // pre-scrolls to accept section if true

  const BookingRequestReviewBase({
    super.key,
    required this.booking,
    required this.service,
    this.acceptMode = false,
  });

  @override
  State<BookingRequestReviewBase> createState() =>
      _BookingRequestReviewBaseState();
}

class _BookingRequestReviewBaseState extends State<BookingRequestReviewBase> {
  bool _availabilityConfirmed = false;
  final _declineReasonController = TextEditingController();

  @override
  void dispose() {
    _declineReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final s = widget.service;
    final dateStr = DateFormat('EEEE, MMMM d, yyyy · h:mm a').format(b.date);

    return Scaffold(
      appBar: AppBar(
        title: Text('Review ${s.verbLabel} Request'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Requester Card ───────────────────────────────────────────
            _sectionHeader('From', Icons.person_outline_rounded),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecor(),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.deepNavy.withOpacity(0.1),
                    child: Text(
                      b.clientName[0],
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.clientName, style: AppTextStyles.titleMedium),
                      Text(
                        b.clientRole,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Service Details ──────────────────────────────────────────
            _sectionHeader('Service Details', s.icon),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecor(),
              child: Column(
                children: [
                  _detailRow(
                    Icons.work_outline_rounded,
                    'Service',
                    b.serviceDetail,
                  ),
                  _divider(),
                  _detailRow(Icons.calendar_today_rounded, 'Date', dateStr),
                  _divider(),
                  _detailRow(
                    Icons.location_on_outlined,
                    'Location',
                    b.location,
                  ),
                  _divider(),
                  _detailRow(Icons.flag_outlined, 'Show / Event', b.showName),
                  _divider(),
                  _detailRow(
                    Icons.pets_rounded,
                    'Horses',
                    '${b.horseCount} horse${b.horseCount > 1 ? 's' : ''} (${b.horseName})',
                  ),
                  _divider(),
                  _detailRow(
                    Icons.attach_money_rounded,
                    'Your Rate',
                    '${b.rate} ${s.rateUnit}',
                  ),
                  if (b.notes != null) ...[
                    _divider(),
                    _detailRow(Icons.notes_rounded, 'Notes', b.notes!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Availability Confirmation ────────────────────────────────
            _sectionHeader(
              'Availability Check',
              Icons.check_circle_outline_rounded,
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _availabilityConfirmed,
              onChanged: (val) =>
                  setState(() => _availabilityConfirmed = val ?? false),
              title: Text(
                'I am available on ${DateFormat('MMMM d').format(b.date)} and can fulfill this ${s.verbLabel} request.',
                style: AppTextStyles.bodyMedium,
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.deepNavy,
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 28),

            // ── Action Buttons ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _availabilityConfirmed
                    ? () => Get.offAll(
                        () => BookingConfirmedBase(booking: b, service: s),
                      )
                    : null,
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text(
                  'Accept Booking',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.grey200,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                onPressed: () =>
                    Get.to(() => BookingDeniedBase(booking: b, service: s)),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text(
                  'Decline Request',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.softRed),
                  foregroundColor: AppColors.softRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.deepNavy),
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

  BoxDecoration _cardDecor() {
    return BoxDecoration(
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
  }

  Widget _detailRow(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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

  Widget _divider() =>
      const Divider(height: 1, thickness: 1, color: AppColors.grey100);
}
