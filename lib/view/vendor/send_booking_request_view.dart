import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/bookings/send_booking_request_controller.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              Obx(() => controller.isSummaryVisible.value ? _buildServiceSummary(controller) : const SizedBox.shrink()),
              const SizedBox(height: 24),
              // const CommonText('Services Included', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              // const SizedBox(height: 16),
              // _buildIncludedChips(controller),
              const SizedBox(height: 24),
              Obx(() {
                if (controller.isBraiding) return _buildBraidingForm(controller);
                if (controller.isClipping) return _buildClippingForm(controller);
                if (controller.isFarrier) return _buildFarrierForm(controller);
                if (controller.isBodywork) return _buildBodyworkForm(controller);
                if (controller.isShipping) return _buildShippingForm(controller);
                return _buildForm(controller);
              }),
              Obx(() => (controller.isBraiding || controller.isClipping || controller.isFarrier || controller.isBodywork || controller.isShipping) ? const SizedBox.shrink() : const SizedBox(height: 24)),
              Obx(() => (controller.isBraiding || controller.isClipping || controller.isFarrier || controller.isBodywork || controller.isShipping) ? const SizedBox.shrink() : _buildAdditionalServices(controller)),
              const SizedBox(height: 12),
              _buildAddServiceButton(controller),
              const SizedBox(height: 24),
              _buildSendButton(controller),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVendorSummary(SendBookingRequestController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 24),
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
                    const Icon(Icons.person_outline, color: AppColors.textSecondary, size: 12),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CommonText('Service Summary', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 14),
              label: const CommonText('Edit', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
            ),
          ],
        ),
        Obx(() => Column(
          children: [
            // List already added services
            ...controller.bookedServices.map((booking) {
              final duration = (booking['endDate'] as DateTime).difference(booking['startDate'] as DateTime).inDays + 1;
              final startDateStr = DateFormat('dd MMM').format(booking['startDate']);
              final endDateStr = DateFormat('dd MMM yyyy').format(booking['endDate']);
              
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
                        CommonText(
                          '${booking['serviceType']} ($duration ${duration > 1 ? 'Days' : 'Day'})', 
                          fontSize: 14, 
                          fontWeight: FontWeight.bold
                        ),
                        CommonText(currencyFormat.format(booking['basePrice']), fontSize: 14, fontWeight: FontWeight.bold),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        CommonText(booking['location'] ?? 'N/A', fontSize: 12, color: AppColors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        CommonText('$startDateStr - $endDateStr', fontSize: 12, color: AppColors.textSecondary),
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
            if (controller.selectedRateType.value != null && controller.startDate.value != null && controller.endDate.value != null) ...[
               _buildCurrentDraftSnippet(controller, currencyFormat),
            ]
          ],
        )),
      ],
    );
  }

  Widget _buildCurrentDraftSnippet(SendBookingRequestController controller, NumberFormat currencyFormat) {
     final duration = controller.endDate.value!.difference(controller.startDate.value!).inDays + 1;
     final startDateStr = DateFormat('dd MMM').format(controller.startDate.value!);
     final endDateStr = DateFormat('dd MMM yyyy').format(controller.endDate.value!);

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
              CommonText('$startDateStr - $endDateStr ($duration Days)', fontSize: 12, color: AppColors.textSecondary),
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
        const SizedBox(height: 24),
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
        _buildDropdownField('Number of Horses', 'Select Number of Horses', ['1', '2', '3', '4', '5'], controller.selectedNumHorses),
        const SizedBox(height: 20),
        // Location
        Obx(() => _buildDropdownField('Location', 'Select Location', controller.availableLocations, controller.selectedLocation, isLoading: controller.isLoadingAvailability.value)),
        const SizedBox(height: 20),
        // Start Date and End Date
        Row(
          children: [
            Expanded(child: _buildDateField('Start Date', 'Select Date', controller.startDate)),
            const SizedBox(width: 16),
            Expanded(child: _buildDateField('End Date', 'Select Date', controller.endDate)),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextField('Notes To Your Braider', 'Add a note for the service provider...', controller.notesController),
      ],
    );
  }

  Widget _buildClippingForm(SendBookingRequestController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
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
        _buildDropdownField('Number of Horses', 'Select Number of Horses', ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'], controller.selectedNumHorses),
        const SizedBox(height: 20),
        // Location
        Obx(() => _buildDropdownField('Location', 'Select Location', controller.availableLocations, controller.selectedLocation, isLoading: controller.isLoadingAvailability.value)),
        const SizedBox(height: 20),
        // Start Date and End Date
        Row(
          children: [
            Expanded(child: _buildDateField('Start Date', 'Select Date', controller.startDate)),
            const SizedBox(width: 16),
            Expanded(child: _buildDateField('End Date', 'Select Date', controller.endDate)),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextField('Notes To Your Clipping Service', 'Add a note for the service provider...', controller.notesController),
      ],
    );
  }

  Widget _buildFarrierForm(SendBookingRequestController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
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
        _buildDropdownField('Number of Horses', 'Select Number of Horses', ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'], controller.selectedNumHorses),
        const SizedBox(height: 20),
        // Location
        Obx(() => _buildDropdownField('Location', 'Select Location', controller.availableLocations, controller.selectedLocation, isLoading: controller.isLoadingAvailability.value)),
        const SizedBox(height: 20),
        // Start Date and End Date
        Row(
          children: [
            Expanded(child: _buildDateField('Start Date', 'Select Date', controller.startDate)),
            const SizedBox(width: 16),
            Expanded(child: _buildDateField('End Date', 'Select Date', controller.endDate)),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextField('Notes To Your Farrier', 'Add a note for the service provider...', controller.notesController),
      ],
    );
  }

  Widget _buildBodyworkForm(SendBookingRequestController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const CommonText('Select Service', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 16),
        Obx(() => Column(
          children: controller.coreServicesList.map((service) {
            final isSelected = controller.selectedCoreServiceIds.contains(service['id']);
            // Session info from naming or special data
            final String sessionInfo = service['session'] ?? '30 mins session:';
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _showSessionBottomSheet(controller, service),
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
                      CommonText('\$ ${service['price']}', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        const SizedBox(height: 12),
        // Number of Horses
        _buildDropdownField('Number of Horses', 'Select Number of Horses', ['1', '2', '3', '4', '5'], controller.selectedNumHorses),
        const SizedBox(height: 20),
        // Location
        Obx(() => _buildDropdownField('Location', 'Select Location', controller.availableLocations, controller.selectedLocation, isLoading: controller.isLoadingAvailability.value)),
        const SizedBox(height: 20),
        // Start Date and End Date
        Row(
          children: [
            Expanded(child: _buildDateField('Start Date', 'Select Date', controller.startDate)),
            const SizedBox(width: 16),
            Expanded(child: _buildDateField('End Date', 'Select Date', controller.endDate)),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextField('Notes To Your Bodywork Specialist', 'Add a note for the service provider...', controller.notesController),
      ],
    );
  }

  void _showSessionBottomSheet(SendBookingRequestController controller, Map<String, dynamic> service) {
    // Session options (Mocking for now as shown in image)
    final sessions = [
      {'label': '30 mins', 'price': 150},
      {'label': '45 mins', 'price': 250},
      {'label': '60 mins', 'price': 300},
      {'label': '90 mins', 'price': 450},
    ];
    
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
            ...sessions.map((session) {
              final isThis = service['session'] == session['label'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    // Update controller/service state
                    controller.toggleCoreService(service['id']);
                    Get.back();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isThis ? const Color(0xFF00083B) : const Color(0xFFE4E7EC), width: isThis ? 2 : 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(isThis ? Icons.radio_button_checked : Icons.radio_button_off, 
                                 color: isThis ? const Color(0xFF00083B) : Colors.grey, size: 20),
                            const SizedBox(width: 12),
                            CommonText(session['label'].toString(), fontSize: 14, fontWeight: isThis ? FontWeight.bold : FontWeight.normal),
                          ],
                        ),
                        CommonText('\$ ${session['price']}', fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF8B4242)),
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
        const SizedBox(height: 24),
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
                      CommonText('\$ ${service['price']} / per mile', fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF8B4242)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        const SizedBox(height: 12),
        // Number of Horses
        _buildDropdownField('Number of Horses', 'Select Number of Horses', ['1', '2', '3', '4', '5'], controller.selectedNumHorses),
        const SizedBox(height: 20),
        // Origin Location
        _buildTextFieldWithLabel('Origin Location', 'Enter Location', controller.notesController),
        const SizedBox(height: 20),
        // Destination Location
        _buildTextFieldWithLabel('Destination location', 'Enter Location', controller.notesController),
        const SizedBox(height: 20),
        // Start Date and End Date
        Row(
          children: [
            Expanded(child: _buildDateField('Start Date', 'Select Date', controller.startDate)),
            const SizedBox(width: 16),
            Expanded(child: _buildDateField('End Date', 'Select Date', controller.endDate)),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextField('Notes To Your Shipper', 'Add a note for the service provider...', controller.notesController),
      ],
    );
  }

  Widget _buildForm(SendBookingRequestController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRateDropdownField(controller),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildDateField('Start Date', 'Select Date', controller.startDate)),
            const SizedBox(width: 16),
            Expanded(child: _buildDateField('End Date', 'Select Date', controller.endDate)),
          ],
        ),
        const SizedBox(height: 20),
        _buildDropdownField(
          'Number Of Horses', 
          'Select', 
          ['1', '2', '3', '4', '5'],
          controller.selectedNumHorses,
        ),
        const SizedBox(height: 20),
        Obx(() => _buildDropdownField(
          'Location', 
          'Select Location', 
          controller.availableLocations,
          controller.selectedLocation,
          isLoading: controller.isLoadingAvailability.value,
        )),
        const SizedBox(height: 20),
        _buildTextField('Notes to your Groom', 'Add a note for the service provider...', controller.notesController),
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

  Widget _buildDropdownField(String label, String hint, List<String> options, RxnString selectedValue, {bool isLoading = false}) {
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
                  onChanged: (val) => selectedValue.value = val,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, String hint, Rxn<DateTime> dateObs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        Obx(() => GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: Get.context!,
              initialDate: dateObs.value ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) dateObs.value = date;
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
                  dateObs.value != null ? DateFormat('MM/dd/yyyy').format(dateObs.value!) : hint,
                  fontSize: 14,
                  color: dateObs.value != null ? AppColors.textPrimary : const Color(0xFF98A2B3),
                ),
                const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF98A2B3)),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
              border: InputBorder.none,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
              border: InputBorder.none,
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => controller.sendRequest(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00083B),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const CommonText('Send Request', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
