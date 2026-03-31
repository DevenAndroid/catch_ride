import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/availability_controller.dart';
import 'package:catch_ride/models/horse_model.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BarnManagerAvailabilityView extends StatefulWidget {
  final HorseModel horse;
  const BarnManagerAvailabilityView({super.key, required this.horse});

  @override
  State<BarnManagerAvailabilityView> createState() =>
      _BarnManagerAvailabilityViewState();
}

class _BarnManagerAvailabilityViewState
    extends State<BarnManagerAvailabilityView> {
  late AvailabilityController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AvailabilityController(horse: widget.horse));
  }

  Future<void> _selectDateTime(
    BuildContext context,
    TextEditingController textController,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      textController.text = DateFormat('dd MMM yyyy').format(pickedDate);
    }
  }


  @override
  void dispose() {
    Get.delete<AvailabilityController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1F2937),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Edit Availability',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: CommonText(
                        'Availability',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Obx(
                      () => ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 24),
                        itemBuilder: (context, index) {
                          final entry = controller.entries[index];
                          return _buildAvailabilityCard(entry, index);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => controller.addEntry(),
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFF101828),
                        ),
                        label: const CommonText(
                          'Add Entry',
                          color: Color(0xFF101828),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard(AvailabilityEntry entry, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CommonText(
                  'Active Status',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101828),
                ),
                Obx(
                  () => Switch(
                    value: entry.isActive.value,
                    onChanged: (val) => entry.isActive.value = val,
                    activeColor: const Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEAECF0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    'Entry ${index + 1}',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF101828),
                  ),
                  const SizedBox(height: 16),
                  _buildLabelledField(
                    label: 'City/State',
                    controller: entry.cityStateController,
                    hintText: 'e.g., Welling.',
                  ),
                  const SizedBox(height: 16),
                  _buildLabelledField(
                    label: 'Show Venue',
                    controller: entry.showVenueController,
                    hintText: 'e.g., Welling.',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLabelledField(
                          label: 'Start Date',
                          controller: entry.startDateController,
                          hintText: 'Select date',
                          isDatePicker: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLabelledField(
                          label: 'End Date',
                          controller: entry.endDateController,
                          hintText: 'Select date',
                          isDatePicker: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLabelledField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool isDatePicker = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          label,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF344054),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: isDatePicker
              ? () => _selectDateTime(context, controller)
              : null,
          child: AbsorbPointer(
            absorbing: isDatePicker,
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 14, color: Color(0xFF101828)),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFFD0D5DD),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFD0D5DD),
                    width: 1,
                  ),
                ),
                suffixIcon: isDatePicker
                    ? const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: Color(0xFF667085),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAECF0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD0D5DD)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const CommonText(
                  'Cancel',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF344054),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await controller.saveAvailability();
                  if (success) Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00083B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const CommonText(
                  'Save',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
