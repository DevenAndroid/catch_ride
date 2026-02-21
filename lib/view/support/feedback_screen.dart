import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _feedbackController = TextEditingController();
  final _emailController = TextEditingController();
  double _rating = 0;

  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_feedbackController.text.isEmpty) {
      Get.snackbar(
        'Empty Feedback',
        'Please tell us what you think before submitting.',
        backgroundColor: AppColors.softRed,
        colorText: Colors.white,
      );
      return;
    }

    // Logic to submit feedback to backend
    Get.back();
    Get.snackbar(
      'Thank You!',
      'Your feedback has been submitted successfully.',
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Your Feedback'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help us improve Catch Ride',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Your experience matters. Let us know what we can do better or what you love about the app.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'How would you rate your experience?',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _rating = index + 1.0),
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: AppColors.mutedGold,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            CustomTextField(
              label: 'Your Email (Optional)',
              hint: 'email@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),

            CustomTextField(
              label: 'Your Feedback *',
              hint: 'Write your comments here...',
              controller: _feedbackController,
              maxLines: 6,
            ),
            const SizedBox(height: 48),

            CustomButton(text: 'Submit Feedback', onPressed: _submitFeedback),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
