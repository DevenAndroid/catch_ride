import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/support_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  final SupportController supportController = Get.put(SupportController());
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  String _selectedCategory = 'General Feedback';

  final List<String> _categories = [
    'General Feedback',
    'Bug Report',
    'Feature Request',
    'Complaint',
    'Suggestion',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
          'Feedback',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CommonText(
                    'Your feedback helps shape the future of Catch Ride. Let us know what’s working and what could be improved.',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  const SizedBox(height: 32),
                  
                  // Category Selection
                  const CommonText(
                    'Category',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          }
                        },
                        items: _categories.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: CommonText(value, fontSize: 15),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Subject Field
                  const CommonText(
                    'Subject',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _subjectController,
                    style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Enter subject',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Message Field
                  const CommonText(
                    'Your Feedback',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 6,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Write your feedback here...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Obx(() => GestureDetector(
        onTap: supportController.isSubmitting.value ? null : () async {
          if (_subjectController.text.trim().isEmpty) {
            Get.snackbar('Alert', 'Please enter a subject',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white);
            return;
          }
          if (_feedbackController.text.trim().isEmpty) {
            Get.snackbar('Alert', 'Please enter your feedback',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white);
            return;
          }
          
          bool success = await supportController.submitFeedback(
            category: _selectedCategory,
            subject: _subjectController.text.trim(),
            message: _feedbackController.text.trim(),
          );

          if (success) {
            Get.back();
          }
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: supportController.isSubmitting.value 
                ? AppColors.primary.withValues(alpha: 0.5) 
                : AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (!supportController.isSubmitting.value)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Center(
            child: supportController.isSubmitting.value
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const CommonText(
                    'Submit Feedback',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
          ),
        ),
      )),
    );
  }
}
