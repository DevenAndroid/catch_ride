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
              const SizedBox(height: 24),
              const CommonText('Services Included', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              const SizedBox(height: 16),
              _buildIncludedChips(controller),
              const SizedBox(height: 24),
              _buildForm(controller),
              const SizedBox(height: 24),
              _buildAdditionalServices(controller),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: CommonImageView(url: controller.profilePhoto, fit: BoxFit.cover, isUserImage: true),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(controller.vendorFullName, fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
                const SizedBox(height: 2),
                CommonText(controller.businessName, fontSize: AppTextSizes.size14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: 4),
                    Expanded(child: CommonText(controller.locationStr, fontSize: AppTextSizes.size12, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.person_outline, color: AppColors.textSecondary, size: 14),
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

  Widget _buildIncludedChips(SendBookingRequestController controller) {
    if (controller.includedServices.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: controller.includedServices.map((service) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: CommonText(service, fontSize: AppTextSizes.size14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
      )).toList(),
    );
  }

  Widget _buildForm(SendBookingRequestController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownField(
          'Rate Type', 
          'Select Rate Type', 
          ['Day Rate', 'Week Rate', 'Month Rate'],
          controller.selectedRateType,
        ),
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
          ['1', '2', '3', '4', '5+'],
          controller.selectedNumHorses,
        ),
        const SizedBox(height: 20),
        _buildDropdownField(
          'Location', 
          'WEF, Wellington', 
          ['WEF, Wellington', 'Ocala, WEC', 'Other'],
          controller.selectedLocation,
        ),
        const SizedBox(height: 20),
        _buildTextField('Notes to your Groom', 'Add a note for the service provider...', controller.notesController),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, List<String> options, RxnString selectedValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedValue.value,
              hint: CommonText(hint, color: Colors.grey, fontSize: 14),
              items: options.map((o) => DropdownMenuItem(value: o, child: CommonText(o, fontSize: 14))).toList(),
              onChanged: (val) => selectedValue.value = val,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, String hint, Rxn<DateTime> dateObs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  dateObs.value != null ? DateFormat('MM/dd/yyyy').format(dateObs.value!) : hint,
                  fontSize: 14,
                  color: dateObs.value != null ? AppColors.textPrimary : Colors.grey,
                ),
                const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
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
        CommonText(label, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
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
          children: controller.additionalServices.map((service) {
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
                      color: isSelected ? AppColors.primary : AppColors.borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight, width: 2),
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CommonText(service['name'], fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      CommonText('\$ ${service['price']} / horse', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Icon(Icons.add, color: AppColors.linkBlue, size: 18),
            SizedBox(width: 4),
            CommonText('Add Service', color: AppColors.linkBlue, fontSize: 14, fontWeight: FontWeight.bold),
          ],
        ),
      ],
    );
  }

  Widget _buildSendButton(SendBookingRequestController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => controller.sendRequest(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const CommonText('Send Request', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
