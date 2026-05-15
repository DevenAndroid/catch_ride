import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/models/booking_model.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/profile_controller.dart';

class BookingDetailsView extends StatelessWidget {
  final BookingModel booking;
  const BookingDetailsView({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<BookingController>()) {
      Get.put(BookingController());
    }
    final controller = Get.find<BookingController>();

    return Obx(() {
      // Find the "live" booking from the controller's lists to ensure reactivity
      final liveBooking = controller.receivedBookings.firstWhereOrNull((b) => b.id == booking.id) ??
                          controller.sentBookings.firstWhereOrNull((b) => b.id == booking.id) ??
                          booking;

      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          title: CommonText(
            'Booking Details',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildStatusBanner(liveBooking),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequesterCard(liveBooking),
                    const SizedBox(height: 24),
                    _buildServiceInfoSection(liveBooking),
                    const SizedBox(height: 24),
                    if (liveBooking.vendorBundleLines.isNotEmpty) ...[
                      _buildBundledServiceLinesSection(liveBooking),
                      const SizedBox(height: 24),
                      _buildSummarySection(liveBooking),
                      const SizedBox(height: 24),
                    ],
                    if (liveBooking.coreServices.isNotEmpty ||
                        liveBooking.additionalServices.isNotEmpty) ...[
                      _buildBookedServicesSection(liveBooking),
                 //     const SizedBox(height: 24),
                    ],
                    if (liveBooking.notes != null && liveBooking.notes!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildNotesSection(liveBooking),
                    ],
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomSheet: _buildBottomActions(context, controller, liveBooking),
      );
    });
  }

  Widget _buildStatusBanner(BookingModel booking) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String statusText = booking.status.toUpperCase();

    switch (booking.status.toLowerCase()) {
      case 'pending':
        bgColor = const Color(0xFFFEF9C3);
        textColor = const Color(0xFF854D0E);
        icon = Icons.access_time_rounded;
        break;
      case 'confirmed':
      case 'accepted':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'completed':
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1E40AF);
        icon = Icons.task_alt_rounded;
        break;
      case 'cancelled':
      case 'rejected':
      case 'declined':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        icon = Icons.cancel_outlined;
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        icon = Icons.info_outline_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      color: bgColor,
      child: Row(
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 10),
          CommonText(
            'Status: $statusText',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildRequesterCard(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        children: [
          CommonImageView(
            url: booking.clientImage,
            height: 56,
            width: 56,
            shape: BoxShape.circle,
            isUserImage: true,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CommonText(
                  'Requester',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                CommonText(
                  booking.clientName ?? 'Unknown Client',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                if (booking.senderBarnName != null)
                  CommonText(
                    booking.senderBarnName!,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                if (booking.numberOfHorses != null && booking.numberOfHorses! > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/icons/horse_icon.svg', height: 13, width: 13,),
                        const SizedBox(width: 4),
                        CommonText(
                          '${booking.numberOfHorses} ${booking.numberOfHorses == 1 ? 'Horse' : 'Horses'}',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              final chatController = Get.find<ChatController>();
              chatController.openBookingChat(
                bookingId: booking.id ?? '',
                otherId: booking.clientId ?? '',
                otherName: booking.clientName ?? 'Client',
                otherImage: booking.clientImage ?? '',
              );
            },
            icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF2F4F7),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfoSection(BookingModel booking) {
    final bool isShipping = booking.type.toLowerCase().contains('ship') || booking.type.toLowerCase().contains('transport');
    final bool isMulti = booking.type.toLowerCase() == 'multi-service';
    final included = _includedServicesFromLines(booking);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              CommonText(
                'Service Information',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF2F4F7)),
          _buildInfoRow('Service Type', booking.type),
          if (isMulti && included.isNotEmpty) _buildInfoRow('Includes', included),
          if (booking.rateType != null && booking.rateType!.isNotEmpty) _buildInfoRow('Category', booking.rateType!),
          _buildInfoRow('Dates', booking.date),
          if (isShipping && booking.origin != null && booking.destination != null) ...[
             _buildInfoRow('Route', '${booking.origin} → ${booking.destination}'),
          ] else if (booking.location != null) ...[
             _buildInfoRow('Location', booking.location!),
          ],
          if (booking.numberOfHorses != null)
            _buildInfoRow('Number of Horses', '${booking.numberOfHorses}'),
          if (booking.horseName != null)
            _buildInfoRow('Horse Name', booking.horseName!),
        ],
      ),
    );
  }

  String _includedServicesFromLines(BookingModel booking) {
    if (booking.vendorBundleLines.isEmpty) return '';
    final names = booking.vendorBundleLines
        .map((l) => (l['serviceType'] ?? l['type'] ?? '').toString().trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return names.join(' + ');
  }

  String _formatServiceLineDateRange(Map<String, dynamic> line) {
    DateTime? parse(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    final s = parse(line['startDate']);
    final e = parse(line['endDate']);
    if (s != null && e != null) {
      final sameDay =
          s.year == e.year && s.month == e.month && s.day == e.day;
      if (sameDay) return DateFormat('dd MMM yyyy').format(s);
      return '${DateFormat('dd MMM').format(s)} - ${DateFormat('dd MMM yyyy').format(e)}';
    }
    return '—';
  }

  Widget _buildBundledServiceLinesSection(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.layers_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const CommonText(
                'Requested services',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF2F4F7)),
          ...booking.vendorBundleLines.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final line = entry.value;
            final st = (line['serviceType'] ?? line['type'] ?? 'Service').toString();
            final rt = line['rateType']?.toString();
            final horses = line['numberOfHorses']?.toString();
            final loc = line['location']?.toString();
            final o = line['origin']?.toString();
            final d = line['destination']?.toString();
            final ship = st.toLowerCase().contains('ship') || st.toLowerCase().contains('transport');
            final lineNotes = line['notes']?.toString().trim();
            final linePrice = line['price'];
            String priceStr = '';
            if (linePrice is num) {
              priceStr = '\$${linePrice.toStringAsFixed(2)}';
            } else if (linePrice != null && linePrice.toString().isNotEmpty) {
              priceStr = '\$$linePrice';
            }

            final core = line['coreServices'];
            final addl = line['additionalServices'];

            return Padding(
              padding: EdgeInsets.only(bottom: index < booking.vendorBundleLines.length ? 20 : 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE4E7EC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CommonText(
                            '#$index',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CommonText(
                            st,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (priceStr.isNotEmpty)
                          CommonText(
                            priceStr,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow('Dates', _formatServiceLineDateRange(line)),
                    if (rt != null && rt.isNotEmpty) _buildInfoRow('Category', rt),
                    if (horses != null && horses.isNotEmpty) _buildInfoRow('Horses', horses),
                    if (ship && o != null && o.isNotEmpty && d != null && d.isNotEmpty)
                      _buildInfoRow('Route', '$o → $d')
                    else if (loc != null && loc.isNotEmpty)
                      _buildInfoRow('Location', loc),
                    if (lineNotes != null && lineNotes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const CommonText('Notes', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      const SizedBox(height: 4),
                      CommonText(lineNotes, fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                    ],
                    if (core is List && core.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const CommonText('Core services', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      const SizedBox(height: 6),
                      ...core.map((s) => _buildServiceItem(s)),
                    ],
                    if (addl is List && addl.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const CommonText('Additional services', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      const SizedBox(height: 6),
                      ...addl.map((s) => _buildServiceItem(s)),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBookedServicesSection(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              CommonText(
                'Selected Services',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF2F4F7)),
          if (booking.coreServices.isNotEmpty) ...[
            const CommonText('Core Services', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            ...booking.coreServices.map((s) => _buildServiceItem(s)),
            const SizedBox(height: 16),
          ],
          if (booking.additionalServices.isNotEmpty) ...[
            const CommonText('Additional Services', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            ...booking.additionalServices.map((s) => _buildServiceItem(s)),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceItem(dynamic service) {
    String name = 'Service';
    String price = '';
    if (service is Map) {
      name = service['name'] ?? 'Service';
      price = service['price']?.toString() ?? '';
    } else if (service is String) {
      if (service.contains('_')) {
        final parts = service.split('_');
        // Handle duration pattern (e.g. Sports massage_30 -> Sports massage (30 mins))
        if (parts.length == 2 && int.tryParse(parts[1]) != null) {
          name = '${parts[0]} (${parts[1]} mins)';
        } else {
          name = service.replaceAll('_', ' ');
        }
      } else {
        name = service;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 14, color: Color(0xFF027A48)),
                const SizedBox(width: 8),
                CommonText(name, fontSize: 14, color: AppColors.textPrimary),
              ],
            ),
          ),
          if (price.isNotEmpty)
            CommonText('\$$price', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF101828),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CommonText(
            'Total Price',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          CommonText(
            '\$${booking.price.toStringAsFixed(2)}',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BookingModel booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText(
          'Notes from Requester',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: CommonText(
            booking.notes!,
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: CommonText(
              label,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: CommonText(
              value,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Last inclusive calendar day of the job window (local). Used to gate "Mark as Completed".
  DateTime? _jobWindowLastCalendarDay(BookingModel booking) {
    DateTime? dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

    DateTime? tryParseDynamic(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return dateOnly(v);
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      final iso = DateTime.tryParse(s);
      if (iso != null) return dateOnly(iso);
      for (final pattern in ['yyyy-MM-dd', 'dd MMM yyyy', 'dd MMM, yyyy']) {
        try {
          return dateOnly(DateFormat(pattern).parse(s));
        } catch (_) {}
      }
      // e.g. "15 Jan" from model (year omitted) — try current and adjacent years
      if (!RegExp(r'\d{4}').hasMatch(s)) {
        final y0 = DateTime.now().year;
        for (final y in [y0, y0 + 1, y0 - 1]) {
          try {
            return dateOnly(DateFormat('dd MMM yyyy').parse('$s $y'));
          } catch (_) {}
        }
      }
      return null;
    }

    if (booking.vendorBundleLines.isNotEmpty) {
      DateTime? maxDay;
      for (final line in booking.vendorBundleLines) {
        final end = tryParseDynamic(line['endDate']);
        final start = tryParseDynamic(line['startDate']);
        final day = end ?? start;
        if (day != null && (maxDay == null || day.isAfter(maxDay))) {
          maxDay = day;
        }
      }
      if (maxDay != null) return maxDay;
    }

    final endStr = booking.endDate?.trim();
    if (endStr != null && endStr.isNotEmpty) {
      final parsed = tryParseDynamic(endStr);
      if (parsed != null) return parsed;
    }

    final startStr = booking.startDate?.trim();
    if (startStr != null && startStr.isNotEmpty) {
      final parsed = tryParseDynamic(startStr);
      if (parsed != null) return parsed;
    }

    final display = booking.date.trim();
    if (display.isNotEmpty && display != 'N/A') {
      if (display.contains(' - ')) {
        final parts = display.split(' - ');
        if (parts.length >= 2) {
          final right = parts.last.trim();
          final parsed = tryParseDynamic(right);
          if (parsed != null) return parsed;
        }
      } else {
        final parsed = tryParseDynamic(display);
        if (parsed != null) return parsed;
      }
    }

    return null;
  }

  /// "Mark as Completed" is allowed only from the first local calendar day **after** the job window ends.
  bool _canShowMarkAsCompleted(BookingModel booking) {
    final lastDay = _jobWindowLastCalendarDay(booking);
    if (lastDay == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.isAfter(lastDay);
  }

  /// Accept / decline / complete actions only for the service provider on this booking.
  bool _viewerIsAssignedVendor(BookingModel booking) {
    final profileUser = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>().user.value
        : null;
    if (profileUser != null && profileUser.role == 'service_provider') {
      final vId = profileUser.vendorProfileId;
      if (vId != null &&
          vId.isNotEmpty &&
          booking.vendorId != null &&
          booking.vendorId == vId) {
        return true;
      }
    }
    final me = Get.find<AuthController>().currentUser.value?.id;
    if (me != null &&
        booking.acceptedById != null &&
        booking.acceptedById!.isNotEmpty &&
        me == booking.acceptedById) {
      return true;
    }
    return false;
  }

  Widget _buildBottomActions(BuildContext context, BookingController controller, BookingModel booking) {
    final String status = booking.status.toLowerCase();

    if (!_viewerIsAssignedVendor(booking)) {
      return const SizedBox.shrink();
    }

    // Actions for provider (Received bookings)
    if (status == 'pending') {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => controller.updateBookingStatus(booking.id!, 'rejected'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFFDA29B)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const CommonText('Decline', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB42318)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.updateBookingStatus(booking.id!, 'confirmed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: controller.isLoading.value 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const CommonText('Accept Booking', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              )),
            ),
          ],
        ),
      );
    }

    if (status == 'confirmed' || status == 'accepted') {
      final showMark = _canShowMarkAsCompleted(booking);
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showCancelConfirmation(controller, booking),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const CommonText('Cancel Booking', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
            if (showMark) ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showCompleteConfirmation(controller, booking),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const CommonText('Mark as Completed', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showCancelConfirmation(BookingController controller, BookingModel booking) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2), shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 32),
              ),
              const SizedBox(height: 20),
              const CommonText('Cancel Booking',
                  fontSize: 20, fontWeight: FontWeight.bold),
              const SizedBox(height: 12),
              const CommonText(
                'Are you sure you want to cancel this booking? This action cannot be undone.',
                fontSize: 14,
                textAlign: TextAlign.center,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const CommonText('No, Keep It',
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        final success = await controller.updateBookingStatus(booking.id!, 'cancelled');
                        if (success) {
                          Get.snackbar(
                            'Booking Cancelled',
                            'Your booking has been successfully cancelled.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const CommonText('Yes, Cancel',
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompleteConfirmation(BookingController controller, BookingModel booking) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_outline,
                    color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 20),
              const CommonText('Complete Booking',
                  fontSize: 20, fontWeight: FontWeight.bold),
              const SizedBox(height: 12),
              const CommonText(
                'Are you sure you want to mark this booking as completed?',
                fontSize: 14,
                textAlign: TextAlign.center,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const CommonText('Not Yet',
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        final success = await controller.updateBookingStatus(booking.id!, 'completed');
                        if (success) {
                          Get.snackbar(
                            'Booking Completed',
                            'The booking has been marked as completed.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const CommonText('Yes, Complete',
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
