import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controllers/profile_controller.dart';
import 'package:share_plus/share_plus.dart';

class ReferNewMemberView extends StatefulWidget {
  const ReferNewMemberView({super.key});

  @override
  State<ReferNewMemberView> createState() => _ReferNewMemberViewState();
}

class _ReferNewMemberViewState extends State<ReferNewMemberView> {
  final String referralLink = 'catchride.com/r/yourusername';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Refer a New Member',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.border.withValues(alpha: 0.3),
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CommonText(
                    'Catch Ride is built through trusted referrals from within the industry. Invite professionals you trust to be considered for the network',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  const SizedBox(height: 24),
                  const CommonText(
                    'How it works?',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 20),
                  _buildStep(
                    1,
                    'Invite a Professional',
                    'Share your referral link with a trainer or vendor you trust.',
                    false,
                  ),
                  _buildStep(
                    2,
                    'They Apply',
                    'They submit a short application to confirm their details and references.',
                    false,
                  ),
                  _buildStep(
                    3,
                    'Priority Review',
                    'Referred applicants receive priority review as new members are approved.',
                    true,
                  ),
                  const SizedBox(height: 32),

                  // Share Link Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CommonText(
                          'Share Your Referral Link',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(height: 8),
                        const CommonText(
                          'Share this link with professionals you\'d confidently recommend to the Catch Ride network.',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: CommonText(
                                  'catchride.com/r/yourusername',
                                  fontSize: 14,
                                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  final controller = Get.find<ProfileController>();
                                  String urlToCopy = '';
                                  if (Theme.of(context).platform == TargetPlatform.iOS) {
                                    urlToCopy = controller.appStoreUrl.value;
                                  } else {
                                    urlToCopy = controller.playStoreUrl.value;
                                  }

                                  if (urlToCopy.isNotEmpty) {
                                    Clipboard.setData(ClipboardData(text: urlToCopy)).then((_) {
                                      Get.snackbar(
                                        'Success',
                                        'Link copied to clipboard',
                                        snackPosition: SnackPosition.BOTTOM,
                                        margin: const EdgeInsets.all(20),
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                    });
                                  } else {
                                     Get.snackbar(
                                        'Error',
                                        'App link not configured',
                                        snackPosition: SnackPosition.BOTTOM,
                                        margin: const EdgeInsets.all(20),
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const CommonText(
                                  'Copy Link',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const CommonText(
                    'Membership is shaped through trusted referrals within the industry',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String title, String description, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFE8EAF6),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CommonText(
                  number.toString(),
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (!isLast)
              SizedBox(
                height: 48,
                width: 1,
                child: CustomPaint(painter: DashedLinePainter()),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                title,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              const SizedBox(height: 4),
              CommonText(
                description,
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              if (!isLast) const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(color: Colors.white),
      child: GestureDetector(
        onTap: () {
          final controller = Get.find<ProfileController>();
          String urlToShare = '';
          if (Theme.of(context).platform == TargetPlatform.iOS) {
            urlToShare = controller.appStoreUrl.value;
          } else {
            urlToShare = controller.playStoreUrl.value;
          }

          if (urlToShare.isNotEmpty) {
            Share.share(
              'Join me on Catch Ride! The premier network for equestrian professionals. Download here: $urlToShare',
              subject: 'Join Catch Ride',
            );
          } else {
             Get.snackbar(
                'Error',
                'App link not configured for sharing',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(20),
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
          }
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: CommonText(
              'Share',
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

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4, dashSpace = 4, startY = 8;
    final paint = Paint()
      ..color = const Color(0xFFD0D5DD)
      ..strokeWidth = 1.2;
    while (startY < size.height - 4) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
