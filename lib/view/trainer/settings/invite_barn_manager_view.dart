import 'package:catch_ride/constant/app_colors.dart';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
                  icon: const Icon(Icons.more_vert, size: 20, color: Colors.white),
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
          ),
          
          // Barn Image
          const CommonImageView(
            url: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=800',
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          
          // Profile & Info
          Transform.translate(
            offset: const Offset(0, -40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        child: const CommonImageView(
                          url: 'https://i.pravatar.cc/150?u=lisa_james',
                          height: 100,
                          width: 100,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                'Lisa James',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              SizedBox(height: 4),
                              CommonText(
                                'lisa@example.com',
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const CommonText(
                    "I'm Alex, a passionate hair stylist with over 10 years of experience in transforming looks and boosting confidence. My journey began in a small town, and since then, I've honed my skills in various styles, from classic cuts to trendy colors.",
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
