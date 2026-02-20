// booking_denied_base.dart
// Shown when a vendor declines a booking request
// Named BookingRequestDenied[Service] in the Dev Packet

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';

class BookingDeniedBase extends StatefulWidget {
  final VendorBooking booking;
  final VendorServiceConfig service;

  const BookingDeniedBase({
    super.key,
    required this.booking,
    required this.service,
  });

  @override
  State<BookingDeniedBase> createState() => _BookingDeniedBaseState();
}

class _BookingDeniedBaseState extends State<BookingDeniedBase> {
  final _reasonController = TextEditingController();
  String? _selectedReason;
  bool _declined = false;

  final _declineReasons = [
    'Not available on this date',
    'Outside my service area',
    'Already booked at this show',
    'Service type not offered',
    'Other — see note',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitDecline() {
    if (_selectedReason == null) {
      Get.snackbar(
        'Required',
        'Please select a reason for declining.',
        backgroundColor: AppColors.softRed,
        colorText: Colors.white,
      );
      return;
    }
    setState(() => _declined = true);
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final s = widget.service;
    final dateStr = DateFormat('MMMM d, yyyy').format(b.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decline Request'),
        centerTitle: true,
        automaticallyImplyLeading: !_declined,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _declined
            ? _buildDeclinedState(b, s)
            : _buildDeclineForm(b, s, dateStr),
      ),
    );
  }

  // ── Decline Form ────────────────────────────────────────────────────────────

  Widget _buildDeclineForm(
    VendorBooking b,
    VendorServiceConfig s,
    String dateStr,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Request summary chip
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.softRed.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.softRed.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.cancel_outlined,
                size: 18,
                color: AppColors.softRed,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Declining ${s.verbLabel} request from ${b.clientName}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$dateStr · ${b.location}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text('Reason for Declining *', style: AppTextStyles.labelLarge),
        const SizedBox(height: 12),
        ..._declineReasons.map(
          (r) => RadioListTile<String>(
            value: r,
            groupValue: _selectedReason,
            onChanged: (val) => setState(() => _selectedReason = val),
            title: Text(r, style: AppTextStyles.bodyMedium),
            activeColor: AppColors.deepNavy,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
                'Optional: Add a note to the client (e.g. suggest alternative dates)',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitDecline,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.softRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirm Decline',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // ── Declined State ──────────────────────────────────────────────────────────

  Widget _buildDeclinedState(VendorBooking b, VendorServiceConfig s) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.softRed.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cancel_rounded,
            size: 52,
            color: AppColors.softRed,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Request Declined',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.softRed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${b.clientName} has been notified. A system message has been sent to your shared thread.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
        ),
        const SizedBox(height: 24),

        // System message preview
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.softRed.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.softRed.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.bookmark_border_rounded,
                size: 16,
                color: AppColors.softRed,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'System message sent: "Booking declined" — visible in your thread with ${b.clientName}.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.softRed,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                Get.snackbar('Messages', 'Opening thread with ${b.clientName}'),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: Text('Message ${b.clientName}'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.deepNavy),
              foregroundColor: AppColors.deepNavy,
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
          child: TextButton(
            onPressed: () => Get.until((r) => r.isFirst),
            child: const Text('Back to Bookings'),
            style: TextButton.styleFrom(foregroundColor: AppColors.deepNavy),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
