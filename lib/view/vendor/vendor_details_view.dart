import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_button.dart';

import 'package:catch_ride/models/vendor_model.dart';
import 'package:intl/intl.dart';

import '../../controllers/booking_controller.dart';

class VendorDetailsView extends StatefulWidget {
  final VendorModel vendor;
  const VendorDetailsView({super.key, required this.vendor});

  @override
  State<VendorDetailsView> createState() => _VendorDetailsViewState();
}

class _VendorDetailsViewState extends State<VendorDetailsView> {
  final BookingController bookingController = Get.find<BookingController>();

  final List<Map<String, String>> _addedServices = [];
  final TextEditingController _notesController = TextEditingController();
  String _selectedService = 'Grooming';
  String _selectedQty = '2';
  String _selectedLocation = 'WEF, Wellington';

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildBasicInfo(),
                    _buildAboutSection(),
                    _buildDetailsSection(),
                    _buildUpcomingAvailability(),
                    _buildCancelationPolicy(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CommonImageView(
          url: widget.vendor.coverImage,
          width: double.infinity,
          height: 240,
          fit: BoxFit.cover,
        ),

        Positioned(
          top: 60,
          left: 16,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -45,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CommonImageView(
              url: widget.vendor.profilePhoto,
              width: 100,
              height: 100,
              shape: BoxShape.circle,
              isUserImage: true,
            ),

          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 55, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CommonText(
                widget.vendor.fullName,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(width: 8),
              if (widget.vendor.yearsExperience != null)
                CommonText(
                  '• ${widget.vendor.yearsExperience} years',
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (widget.vendor.phone != null)
            CommonText(
              widget.vendor.phone!,
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          CommonText(
            widget.vendor.email,
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('About', fontSize: 16, fontWeight: FontWeight.w700),
          const SizedBox(height: 8),
          CommonText(
            widget.vendor.bio ?? "No bio provided.",
            fontSize: 14,
            color: AppColors.textPrimary.withValues(alpha: 0.8),
            height: 1.5,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.accentRed,
                size: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: CommonText(
                  '${widget.vendor.businessName} • ${widget.vendor.location ?? "Wellington, FL"}',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Details',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        'Services',
                        widget.vendor.services.isNotEmpty
                            ? widget.vendor.services
                                  .map((s) => s.name)
                                  .join(", ")
                            : widget.vendor.serviceType,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDetailRow('Travel Preferences', '')),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 16),
                _buildDetailRow(
                  'Operating Regions',
                  widget.vendor.location ?? '',
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 16),
                _buildDetailRow('Disciplines', ''),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          label,
          fontSize: 13,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(height: 4),
        CommonText(
          value,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildUpcomingAvailability() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CommonText(
            'Upcoming Availability',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (widget.vendor.serviceAvailability.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CommonText(
              'No upcoming availability listed.',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          )
        else
          ...widget.vendor.serviceAvailability.map(
            (avail) => _buildAvailabilityCard(avail),
          ),
      ],
    );
  }

  Widget _buildDummyAvailabilityCard() {
    return Column(
      children: [
        _buildAvailabilityItem(
          'Mar 10 - Mar 18, 2026',
          'Wellington, WEC Ocala',
        ),
        _buildAvailabilityItem(
          'Mar 10 - Mar 18, 2026',
          'Wellington, WEC Ocala',
        ),
        _buildAvailabilityItem(
          'Mar 10 - Mar 18, 2026',
          'Wellington, WEC Ocala',
        ),
      ],
    );
  }

  Widget _buildAvailabilityItem(String dateRange, String location) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  dateRange,
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    CommonText(
                      location,
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip('Show Week Support'),
                      const SizedBox(width: 8),
                      _buildChip('Full - in/ Daily Show Support'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildIconText(Icons.pets, 'Max 6 Horses'),
                    const SizedBox(width: 24),
                    _buildIconText(Icons.calendar_today, 'Max 8 Days'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: CommonText(
                        'Prefer mornings. Experience with warmbloods.',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard(VendorAvailability avail) {
    return _buildAvailabilityItem(
      '${avail.startDate ?? ""} - ${avail.endDate ?? ""}',
      avail.serviceRegion ?? 'General Area',
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CommonText(
        text,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        CommonText(
          text,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildCancelationPolicy() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.errorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.accentRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const CommonText(
                'Cancelation Policy',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.errorPrimary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const CommonText(
            'The reservation is non-refundable and non-transferable.',
            fontSize: 14,
            color: AppColors.errorPrimary,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: CommonButton(
              text: 'Send Booking Request',
              backgroundColor: AppColors.primaryDark,
              onPressed: () => _showBookingBottomSheet(),
              height: 56,
              borderRadius: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: CommonButton(
              onPressed: () {},
              height: 56,
              borderRadius: 16,
              backgroundColor: AppColors.secondary,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message_outlined, size: 20, color: Colors.white),
                  SizedBox(width: 10),
                  CommonText(
                    'Message',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingBottomSheet() {
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setBottomSheetState) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Vendor Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CommonImageView(
                            url: widget.vendor.profilePhoto,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            isUserImage: true,
                          ),

                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                widget.vendor.fullName,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              const SizedBox(height: 4),
                              _buildIconTextSmall(
                                Icons.location_on_outlined,
                                widget.vendor.location ?? '',
                              ),
                              const SizedBox(height: 2),
                              _buildIconTextSmall(
                                Icons.person_outline,
                                widget.vendor.services.isNotEmpty
                                    ? widget.vendor.services
                                          .map((s) => s.name)
                                          .join(", ")
                                    : widget.vendor.serviceType,
                              ),
                              const SizedBox(height: 2),
                              if (widget.vendor.serviceAvailability.isNotEmpty)
                                _buildIconTextSmall(
                                  Icons.calendar_today_outlined,
                                  '${widget.vendor.serviceAvailability.first.startDate} - ${widget.vendor.serviceAvailability.first.endDate}',
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_addedServices.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Column(
                      children: _addedServices
                          .map(
                            (service) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primaryDark.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                color: AppColors.background,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CommonText(
                                        service['name']!,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.05,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: CommonText(
                                          'Qty: ${service['qty']}',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  _buildIconTextSmall(
                                    Icons.location_on_outlined,
                                    service['location']!,
                                  ),
                                  const SizedBox(height: 4),
                                  _buildIconTextSmall(
                                    Icons.calendar_today_outlined,
                                    '01 Apr - 07 Apr 2026',
                                  ),
                                  if (service['note']!.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    CommonText(
                                      'NOTE : ${service['note']}',
                                      fontSize: 13,
                                      color: Colors.black.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 20),
                  _buildDropdownField('Service', _selectedService),
                  const SizedBox(height: 16),
                  _buildDropdownField('Quality', _selectedQty),
                  const SizedBox(height: 16),
                  _buildDropdownField('Location', _selectedLocation),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          'Start Date',
                          _startDate == null
                              ? 'Select Date'
                              : DateFormat('dd MMM yyyy').format(_startDate!),
                          isStart: true,
                          setState: setBottomSheetState,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                          'End Date',
                          _endDate == null
                              ? 'Select Date'
                              : DateFormat('dd MMM yyyy').format(_endDate!),
                          isStart: false,
                          setState: setBottomSheetState,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const CommonText(
                    'Notes to Vendor',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add a note for the service provider...',
                      hintStyle: TextStyle(
                        color: Colors.black.withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderMedium,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setBottomSheetState(() {
                          _addedServices.add({
                            'name': _selectedService,
                            'qty': _selectedQty,
                            'location': _selectedLocation,
                            'note': _notesController.text,
                          });
                          _notesController.clear();
                        });
                        setState(
                          () {},
                        ); // Update parent to reflect in next open if needed
                      },
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                        color: AppColors.linkBlue,
                      ),
                      label: const CommonText(
                        'Add Service',
                        color: AppColors.linkBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CommonButton(
                          text: 'Cancel',
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          onPressed: () => Get.back(),
                          height: 56,
                          borderRadius: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => CommonButton(
                            text: 'Submit',
                            backgroundColor: AppColors.primaryDark,
                            isLoading: bookingController.isLoading.value,
                            onPressed: () async {
                              final bookingData = {
                                'vendorId': widget.vendor.id,
                                'type': 'Vendor',
                                'service': _selectedService,
                                'date':
                                    _startDate?.toIso8601String() ??
                                    DateTime.now().toIso8601String(),
                                'endDate': _endDate?.toIso8601String(),
                                'notes': _notesController.text,
                                'price':
                                    0, // Should be set by vendor or fetched
                                'addedServices': _addedServices,
                              };

                              final success = await bookingController
                                  .createBooking(bookingData);
                              if (success) {
                                Get.back();
                                Get.back(); // Back to list
                              }
                            },
                            height: 56,
                            borderRadius: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildIconTextSmall(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: CommonText(
            text,
            fontSize: 12,
            color: AppColors.textSecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 14, fontWeight: FontWeight.w600),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderMedium),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                value,
                fontSize: 16,
                color: Colors.black.withValues(alpha: 0.6),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    String value, {
    required bool isStart,
    required Function setState,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 14, fontWeight: FontWeight.w600),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() {
                if (isStart) {
                  _startDate = date;
                } else {
                  _endDate = date;
                }
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderMedium),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  value,
                  fontSize: 14,
                  color: value == 'Select Date'
                      ? Colors.black.withValues(alpha: 0.4)
                      : Colors.black,
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
