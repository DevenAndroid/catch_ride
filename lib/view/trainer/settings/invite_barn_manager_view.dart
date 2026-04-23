import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/barn_manager/barn_manager_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../models/user_model.dart';

class InviteBarnManagerView extends StatefulWidget {
  const InviteBarnManagerView({super.key});

  @override
  State<InviteBarnManagerView> createState() => _InviteBarnManagerViewState();
}

class _InviteBarnManagerViewState extends State<InviteBarnManagerView> {
  final BarnManagerController _controller = Get.put(BarnManagerController());
  final ProfileController _profileController = Get.find<ProfileController>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _profileController.fetchProfile();
  }

  @override
  void dispose() {
    _emailController.dispose();
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
          'Invite a Barn Manager',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      body: Obx(() {
        final barnManager = _profileController.user.value?.linkedBarnManager;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              if (barnManager != null)
                _buildCurrentManagerSection(barnManager)
              else
                _buildInviteForm(),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final hasBarnManager =
            _profileController.user.value?.linkedBarnManager != null;
        if (hasBarnManager) return const SizedBox.shrink();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(
              () => CommonButton(
                text: _controller.isLoading.value
                    ? 'Sending...'
                    : 'Send Invite Link',
                onPressed: _controller.isLoading.value
                    ? null
                    : () async {
                        final email = _emailController.text.trim();
                        if (email.isEmpty || !GetUtils.isEmail(email)) {
                          Get.snackbar(
                            'Error',
                            'Please enter a valid email address',
                            backgroundColor: const Color(0xFFF04438),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                          return;
                        }

                        final success = await _controller.inviteBarnManager(
                          email,
                        );
                        if (success) {
                          _emailController.clear();
                          Get.snackbar(
                            'Success',
                            'Invitation sent successfully',
                            backgroundColor: const Color(0xFF13CA8B),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                        }
                      },
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentManagerSection(BarnManager manager) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CommonText(
                  'Your current barn manager',
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                PopupMenuButton(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Colors.white,
                  ),
                  onSelected: (value) async {
                    if (value == 'remove') {
                      final confirmRemoved = await Get.dialog<bool>(
                        AlertDialog(
                          title: const CommonText('Remove Barn Manager',
                              fontWeight: FontWeight.bold, fontSize: 18),
                          content: const CommonText(
                            'Are you sure you want to remove this barn manager? They will be notified and their access will be disabled immediately.',
                            fontSize: 14,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: const CommonText('Cancel',
                                  color: AppColors.textSecondary),
                            ),
                            TextButton(
                              onPressed: () => Get.back(result: true),
                              child: const CommonText('Remove',
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );

                      if (confirmRemoved == true) {
                        final success = await _controller.removeBarnManager();
                        if (success) {
                          Get.snackbar(
                            'Success',
                            'Barn manager removed and notified',
                            backgroundColor: const Color(0xFF13CA8B),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                        }
                      }
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
          ),

          // Barn Image
          CommonImageView(
            url: (manager.coverImage != null && manager.coverImage!.isNotEmpty)
                ? manager.coverImage
                : null,
            assetPath:
                (manager.coverImage == null || manager.coverImage!.isEmpty)
                    ? 'assets/images/barn_manager_bg1.jpg'
                    : null,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // Profile & Info
          Transform.translate(
            offset: const Offset(0, -40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CommonImageView(
                          url:
                              (manager.avatar != null &&
                                  manager.avatar!.isNotEmpty)
                              ? manager.avatar
                              : null,
                          assetPath:
                              (manager.avatar == null ||
                                  manager.avatar!.isEmpty)
                              ? 'assets/images/demo_user_image.jpg'
                              : null,
                          height: 100,
                          width: 100,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 32),
                              CommonText(
                                manager.fullName,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(height: 4),
                              CommonText(
                                manager.email,
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CommonText(
                    manager.bio ??
                        "Invited Barn Manager. This space will show their bio once they set up their profile.",
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
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
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            "Invite a Barn Manager to help manage listings and barn activity on your account.",
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          const SizedBox(height: 20),
          _buildSetupSteps(),
          const SizedBox(height: 24),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 24),
          CommonTextField(
            controller: _emailController,
            label: 'Email Address',
            hintText: 'name@email.com',
            isRequired: true,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            onChanged: (val) {
              if (val != val.toLowerCase()) {
                _emailController.value = _emailController.value.copyWith(
                  text: val.toLowerCase(),
                  selection: TextSelection.collapsed(offset: val.length),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSetupSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText(
          'Setup Steps',
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 12),
        _buildStepItem(1, 'Enter their email address below.'),
        _buildStepItem(2, 'They will receive an invitation link.'),
        _buildStepItem(3, 'They click the link to create their profile.'),
        _buildStepItem(4, 'Once joined, they can manage your barn activity.'),
      ],
    );
  }

  Widget _buildStepItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CommonText(
                number.toString(),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CommonText(
              text,
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
