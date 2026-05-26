import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/bookings/send_booking_request_controller.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/google_api_controller.dart';
import '../../widgets/common_button.dart';

class SendBookingRequestView extends StatelessWidget {
  const SendBookingRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SendBookingRequestController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Send Booking Request', fontSize: AppTextSizes.size20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildVendorSummary(controller),
              const SizedBox(height: 16),
              Obx(() => controller.bookedServices.isNotEmpty 
                ? Column(
                    children: [
                      _buildServiceSummary(controller),
                      const SizedBox(height: 16),
                    ],
                  ) 
                : const SizedBox.shrink()),
              Obx(() {
                if (controller.isBraiding) return _buildBraidingForm(controller);
                if (controller.isClipping) return _buildClippingForm(controller);
                if (controller.isFarrier) return _buildFarrierForm(controller);
                if (controller.isBodywork) return _buildBodyworkForm(controller);
                if (controller.isShipping) return _buildShippingForm(controller);
                return _buildForm(controller);
              }),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _horseCapacityBannerIfNeeded(SendBookingRequestController controller) {
    return Obx(() {
      controller.startDate.value;
      controller.endDate.value;
      final loc =
          controller.isShipping ? controller.selectedOrigin.value : controller.selectedLocation.value;
      if (!controller.isHorseCapacityExhaustedFor(loc)) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.errorBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.errorBorder),
          ),
          child: const CommonText(
            AppStrings.availabilityFullyBookedHorses,
            fontSize: AppTextSizes.size12,
            color: AppColors.errorPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    });
  }

  Widget _buildVendorSummary(SendBookingRequestController controller) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: CommonImageView(url: controller.profilePhoto, fit: BoxFit.cover, isUserImage: true),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(controller.vendorFullName, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                const SizedBox(height: 2),
                CommonText(controller.businessName, fontSize: AppTextSizes.size12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.textSecondary, size: 12),
                    const SizedBox(width: 4),
                    Expanded(child: CommonText(controller.locationStr, fontSize: AppTextSizes.size12, color: AppColors.textSecondary, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    SvgPicture.asset("assets/icons/badge.svg"),
                    const SizedBox(width: 4),
                    Expanded(child: CommonText(controller.selectedService.value, fontSize: AppTextSizes.size12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSummary(SendBookingRequestController controller) {
    final currencyFormat = NumberFormat.currency(symbol: '\$ ');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Service Summary', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
        const SizedBox(height: 12),



        Obx(() => Column(
          children: [
            // List already added services
            ...controller.bookedServices.map((booking) {
              final startDt = booking['startDate'] as DateTime;
              final endDt = booking['endDate'] as DateTime;
              final duration = endDt.difference(startDt).inDays + 1;
              final sameCalendarDay =
                  startDt.year == endDt.year && startDt.month == endDt.month && startDt.day == endDt.day;
              final dateLabel = sameCalendarDay
                  ? DateFormat('MMMM d, yyyy').format(startDt)
                  : '${DateFormat('MMMM d').format(startDt)} - ${DateFormat('MMMM d, yyyy').format(endDt)}';
              
              return Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE4E7EC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CommonText(
                            '${booking['serviceType']} ($duration ${duration > 1 ? 'Days' : 'Day'})', 
                            fontSize: 14, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Row(
                          children: [
                            CommonText(currencyFormat.format(booking['basePrice']), fontSize: 14, fontWeight: FontWeight.bold),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => controller.editService(controller.bookedServices.indexOf(booking)),
                              child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        CommonText(booking['location'] ?? '', fontSize: 12, color: AppColors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        CommonText(dateLabel, fontSize: 12, color: AppColors.textSecondary),
                      ],
                    ),
                    if ((booking['additionalIds'] as List).isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: Color(0xFFE4E7EC)),
                      const SizedBox(height: 8),
                      const CommonText('Additional Services', fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                      ...(booking['additionalIds'] as List).map((id) {
                        final service = controller.additionalServicesList.firstWhere((s) => s['id'] == id, orElse: () => {'name': id, 'price': 0.0});
                        final numHorses = int.tryParse(booking['horses']?.toString() ?? '1') ?? 1;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               CommonText('${service['name']} ($numHorses ${numHorses > 1 ? 'Horses' : 'Horse'})', fontSize: 13, fontWeight: FontWeight.w600),
                               CommonText(currencyFormat.format((double.tryParse(service['price']?.toString() ?? '0') ?? 0.0) * numHorses), fontSize: 13, fontWeight: FontWeight.bold),
                            ],
                          ),
                        );
                      }),
                    ]
                  ],
                ),
              );
            }),
            
            // Current Draft Service (only if partially filled)
            if (controller.startDate.value != null &&
                controller.endDate.value != null &&
                (controller.selectedRateType.value != null ||
                    controller.selectedCoreServiceIds.isNotEmpty)) ...[
              _buildCurrentDraftSnippet(controller, currencyFormat),
            ]
          ],
        )),
      ],
    );
  }

  Widget _buildCurrentDraftSnippet(SendBookingRequestController controller, NumberFormat currencyFormat) {
    final startDt = controller.startDate.value!;
    final endDt = controller.endDate.value!;
    final duration = endDt.difference(startDt).inDays + 1;
    final sameCalendarDay =
        startDt.year == endDt.year && startDt.month == endDt.month && startDt.day == endDt.day;
    final dateLine = sameCalendarDay
        ? '${DateFormat('MMMM d, yyyy').format(startDt)} (${duration == 1 ? '1 Day' : '$duration Days'})'
        : '${DateFormat('MMMM d').format(startDt)} - ${DateFormat('MMMM d, yyyy').format(endDt)} ($duration ${duration > 1 ? 'Days' : 'Day'})';

    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText(
                    '${controller.selectedService.value} (DRAFT)', 
                    fontSize: 14, 
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  CommonText(currencyFormat.format(controller.basePrice.value), fontSize: 14, fontWeight: FontWeight.bold),
                ],
              ),
              const SizedBox(height: 8),
              CommonText(dateLine, fontSize: 12, color: AppColors.textSecondary),
            ],
          ),
        );
  }

  Widget _buildIncludedChips(SendBookingRequestController controller) {
    if (controller.includedServices.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: controller.includedServices.map((service) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: CommonText(service, fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF475467)),
      )).toList(),
    );
  }

  Widget _buildBraidingForm(SendBookingRequestController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Select Service', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),

        const SizedBox(height: 16),
        Obx(() => Column(
          children: controller.coreServicesList.map((service) {
            final isSelected = controller.selectedCoreServiceIds.contains(service['id']);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => controller.toggleCoreService(service['id']),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00083B) : const Color(0xFFE4E7EC),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF00083B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isSelected ? const Color(0xFF00083B) : const Color(0xFFD0D5DD), width: 2),
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CommonText(service['name'], fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      CommonText('\$ ${service['price']} / horse', fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF8B4242)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        const SizedBox(height: 12),
        // Number of Horses
        Obx(() {
          controller.startDate.value;
          controller.endDate.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownField(
                'Number of Horses',
                'Select Number of Horses',
                controller.getHorseOptionsForLocation(controller.selectedLocation.value),
                controller.selectedNumHorses,
              ),
              _horseCapacityBannerIfNeeded(controller),
            ],
          );
        }),
        const SizedBox(height: 20),
        // Location
        Obx(() => _buildDropdownField(
          'Location', 
          'Select Location', 
          controller.availableLocations, 
          controller.selectedLocation, 
          isLoading: controller.isLoadingAvailability.value,
          onChanged: (val) {
            controller.startDate.value = null;
            controller.endDate.value = null;
            controller.selectedNumHorses.value = null;
          }
        )),
        const SizedBox(height: 20),
        _buildSingleDateField(controller),
        const SizedBox(height: 20),
        _buildTextField('Notes To Your Braider', 'Add a note for the service provider...', controller.notesController),
        const SizedBox(height: 24),
        _buildAddServiceButton(controller),
        const SizedBox(height: 24),
        _buildSendButton(controller),
      ],
    );
  }

  Widget _buildClippingForm(SendBookingRequestController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Select Service', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),

        const SizedBox(height: 16),
        Obx(() => Column(
          children: controller.coreServicesList.map((service) {
            final isSelected = controller.selectedCoreServiceIds.contains(service['id']);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => controller.toggleCoreService(service['id']),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00083B) : const Color(0xFFE4E7EC),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF00083B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isSelected ? const Color(0xFF00083B) : const Color(0xFFD0D5DD), width: 2),
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CommonText(service['name'], fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      CommonText('\$ ${service['price']} / horse', fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF8B4242)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        const SizedBox(height: 12),
        // Number of Horses
        Obx(() {
          controller.startDate.value;
          controller.endDate.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownField(
                'Number of Horses',
                'Select Number of Horses',
                controller.getHorseOptionsForLocation(controller.selectedLocation.value),
                controller.selectedNumHorses,
              ),
              _horseCapacityBannerIfNeeded(controller),
            ],
          );
        }),
        const SizedBox(height: 20),
        // Location
        Obx(() => _buildDropdownField(
          'Location', 
          'Select Location', 
          controller.availableLocations, 
          controller.selectedLocation, 
          isLoading: controller.isLoadingAvailability.value,
          onChanged: (val) {
            controller.startDate.value = null;
            controller.endDate.value = null;
            controller.selectedNumHorses.value = null;
          }
        )),
        const SizedBox(height: 20),
        // Date Range
        _buildDateRangeField(controller),
        const SizedBox(height: 20),
        _buildTextField('Notes To Your Clipping Service', 'Add a note for the service provider...', controller.notesController),
        const SizedBox(height: 24),
        _buildAddServiceButton(controller),
        const SizedBox(height: 24),
        _buildSendButton(controller),
      ],
    );
  }

  Widget _buildFarrierForm(SendBookingRequestController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Select Service', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),

        const SizedBox(height: 16),
        Obx(() => Column(
          children: controller.coreServicesList.map((service) {
            final isSelected = controller.selectedCoreServiceIds.contains(service['id']);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => controller.toggleCoreService(service['id']),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00083B) : const Color(0xFFE4E7EC),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF00083B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isSelected ? const Color(0xFF00083B) : const Color(0xFFD0D5DD), width: 2),
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CommonText(service['name'], fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      CommonText('\$ ${service['price']} / horse', fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF8B4242)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        const SizedBox(height: 12),
        // Number of Horses
        Obx(() {
          controller.startDate.value;
          controller.endDate.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownField(
                'Number of Horses',
                'Select Number of Horses',
                controller.getHorseOptionsForLocation(controller.selectedLocation.value),
                controller.selectedNumHorses,
              ),
              _horseCapacityBannerIfNeeded(controller),
            ],
          );
        }),
        const SizedBox(height: 20),
        // Location
        Obx(() => _buildDropdownField(
          'Location', 
          'Select Location', 
          controller.availableLocations, 
          controller.selectedLocation, 
          isLoading: controller.isLoadingAvailability.value,
          onChanged: (val) {
            controller.startDate.value = null;
            controller.endDate.value = null;
            controller.selectedNumHorses.value = null;
          }
        )),
        const SizedBox(height: 20),
        // Date Range
        _buildDateRangeField(controller),
        const SizedBox(height: 20),
        _buildTextField('Notes To Your Farrier', 'Add a note for the service provider...', controller.notesController),
        const SizedBox(height: 24),
        _buildAddServiceButton(controller),
        const SizedBox(height: 24),
        _buildSendButton(controller),
      ],
    );
  }

  Widget _buildBodyworkForm(SendBookingRequestController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Select Service', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),

        const SizedBox(height: 16),
        Obx(() => Column(
          children: controller.coreServicesList.map((service) {
            final Map rates = service['rates'] ?? {};
            final activeRates = rates.entries
                .where((e) => e.value != null && e.value.toString().isNotEmpty)
                .toList();
            
            final selectedSessionId = controller.selectedCoreServiceIds.firstWhereOrNull((sid) => sid.startsWith('${service['id']}_'));
            final isSelected = controller.selectedCoreServiceIds.contains(service['id']) || selectedSessionId != null;
            
            String sessionInfo = 'Choose session';
            if (activeRates.length == 1) {
              sessionInfo = '${activeRates.first.key} mins';
            } else if (selectedSessionId != null) {
              final duration = selectedSessionId.split('_')[1];
              sessionInfo = '$duration mins session';
            } else if (activeRates.length > 1) {
              sessionInfo = '${activeRates.length} sessions available';
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  if (activeRates.length == 1) {
                    controller.toggleCoreService(service['id']);
                  } else {
                    _showSessionBottomSheet(controller, service);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00083B) : const Color(0xFFE4E7EC),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF00083B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isSelected ? const Color(0xFF00083B) : const Color(0xFFD0D5DD), width: 2),
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(service['name'], fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            CommonText(sessionInfo, fontSize: 12, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                      if (activeRates.length == 1)
                        CommonText('\$ ${activeRates.first.value}', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                      else if (selectedSessionId != null)
                        CommonText('\$ ${rates[selectedSessionId.split('_')[1]]}', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                      else if (activeRates.length > 1)
                        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        const SizedBox(height: 12),
        // Number of Horses
        Obx(() {
          controller.startDate.value;
          controller.endDate.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownField(
                'Number of Horses',
                'Select Number of Horses',
                controller.getHorseOptionsForLocation(controller.selectedLocation.value),
                controller.selectedNumHorses,
              ),
              _horseCapacityBannerIfNeeded(controller),
            ],
          );
        }),
        const SizedBox(height: 20),
        // Location
        Obx(() => _buildDropdownField(
          'Location', 
          'Select Location', 
          controller.availableLocations, 
          controller.selectedLocation, 
          isLoading: controller.isLoadingAvailability.value,
          onChanged: (val) {
            controller.startDate.value = null;
            controller.endDate.value = null;
            controller.selectedNumHorses.value = null;
          }
        )),
        const SizedBox(height: 20),
        // Date Range
        _buildDateRangeField(controller),
        const SizedBox(height: 20),
        _buildTextField('Notes To Your Bodywork Specialist', 'Add a note for the service provider...', controller.notesController),
        const SizedBox(height: 24),
        _buildAddServiceButton(controller),
        const SizedBox(height: 24),
        _buildSendButton(controller),
      ],
    );
  }

  void _showSessionBottomSheet(SendBookingRequestController controller, Map<String, dynamic> service) {
    final Map rates = service['rates'] ?? {};
    final activeRates = rates.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty)
        .toList()
      ..sort((a, b) {
        final aVal = int.tryParse(a.key.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bVal = int.tryParse(b.key.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return aVal.compareTo(bVal);
      });
    
    if (activeRates.isEmpty) return;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonText('Choose Session', fontSize: 20, fontWeight: FontWeight.bold),
            const SizedBox(height: 24),
            ...activeRates.map((rate) {
              final isSelected = controller.selectedCoreServiceIds.contains('${service['id']}_${rate.key}');
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    // Use a unique ID for the specific session
                    controller.toggleCoreService('${service['id']}_${rate.key}');
                    Get.back();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? const Color(0xFF00083B) : const Color(0xFFE4E7EC), width: isSelected ? 2 : 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, 
                                 color: isSelected ? const Color(0xFF00083B) : Colors.grey, size: 20),
                            const SizedBox(width: 12),
                            CommonText('${rate.key} mins', fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                          ],
                        ),
                        CommonText('\$ ${rate.value}', fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF8B4242)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildShippingForm(SendBookingRequestController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Select Service', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),

        const SizedBox(height: 16),
        Obx(() => Column(
          children: controller.coreServicesList.map((service) {
            final isSelected = controller.selectedCoreServiceIds.contains(service['id']);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => controller.toggleCoreService(service['id']),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00083B) : const Color(0xFFE4E7EC),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF00083B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isSelected ? const Color(0xFF00083B) : const Color(0xFFD0D5DD), width: 2),
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CommonText(service['name'], fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      CommonText('\$ ${service['price']} / ', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.secondary),
                      CommonText('per mile', fontSize: 14,),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        const SizedBox(height: 12),
        // Number of Horses
        Obx(() {
          controller.startDate.value;
          controller.endDate.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownField(
                'Number of Horses',
                'Select Number of Horses',
                controller.getHorseOptionsForLocation(controller.selectedOrigin.value),
                controller.selectedNumHorses,
              ),
              _horseCapacityBannerIfNeeded(controller),
            ],
          );
        }),
        const SizedBox(height: 20),
        
        // Origin Location
        LocationSearchField(
          label: 'Origin Location',
          hint: 'Search Origin',
          selectedValue: controller.selectedOrigin,
          bookingRequestController: controller,
          isOrigin: true,
        ),
        const SizedBox(height: 16),

        // Intermediate Stops
        // Obx(() => Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     if (controller.intermediateStops.isNotEmpty) ...[
        //       const CommonText('Intermediate Stops', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        //       const SizedBox(height: 8),
        //       ...controller.intermediateStops.asMap().entries.map((entry) {
        //         final index = entry.key;
        //         final stopValue = entry.value;
        //
        //         final stopObs = RxnString(stopValue.isEmpty ? null : stopValue);
        //
        //         return Padding(
        //           padding: const EdgeInsets.only(bottom: 12),
        //           child: Row(
        //             children: [
        //               Expanded(
        //                 child: LocationSearchField(
        //                   label: '',
        //                   hint: 'Select Stop ${index + 1}',
        //                   selectedValue: stopObs,
        //                   anchorLocation: stopValue,
        //                   onChanged: (val) {
        //                     controller.intermediateStops[index] = val ?? '';
        //                   }
        //                 ),
        //               ),
        //               const SizedBox(width: 8),
        //               Padding(
        //                 padding: const EdgeInsets.only(top: 8.0),
        //                 child: IconButton(
        //                   onPressed: () => controller.removeIntermediateStop(index),
        //                   icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         );
        //       }),
        //     ],
        //     GestureDetector(
        //       onTap: () => controller.addIntermediateStop(),
        //       child: Padding(
        //         padding: const EdgeInsets.symmetric(vertical: 8),
        //         child: Row(
        //           children: const [
        //             Icon(Icons.add_circle_outline, color: AppColors.primary, size: 18),
        //             SizedBox(width: 8),
        //             CommonText('Add Intermediate Stop', color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
        //           ],
        //         ),
        //       ),
        //     ),
        //     const SizedBox(height: 16),
        //   ],
        // )),

        // Destination Location
        LocationSearchField(
          label: 'Destination Location',
          hint: 'Search Destination',
          selectedValue: controller.selectedDestination,
          bookingRequestController: controller,
          isDestination: true,
        ),
        const SizedBox(height: 16),

        // Date Range
        _buildDateRangeField(controller, locationObs: controller.selectedOrigin),
        const SizedBox(height: 16),
        _buildTextField('Notes To Your Shipper', 'Add a note for the service provider...', controller.notesController),
        const SizedBox(height: 24),
        _buildAddServiceButton(controller),
        const SizedBox(height: 24),
        _buildSendButton(controller),
      ],
    );
  }

  Widget _buildForm(SendBookingRequestController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRateDropdownField(controller),
        // Date Range
        const SizedBox(height: 20),
        _buildDateRangeField(controller),
        const SizedBox(height: 20),
        Obx(() {
          controller.startDate.value;
          controller.endDate.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownField(
                'Number Of Horses',
                'Select',
                controller.getHorseOptionsForLocation(controller.selectedLocation.value),
                controller.selectedNumHorses,
              ),
              _horseCapacityBannerIfNeeded(controller),
            ],
          );
        }),
        const SizedBox(height: 20),
        Obx(() => _buildDropdownField(
          'Location', 
          'Select Location', 
          controller.availableLocations,
          controller.selectedLocation,
          isLoading: controller.isLoadingAvailability.value,
          onChanged: (val) {
            controller.startDate.value = null;
            controller.endDate.value = null;
            controller.selectedNumHorses.value = null;
          },
        )),
        const SizedBox(height: 20),
        _buildTextField('Notes to your Groom', 'Add a note for the service provider...', controller.notesController),
        const SizedBox(height: 24),
        _buildAdditionalServices(controller),
        const SizedBox(height: 24),
        _buildAddServiceButton(controller),
        const SizedBox(height: 24),
        _buildSendButton(controller),
      ],
    );
  }

  Widget _buildRateDropdownField(SendBookingRequestController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Rate Type', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: controller.selectedRateType.value,
              hint: const CommonText('Select Rate Type', color: Color(0xFF98A2B3), fontSize: 14),
              items: controller.rateOptions.map((opt) => DropdownMenuItem<String>(
                value: opt['label'],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText(opt['label'], fontSize: 14, color: const Color(0xFF667085)),
                    CommonText(opt['price'], fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF8B4242)),
                  ],
                ),
              )).toList(),
              onChanged: (val) => controller.selectedRateType.value = val,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, List<String> options, RxnString selectedValue, {bool isLoading = false, void Function(String?)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 52, // Fixed height for consistency
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: isLoading 
            ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)))
            : DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: (options.contains(selectedValue.value)) ? selectedValue.value : null,
                  hint: CommonText(hint, color: const Color(0xFF98A2B3), fontSize: 14),
                  items: options.map((o) => DropdownMenuItem(value: o, child: CommonText(o, fontSize: 14))).toList(),
                  onChanged: (val) {
                    selectedValue.value = val;
                    if (onChanged != null) onChanged(val);
                  },
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                ),
              ),
        ),
      ],
    );
  }

  String? _locationForAcceptedDateBlocking(
    SendBookingRequestController controller,
    RxnString? locationObs,
  ) {
    if (locationObs != null) return locationObs.value;
    return controller.isShipping
        ? controller.selectedOrigin.value
        : controller.selectedLocation.value;
  }

  Widget _buildDateRangeField(SendBookingRequestController controller, {RxnString? locationObs}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Select Date Range', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        Obx(() {
          controller.acceptedBookingWindows.length;
          controller.selectedService.value;
          controller.selectedLocation.value;
          controller.selectedOrigin.value;
          if (locationObs != null) locationObs.value;

          final startDate = controller.startDate.value;
          final endDate = controller.endDate.value;
          String displayDate = 'Select Date Range';
          if (startDate != null && endDate != null) {
            displayDate = '${DateFormat('MMMM d, yyyy').format(startDate)} - ${DateFormat('MMMM d, yyyy').format(endDate)}';
          }

          return GestureDetector(
            onTap: () async {
              final allowedDates = controller.getAllowedDatesForLocation(locationObs?.value ?? controller.selectedLocation.value);
              final DateTime now = DateTime.now();
              final DateTime today = DateTime(now.year, now.month, now.day);

              DateTime first = allowedDates['start'] ?? today;
              DateTime last = allowedDates['end'] ?? today.add(const Duration(days: 365));

              // Adjust firstDate if it's in the past
              if (first.isBefore(today)) {
                first = today;
              }

              // Ensure initial range is valid within first/last
              DateTimeRange? initialRange;
              if (startDate != null && endDate != null) {
                if (!startDate.isBefore(first) && !endDate.isAfter(last)) {
                  initialRange = DateTimeRange(start: startDate, end: endDate);
                }
              }

              final locBlock = _locationForAcceptedDateBlocking(controller, locationObs);

              final DateTimeRange? picked = await showDateRangePicker(
                context: Get.context!,
                firstDate: first,
                lastDate: last.isBefore(first) ? first.add(const Duration(days: 1)) : last,
                initialDateRange: initialRange,
                selectableDayPredicate: (DateTime day, DateTime? rangeStart, DateTime? rangeEnd) =>
                    !controller.isDateBlockedByAcceptedBooking(day, locBlock),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: AppColors.textPrimary,
                      ),
                      datePickerTheme: DatePickerThemeData(
                        rangeSelectionBackgroundColor: AppColors.primary.withOpacity(0.15),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (picked != null) {
                controller.startDate.value = picked.start;
                controller.endDate.value = picked.end;
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE4E7EC)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText(
                    displayDate,
                    fontSize: 14,
                    color: (startDate != null && endDate != null) ? AppColors.textPrimary : const Color(0xFF98A2B3),
                  ),
                  const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF98A2B3)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Braiding is booked for a single day; [startDate] and [endDate] are both set to that day.
  Widget _buildSingleDateField(SendBookingRequestController controller, {RxnString? locationObs}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText(
          'Select Date',
          fontSize: AppTextSizes.size14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 8),
        Obx(() {
          controller.acceptedBookingWindows.length;
          controller.selectedService.value;
          controller.selectedLocation.value;
          controller.selectedOrigin.value;
          if (locationObs != null) locationObs.value;

          final startDate = controller.startDate.value;
          final endDate = controller.endDate.value;
          final hasSingleDay = startDate != null &&
              endDate != null &&
              startDate.year == endDate.year &&
              startDate.month == endDate.month &&
              startDate.day == endDate.day;
          final displayDate =
              hasSingleDay ? DateFormat('MMMM d, yyyy').format(startDate) : 'Select Date';

          return GestureDetector(
            onTap: () async {
              final allowedDates =
                  controller.getAllowedDatesForLocation(locationObs?.value ?? controller.selectedLocation.value);
              final DateTime now = DateTime.now();
              final DateTime today = DateTime(now.year, now.month, now.day);

              DateTime first = allowedDates['start'] ?? today;
              DateTime last = allowedDates['end'] ?? today.add(const Duration(days: 365));

              if (first.isBefore(today)) {
                first = today;
              }

              DateTime initialDate = first;
              if (hasSingleDay) {
                final d = DateTime(startDate.year, startDate.month, startDate.day);
                if (!d.isBefore(first) && !d.isAfter(last)) {
                  initialDate = d;
                }
              }

              final locBlock = _locationForAcceptedDateBlocking(controller, locationObs);

              final DateTime? picked = await showDatePicker(
                context: Get.context!,
                initialDate: initialDate.isBefore(first)
                    ? first
                    : (initialDate.isAfter(last) ? last : initialDate),
                firstDate: first,
                lastDate: last.isBefore(first) ? first.add(const Duration(days: 1)) : last,
                selectableDayPredicate: (dt) =>
                    !controller.isDateBlockedByAcceptedBooking(dt, locBlock),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: AppColors.textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (picked != null) {
                final d = DateTime(picked.year, picked.month, picked.day);
                controller.startDate.value = d;
                controller.endDate.value = d;
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE4E7EC)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText(
                    displayDate,
                    fontSize: 14,
                    color: hasSingleDay ? AppColors.textPrimary : const Color(0xFF98A2B3),
                  ),
                  const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF98A2B3)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
            contentPadding: const EdgeInsets.all(16),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldWithLabel(String label, String hint, TextEditingController fieldController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        TextFormField(
          controller: fieldController,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalServices(SendBookingRequestController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Select Additional Services', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 16),
        Obx(() => Column(
          children: controller.additionalServicesList.map((service) {
            final isSelected = controller.selectedAdditionalIds.contains(service['id']);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => controller.toggleAdditionalService(service['id']),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00083B) : const Color(0xFFE4E7EC),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF00083B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isSelected ? const Color(0xFF00083B) : const Color(0xFFD0D5DD), width: 2),
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CommonText(service['name'], fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      CommonText('\$ ${service['price']} / horse', fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF8B4242)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildAddServiceButton(SendBookingRequestController controller) {
    return InkWell(
      onTap: () => controller.addServiceToSummary(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          Icon(Icons.add, color: AppColors.linkBlue, size: 18),
          SizedBox(width: 4),
          CommonText('Add Service', color: AppColors.linkBlue, fontSize: 14, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  Widget _buildSendButton(SendBookingRequestController controller) {
    return Obx(() => CommonButton(
      text: 'Send Request',
      isLoading: controller.isSending.value,
      backgroundColor: const Color(0xFF00083B),
      onPressed: () => controller.sendRequest(),
    ));
  }
}

class LocationSearchField extends StatefulWidget {
  final String label;
  final String hint;
  final RxnString selectedValue;
  final String? anchorLocation;
  final void Function(String?)? onChanged;
  final bool isOrigin;
  final bool isDestination;
  final SendBookingRequestController bookingRequestController;

  const LocationSearchField({
    super.key,
    required this.label,
    required this.hint,
    required this.selectedValue,
    required this.bookingRequestController,
    this.anchorLocation,
    this.onChanged,
    this.isOrigin = false,
    this.isDestination = false,
  });

  @override
  State<LocationSearchField> createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<LocationSearchField> {
  final googleController = Get.put(GoogleApiController());
  late final TextEditingController textController;
  final focusNode = FocusNode();
  final isFocused = false.obs;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.selectedValue.value);
    focusNode.addListener(() {
      isFocused.value = focusNode.hasFocus;
    });
    
    // Update text field if selectedValue changes from outside
    ever(widget.selectedValue, (String? val) {
       if (val != textController.text) {
          textController.text = val ?? '';
       }
    });
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          CommonText(
            widget.label,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: textController,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          onChanged: (val) {
            widget.selectedValue.value = val;
            if (widget.onChanged != null) widget.onChanged!(val);

            // Fetch coords for radius search
            String? coords;
            if (widget.isOrigin) {
               for (var avail in widget.bookingRequestController.availabilityList) {
                  if (avail['originCoords'] != null) {
                     final c = avail['originCoords']['coordinates'];
                     coords = '${c[1]},${c[0]}';
                     break;
                  }
               }
            } else if (widget.isDestination) {
               for (var avail in widget.bookingRequestController.availabilityList) {
                  if (avail['destinationCoords'] != null) {
                     final c = avail['destinationCoords']['coordinates'];
                     coords = '${c[1]},${c[0]}';
                     break;
                  }
               }
            } else {
               coords = widget.bookingRequestController.getCoordsForLocation(widget.anchorLocation);
            }

            googleController.searchGooglePlaces(
              val,
              location: coords,
              radius: 241402, // 150 miles
            );
          },
        ),
        Obx(() {
          if (!isFocused.value) return const SizedBox.shrink();
          
          final suggestions = googleController.googleSuggestions;
          final available = widget.bookingRequestController.availableLocations.where((l) =>
            l.toLowerCase().contains(textController.text.toLowerCase())).toList();

          if (suggestions.isEmpty && available.isEmpty) return const SizedBox.shrink();

          // Get coords to check if we should show Google suggestions
          String? coords;
          if (widget.isOrigin) {
             for (var avail in widget.bookingRequestController.availabilityList) {
                if (avail['originCoords'] != null) {
                   final c = avail['originCoords']['coordinates'];
                   coords = '${c[1]},${c[0]}';
                   break;
                }
             }
          } else if (widget.isDestination) {
             for (var avail in widget.bookingRequestController.availabilityList) {
                if (avail['destinationCoords'] != null) {
                   final c = avail['destinationCoords']['coordinates'];
                   coords = '${c[1]},${c[0]}';
                   break;
                }
             }
          } else {
             coords = widget.bookingRequestController.getCoordsForLocation(widget.anchorLocation);
          }

          final showGoogle = coords != null;

          return Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE4E7EC)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
            ),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                if (available.isNotEmpty)
                  ...available.map((l) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                    title: CommonText(l, fontSize: 13),
                    onTap: () {
                      textController.text = l;
                      widget.selectedValue.value = l;
                      if (widget.onChanged != null) widget.onChanged!(l);
                      focusNode.unfocus();
                    },
                  )),
                if (showGoogle && suggestions.isNotEmpty)
                  ...suggestions.map((s) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                    title: CommonText(s['name'] ?? '', fontSize: 13),
                    onTap: () {
                      textController.text = s['name'] ?? '';
                      widget.selectedValue.value = s['name'];
                      if (widget.onChanged != null) widget.onChanged!(s['name']);
                      focusNode.unfocus();
                    },
                  )),
              ],
            ),
          );
        }),
      ],
    );
  }
}
