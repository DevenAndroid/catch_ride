import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/vendor/shipping/flows/load_models.dart';

class BookingsRequestShippingScreen extends StatefulWidget {
  final ShippingLoad? relatedLoad;
  final String? vendorName;

  const BookingsRequestShippingScreen({
    super.key,
    this.relatedLoad,
    this.vendorName,
  });

  @override
  State<BookingsRequestShippingScreen> createState() =>
      _BookingsRequestShippingScreenState();
}

class _BookingsRequestShippingScreenState
    extends State<BookingsRequestShippingScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _horsesController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  DateTime? _startDate;

  @override
  void initState() {
    super.initState();
    if (widget.relatedLoad != null) {
      _pickupController.text = widget.relatedLoad!.origin;
      _dropoffController.text = widget.relatedLoad!.destinations.first;
      _startDate = widget.relatedLoad!.startDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Request Shipping'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.relatedLoad != null) _buildLoadPreview(),

            _sectionTitle('Route Details'),
            CustomTextField(
              label: 'Pickup Address',
              controller: _pickupController,
              hint: 'Full address or barn name',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Dropoff Address',
              controller: _dropoffController,
              hint: 'Full address or barn name',
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await AppDatePicker.pickDate(context);
                      if (date != null) setState(() => _startDate = date);
                    },
                    child: _fakeInput(
                      'Pickup Date',
                      _startDate == null
                          ? 'Select'
                          : DateFormat('MMM d').format(_startDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Horse Count',
                    controller: _horsesController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            _sectionTitle('Additional Information'),
            CustomTextField(
              label: 'Notes / Special Requests',
              controller: _notesController,
              maxLines: 4,
              hint: 'e.g. Hay bag preference, medical needs...',
            ),
            const SizedBox(height: 32),

            CustomButton(
              text: 'Send Booking Request',
              onPressed: () {
                Get.back();
                Get.snackbar('Request Sent', 'The shipper has been notified.');
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadPreview() {
    final load = widget.relatedLoad!;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepNavy.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.deepNavy.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.deepNavy,
              ),
              const SizedBox(width: 8),
              Text(
                'Requesting from Load',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.deepNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${load.origin} → ${load.destinations.first}',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${load.startDate != null ? DateFormat('MMM d').format(load.startDate!) : 'Open'} · ${load.remainingSlots} slots left',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.grey500,
          letterSpacing: 1.2,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _fakeInput(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(value, style: AppTextStyles.bodyMedium),
              const Spacer(),
              const Icon(
                Icons.calendar_month,
                size: 18,
                color: AppColors.grey400,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
