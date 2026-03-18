import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
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
                  const CommonText(
                    'Give Feedback',
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
                      hintText: 'Write your feedback...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.2,
                        ),
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
      decoration: const BoxDecoration(color: Colors.white),
      child: GestureDetector(
        onTap: () {
          if (_feedbackController.text.trim().isEmpty) {
            Get.snackbar(
              'Alert',
              'Please enter your feedback',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            return;
          }
          Get.back();
          Get.snackbar(
            'Success',
            'Thank you for your feedback!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF17B26A),
            colorText: Colors.white,
          );
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: CommonText(
              'Submit Feedback',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
