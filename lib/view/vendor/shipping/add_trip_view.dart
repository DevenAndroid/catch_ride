import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/shipping/add_trip_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddTripView extends StatelessWidget {
  const AddTripView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddTripController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'List a Trip',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              // ── Route Details ─────────────────────────────────────────────
              _buildSectionCard(
                title: 'Route Details',
                children: [
                  CommonTextField(
                    label: 'Origin Location',
                    hintText: 'Select Show Venue or City',
                    controller: controller.originController,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),
                  CommonTextField(
                    label: 'Destination location',
                    hintText: 'Select Show Venue or City',
                    controller: controller.destinationController,
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...controller.rxHorseShows.take(5).map((show) {
                            final name = show['name'] ?? '';
                            final isAdded = controller.rxDestinationTags.contains(name);
                            if (isAdded) return const SizedBox.shrink();
                            return _buildChip(
                              name,
                              () => controller.addDestinationTag(name),
                              isAction: true,
                            );
                          }),
                          ...controller.rxDestinationTags.map(
                            (tag) => _buildChip(tag, () => controller.removeDestinationTag(tag)),
                          ),
                        ],
                      )),
                ],
              ),
              const SizedBox(height: 16),

              // ── Schedule ──────────────────────────────────────────────────
              _buildSectionCard(
                title: 'Schedule',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => CommonTextField(
                              label: 'Start Date',
                              hintText: 'Select date',
                              readOnly: true,
                              controller: TextEditingController(
                                text: controller.rxStartDate.value != null
                                    ? DateFormat('MMM dd, yyyy').format(controller.rxStartDate.value!)
                                    : '',
                              ),
                              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) controller.rxStartDate.value = date;
                              },
                            )),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() => CommonTextField(
                              label: 'End Date',
                              hintText: 'Select date',
                              readOnly: true,
                              controller: TextEditingController(
                                text: controller.rxEndDate.value != null
                                    ? DateFormat('MMM dd, yyyy').format(controller.rxEndDate.value!)
                                    : '',
                              ),
                              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: controller.rxStartDate.value ?? DateTime.now(),
                                  firstDate: controller.rxStartDate.value ?? DateTime.now(),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) controller.rxEndDate.value = date;
                              },
                            )),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Available Slots ───────────────────────────────────────────
              _buildSectionCard(
                title: 'Available slots',
                children: [
                  const CommonText(
                    'Max Horses',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderLight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCounterButton(Icons.remove, controller.decrementHorses),
                        Obx(() => CommonText(
                              '${controller.rxMaxHorses.value}',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                        _buildCounterButton(Icons.add, controller.incrementHorses),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Equipment & Setup ─────────────────────────────────────────
              _buildSectionCard(
                title: 'Equipment & Setup',
                subtitle: 'Briefly describe your equipment + services offered on this trip',
                children: [
                  CommonTextField(
                    label: '',
                    hintText: 'example: "Box trucks + goosenecks, climate controlled when needed"',
                    maxLines: 4,
                    controller: controller.equipmentController,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Route Notes ───────────────────────────────────────────────
              _buildSectionCard(
                title: 'Route Notes',
                children: [
                  CommonTextField(
                    label: '',
                    hintText: 'Add any details about your route or schedule that would help clients understand your availability or flexibility.',
                    maxLines: 4,
                    controller: controller.notesController,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Allow Intermediate Stops Toggle ───────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CommonText(
                      'Allow Intermediate Stops',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    Obx(() => Switch(
                          value: controller.rxAllowIntermediateStops.value,
                          onChanged: (val) => controller.rxAllowIntermediateStops.value = val,
                          activeColor: const Color(0xFF13CA8B),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Intermediate Stops ────────────────────────────────────────
              Obx(() => Visibility(
                    visible: controller.rxAllowIntermediateStops.value,
                    child: _buildSectionCard(
                      title: 'Intermediate Stops',
                      subtitle: 'Add stops between pickup and destination locations',
                      children: [
                        CommonTextField(
                          label: 'Location',
                          hintText: 'Enter Location',
                          controller: controller.intermediateStopController,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              controller.addIntermediateStop(controller.intermediateStopController.text);
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.rxIntermediateStops.map((stop) {
                            return _buildChip(stop, () => controller.removeIntermediateStop(stop));
                          }).toList(),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 32),

              // ── Action Buttons ────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const CommonText('Cancel', fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CommonButton(
                      text: 'List',
                      onPressed: controller.listTrip,
                      isLoading: controller.isLoading.value,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            title,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            CommonText(
              subtitle,
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildChip(String label, VoidCallback onTap, {bool isAction = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isAction ? AppColors.primary.withOpacity(0.05) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isAction ? AppColors.primary.withOpacity(0.2) : Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonText(
              label,
              fontSize: 13,
              color: isAction ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isAction ? FontWeight.w600 : FontWeight.normal,
            ),
            if (!isAction) ...[
              const SizedBox(width: 4),
              const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
    );
  }
}
