import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/vendor/bookings/flows/vendor_booking_models.dart';
import 'package:catch_ride/view/vendor/bookings/flows/farrier_booking_screens.dart';

class BookingDetailFarrierView extends StatelessWidget {
  final VendorBooking booking;
  final bool isTrainer;

  const BookingDetailFarrierView({
    super.key,
    required this.booking,
    this.isTrainer = false,
  });

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final dateStr = DateFormat('MMMM d, yyyy').format(b.date);
    final timeStr = DateFormat('h:mm a').format(b.date);

    // Derived Title: "2 Horses Full Set of Shoes Ocala, Fl"
    final title =
        '${b.horseCount} Horse${b.horseCount > 1 ? 's' : ''} ${b.serviceDetail} ${b.location}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Farrier Booking'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Booking Title ───────────────────────────────────────────
            Text(
              title,
              style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'Booking ID: #${b.id}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 24),

            // ── Status Banner ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: b.status.color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: b.status.color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(_statusIcon(b.status), size: 18, color: b.status.color),
                  const SizedBox(width: 10),
                  Text(
                    b.status.label,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: b.status.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Show Profile Section ─────────────────────────────────────
            _sectionLabel(isTrainer ? 'Farrier' : 'Client'),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => Get.snackbar('Profile', 'Opening profile...'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecor(),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.deepNavy.withOpacity(0.1),
                      child: Text(
                        b.clientName[0],
                        style: AppTextStyles.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
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
                    ),
                    const Text(
                      'View Profile',
                      style: TextStyle(
                        color: AppColors.deepNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.deepNavy,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Booking Details ─────────────────────────────────────────
            _sectionLabel('Service Information'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecor(),
              child: Column(
                children: [
                  _infoRow(Icons.calendar_today_outlined, 'Date', dateStr),
                  _divider(),
                  _infoRow(Icons.access_time, 'Time Window', timeStr),
                  _divider(),
                  _infoRow(
                    Icons.location_on_outlined,
                    'Address / Barn',
                    b.location,
                  ),
                  _divider(),
                  _infoRow(Icons.flag_outlined, 'Show Name', b.showName),
                  _divider(),
                  _infoRow(
                    Icons.pets_outlined,
                    'Horse(s)',
                    '${b.horseName} (${b.horseCount})',
                  ),
                  _divider(),
                  _infoRow(
                    Icons.attach_money_outlined,
                    'Total Estimate',
                    b.rate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Policies & Payments ─────────────────────────────────────
            _sectionLabel('Policies & Payments'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecor(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cancellation Policy', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Flexible: Full refund if cancelled at least 24 hours before the appointment.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Accepted Payment Methods',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Venmo, Zelle, Cash, Credit Card',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            if (b.notes != null && b.notes!.isNotEmpty) ...[
              _sectionLabel('Notes'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: _cardDecor(),
                child: Text(b.notes!, style: AppTextStyles.bodyMedium),
              ),
              const SizedBox(height: 32),
            ],

            // ── Actions ──────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        Get.snackbar('Chat', 'Opening message thread...'),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.deepNavy),
                      foregroundColor: AppColors.deepNavy,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.to(
                      () => BookingsRequestFarrierScreen(
                        vendorName: b.clientName,
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Change'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.grey300),
                      foregroundColor: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () =>
                    Get.snackbar('Cancel', 'Cancellation policy applied.'),
                child: const Text(
                  'Cancel Request',
                  style: TextStyle(color: AppColors.softRed),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.labelLarge.copyWith(
        color: AppColors.grey500,
        fontSize: 11,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.grey400),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500),
            ),
          ),
          Expanded(
            child: Text(
              val,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: AppColors.grey100);

  BoxDecoration _cardDecor() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.grey200),
    );
  }

  IconData _statusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule_rounded;
      case BookingStatus.confirmed:
        return Icons.check_circle_outline;
      case BookingStatus.completed:
        return Icons.verified;
      case BookingStatus.declined:
        return Icons.cancel_outlined;
      case BookingStatus.cancelled:
        return Icons.remove_circle_outline;
    }
  }
}
