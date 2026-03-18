import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/support_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class PrivacyPolicyView extends StatefulWidget {
  const PrivacyPolicyView({super.key});

  @override
  State<PrivacyPolicyView> createState() => _PrivacyPolicyViewState();
}

class _PrivacyPolicyViewState extends State<PrivacyPolicyView> {
  final SupportController supportController = Get.put(SupportController());

  @override
  void initState() {
    super.initState();
    supportController.fetchPageContent('privacy-policy');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Privacy Policy',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border.withOpacity(0.5), height: 1),
        ),
      ),
      body: Obx(() {
        if (supportController.isLoadingPage.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (supportController.privacyPolicy.isEmpty) {
          return const Center(
            child: CommonText(
              'No content available',
              color: AppColors.textSecondary,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: HtmlWidget(
            supportController.privacyPolicy.value,
            textStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        );
      }),
    );
  }
}
