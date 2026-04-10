import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/support_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../widgets/common_textfield.dart';

class RequestHorseShowView extends StatefulWidget {
  const RequestHorseShowView({super.key});

  @override
  State<RequestHorseShowView> createState() => _RequestHorseShowViewState();
}

class _RequestHorseShowViewState extends State<RequestHorseShowView> {
  final SupportController _controller = Get.find<SupportController>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _showNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  bool _isSubmitted = false;

  @override
  void dispose() {
    _showNameController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _controller.submitHorseShowRequest(
      showName: _showNameController.text,
      location: _locationController.text,
      startDate: _startDateController.text,
      endDate: _endDateController.text,
    );

    if (success) {
      setState(() {
        _isSubmitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return _buildSuccessScreen();
    }

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
        title: const CommonText(
          'Request a Horse Show',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border.withValues(alpha: 0.5), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonText(
                'Can\'t find your show? Submit the details and we\'ll add it for you.',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              const SizedBox(height: 32),
              CommonTextField(
                label: 'Horse Show Name',
                controller: _showNameController,
                hintText: 'Enter Horse Show Name',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              CommonTextField(
                label: 'Show Location',
                controller: _locationController,
                hintText: 'Enter Show Location',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CommonTextField(
                      label: 'Start Date',
                      controller: _startDateController,
                      hintText: 'Select Date',
                      readOnly: true,
                      onTap: () => _selectDate(context, _startDateController),
                      suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.textSecondary),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CommonTextField(
                      label: 'End Date',
                      controller: _endDateController,
                      hintText: 'Select Date',
                      readOnly: true,
                      onTap: () => _selectDate(context, _endDateController),
                      suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.textSecondary),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Obx(() => GestureDetector(
          onTap: _controller.isSubmitting.value ? null : _handleSubmit,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF00084D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: _controller.isSubmitting.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const CommonText(
                      'Submit Request',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B4242).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.check, color: Color(0xFF8B4242), size: 40),
                ),
              ),
              const SizedBox(height: 40),
              const CommonText(
                'Request Submitted',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 16),
              const CommonText(
                'Thanks! Our team will review and add the show if applicable.',
                fontSize: 16,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
                height: 1.5,
              ),
              const SizedBox(height: 60),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00084D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CommonText(
                      'Done',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
