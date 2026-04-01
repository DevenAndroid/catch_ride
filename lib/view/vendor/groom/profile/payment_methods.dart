import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/groom_view_profile_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentMethods extends StatelessWidget {
  const PaymentMethods({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroomViewProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Payment Methods',
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.dividerColor,
            height: 1.0,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final methods = controller.paymentMethods;
        final extraDetails = controller.vendorData['otherPaymentDetails']?.toString() ?? '';

        if (methods.isEmpty && extraDetails.isEmpty) {
          return const Center(
            child: CommonText('No payment methods provided.', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...methods.map((pm) {
                Color iconColor = AppColors.secondary;
                IconData icon = Icons.payments_outlined;
                if (pm.toLowerCase().contains('venmo')) {
                    iconColor = const Color(0xFF3D95CE);
                    icon = Icons.account_balance_wallet_outlined;
                } else if (pm.toLowerCase().contains('zelle')) {
                    iconColor = const Color(0xFF671BC4);
                    icon = Icons.currency_exchange;
                } else if (pm.toLowerCase().contains('cash')) {
                    iconColor = const Color(0xFF22C55E);
                    icon = Icons.payments_outlined;
                } else if (pm.toLowerCase().contains('card')) {
                    iconColor = const Color(0xFF1E3A8A);
                    icon = Icons.credit_card_outlined;
                } else if (pm.toLowerCase().contains('ach') || pm.toLowerCase().contains('bank')) {
                    iconColor = const Color(0xFF713F12);
                    icon = Icons.account_balance_outlined;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildPaymentItem(pm, iconColor, icon),
                );
              }).toList(),
              
              if (extraDetails.isNotEmpty) ...[
                const SizedBox(height: 16),
                const CommonText('Additional Payment Info', fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: CommonText(extraDetails, fontSize: AppTextSizes.size14, color: AppColors.textPrimary, height: 1.5),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPaymentItem(String label, Color iconColor, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          CommonText(
            label,
            fontSize: AppTextSizes.size16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}
