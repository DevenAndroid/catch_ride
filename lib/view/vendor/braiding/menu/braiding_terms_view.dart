import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/support_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class BraidingTermsView extends StatefulWidget {
  const BraidingTermsView({super.key});

  @override
  State<BraidingTermsView> createState() => _BraidingTermsViewState();
}

class _BraidingTermsViewState extends State<BraidingTermsView> {
  final SupportController supportController = Get.put(SupportController());

  @override
  void initState() {
    super.initState();
    supportController.fetchPageContent('terms-conditions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Terms & Conditions', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border.withValues(alpha: 0.5), height: 1),
        ),
      ),
      body: Obx(() {
        if (supportController.isLoadingPage.value) return const Center(child: CircularProgressIndicator());
        if (supportController.termsAndConditions.isEmpty) return const Center(child: CommonText('No content available', color: AppColors.textSecondary));
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: HtmlWidget(
            supportController.termsAndConditions.value,
            textStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
          ),
        );
      }),
    );
  }
}
