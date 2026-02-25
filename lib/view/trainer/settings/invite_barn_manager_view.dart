import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InviteBarnManagerView extends StatefulWidget {
  const InviteBarnManagerView({super.key});

  @override
  State<InviteBarnManagerView> createState() => _InviteBarnManagerViewState();
}

class _InviteBarnManagerViewState extends State<InviteBarnManagerView> {
  // Simulating the flow: Starts with no manager, then shows manager after invite
  bool _hasBarnManager = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
          'Invite a Barn Manager',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border.withOpacity(0.5), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_hasBarnManager)
              _buildCurrentManagerSection()
            else
              _buildInviteForm(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _hasBarnManager
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CommonButton(
                  text: 'Send Invite Link',
                  onPressed: () {
                    setState(() {
                      _hasBarnManager = true;
                    });
                    Get.snackbar(
                      'Success',
                      'Invitation sent successfully',
                      backgroundColor: const Color(0xFF13CA8B),
                      colorText: Colors.white,
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildCurrentManagerSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF), // Soft blue background
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CommonText(
                'Your current barn manager',
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              PopupMenuButton(
                icon: const Icon(
                  Icons.more_vert,
                  size: 20,
                  color: Colors.black87,
                ),
                onSelected: (value) {
                  if (value == 'remove') {
                    setState(() {
                      _hasBarnManager = false;
                    });
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove Barn Manager'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CommonImageView(
                  url: AppConstants.dummyImageUrl,
                  height: 60,
                  width: 60,
                  shape: BoxShape.circle,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonText(
                        'Lisa James',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 2),
                      const CommonText(
                        'lisa@example.com',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: CommonText(
                              'Ocklawaha, USA, United States',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          CommonText(
            "Send a direct invitation to someone you'd like to work with. They'll receive priority review.",
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          SizedBox(height: 24),
          CommonTextField(
            label: 'Email',
            hintText: 'barn.manager@email.com',
            isRequired: true,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }
}
