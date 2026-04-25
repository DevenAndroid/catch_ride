import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/availability_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
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
  final ProfileController profileController = Get.find<ProfileController>();

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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          title: const CommonText(
            'Edit Availability',
            fontSize: AppTextSizes.size18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildActiveStatusCard(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CommonText(
                            'Availability',
                            fontSize: AppTextSizes.size18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          GestureDetector(
                            onTap: () => controller.addEntry(),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.add,
                                  color: Color(0xFF2C74EA),
                                  size: 18,
                                ),
                                SizedBox(width: 4),
                                CommonText(
                                  'Add Entry',
                                  color: Color(0xFF2C74EA),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildAvailabilityList(),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              CommonText(
                'Active Status',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 4),
              CommonText(
                'Make listing visible to others',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          Obx(
            () => Switch(
              value: controller.activeStatus.value,
              onChanged: (val) {
                controller.activeStatus.value = val;
              },
              activeTrackColor: const Color(0xFF10B981),
              activeColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityList() {
    return Obx(
      () => Column(
        children: [
          ...controller.entries.asMap().entries.map((entry) {
            final index = entry.key;
            final availabilityEntry = entry.value;
            return _buildAvailabilityCard(availabilityEntry, index);
          }),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard(AvailabilityEntry entry, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  'Entry ${index + 1}',
                  fontSize: AppTextSizes.size14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                if (controller.entries.length > 1)
                  GestureDetector(
                    onTap: () => controller.removeEntry(index),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildShowVenueSearch(entry),
            const SizedBox(height: 16),
            _buildLabelledField(
              label: 'City/State',
              controller: entry.cityStateController,
              hintText: 'e.g., Wellington, FL',
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
    );
  }

  Widget _buildShowVenueSearch(AvailabilityEntry availabilityEntry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Show Venue',
            style: TextStyle(
              fontSize: AppTextSizes.size14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
            children: [
              TextSpan(
                text: ' (optional)',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) => Autocomplete<Map<String, dynamic>>(
            displayStringForOption: (option) => option['name'] ?? '',
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<Map<String, dynamic>>.empty();
              }
              final query = textEditingValue.text.toLowerCase();
              return profileController.rawHorseShows.where((show) {
                final name = (show['name'] ?? '').toString().toLowerCase();
                final venue = (show['showVenue'] ?? '').toString().toLowerCase();
                final circuit = (show['circuit'] ?? '').toString().toLowerCase();
                return name.contains(query) ||
                    venue.contains(query) ||
                    circuit.contains(query);
              });
            },
            onSelected: (Map<String, dynamic> selection) {
              availabilityEntry.showVenueController.text = selection['name'] ?? '';
              availabilityEntry.showIdController.text =
                  selection['_id'] ?? selection['id'] ?? '';

              // Auto-fill City/State
              final city = selection['city'] ?? '';
              final state = selection['state'] ?? '';
              final country = selection['country'] ?? '';

              List<String> parts = [];
              if (city.isNotEmpty) parts.add(city.toString());
              if (state.isNotEmpty) parts.add(state.toString());
              if (country.isNotEmpty) parts.add(country.toString());

              if (parts.isNotEmpty) {
                availabilityEntry.cityStateController.text = parts.join(', ');
              }

              // Auto-fill Dates
              final DateFormat formatter = DateFormat('dd MMM yyyy');
              if (selection['startDate'] != null) {
                try {
                  final start = DateTime.parse(selection['startDate']);
                  availabilityEntry.startDateController.text =
                      formatter.format(start);
                } catch (_) {}
              }
              if (selection['endDate'] != null) {
                try {
                  final end = DateTime.parse(selection['endDate']);
                  availabilityEntry.endDateController.text =
                      formatter.format(end);
                } catch (_) {}
              }
            },
            fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
              if (availabilityEntry.showVenueController.text.isNotEmpty &&
                  textController.text.isEmpty) {
                textController.text = availabilityEntry.showVenueController.text;
              }
              textController.addListener(() {
                availabilityEntry.showVenueController.text = textController.text;
              });

              return TextFormField(
                controller: textController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Search horse show, venue or circuit...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  suffixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                ),
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: constraints.maxWidth,
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.borderLight),
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: CommonText(
                            option['name'] ?? '',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          subtitle: CommonText(
                            '${option['city'] ?? ''}, ${option['state'] ?? ''}',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: isDatePicker ? () => _selectDateTime(context, controller) : null,
          child: AbsorbPointer(
            absorbing: isDatePicker,
            child: TextFormField(
              controller: controller,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                ),
                suffixIcon: isDatePicker
                    ? const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
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
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const CommonText(
                  'Cancel',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 52,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          final success = await controller.saveAvailability();
                          if (success) {
                            Get.back();
                            Get.snackbar(
                              'Success',
                              'Availability updated successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const CommonText(
                          'Save Changes',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
