import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/view/trainer/trainer_application_submitted_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class TrainerProfileSetupView extends StatefulWidget {
  const TrainerProfileSetupView({super.key});

  @override
  State<TrainerProfileSetupView> createState() =>
      _TrainerProfileSetupViewState();
}

class _TrainerProfileSetupViewState extends State<TrainerProfileSetupView> {
  int _currentStep = 0;
  bool _isConfirmed = false;
  String _selectedFederation = 'USEF (United States)';
  String _selectedYears = 'Select years';

  File? _profileImage;
  File? _bannerImage;
  final ImagePicker _picker = ImagePicker();

  // Dummy tags for UI purposes
  final List<String> _programTags = ['Jump', 'Dance', 'Well'];
  final List<String> _horseShows = ['WEC Ocala', 'Tryon', 'Well'];

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _pickBannerImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _bannerImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
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
          onPressed: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            } else {
              Get.back();
            }
          },
        ),
        title: const CommonText(
          AppStrings.profileSetup,
          color: AppColors.textPrimary,
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: _buildProgressBar(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildCurrentStep(), const SizedBox(height: 40)],
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CommonButton(
                text: _currentStep == 3 ? AppStrings.submitApplication : 'Next',
                onPressed: () {
                  // if (_currentStep == 3 && !_isConfirmed) {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(
                  //       content: CommonText(
                  //         'Please confirm all information is accurate.',
                  //       ),
                  //     ),
                  //   );
                  //   return;
                  // }
                  if (_currentStep < 3) {
                    setState(() {
                      _currentStep++;
                    });
                  } else {
                    Get.to(() => const TrainerApplicationSubmittedView());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: index <= _currentStep
                  ? AppColors.primary
                  : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return Column(
          children: [
            _buildBasicDetailsCard(),
            const SizedBox(height: 16),
            _buildExperienceCard(),
          ],
        );
      case 1:
        return Column(
          children: [
            _buildBarnInfoCard(),
            const SizedBox(height: 16),
            _buildHorseShowsCard(),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildFederationInfoCard()],
        );
      case 3:
        return Column(
          children: [
            _buildSocialMediaCard(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _isConfirmed,
                    onChanged: (val) {
                      setState(() {
                        _isConfirmed = val ?? false;
                      });
                    },
                    activeColor: const Color(
                      0xFFD92D20,
                    ), // Reddish checkbox from design
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: CommonText(
                    AppStrings.iConfirmAllInformationIsAccurate,
                    fontSize: AppTextSizes.size14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            title,
            fontSize: AppTextSizes.size16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildBasicDetailsCard() {
    return _buildCard(
      title: AppStrings.basicDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            AppStrings.profilePhoto,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _profileImage != null
                        ? ClipOval(
                            child: Image.file(
                              _profileImage!,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            ),
                          )
                        : const Icon(
                            Icons.person_outline,
                            size: 40,
                            color: AppColors.textSecondary,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const CommonText(
            AppStrings.bannerImage,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickBannerImage,
            child: CustomPaint(
              painter: _bannerImage == null
                  ? DashPainter(color: AppColors.border)
                  : null,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _bannerImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_bannerImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.add,
                            color: AppColors.textSecondary,
                            size: 24,
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const CommonTextField(
            label: AppStrings.fullName,
            hintText: AppStrings.enterYourFullName,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: CommonText(
              AppStrings.phoneNumber,
              fontSize: AppTextSizes.size14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  border: Border.all(color: AppColors.border),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: const [
                    CommonText(
                      AppStrings.num91,
                      fontSize: AppTextSizes.size14,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontSize: AppTextSizes.size14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.enterPhoneNumber,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarnInfoCard() {
    return _buildCard(
      title: AppStrings.barnInformation,
      child: Column(
        children: [
          const CommonTextField(
            label: AppStrings.barnName,
            hintText: AppStrings.enterYourBusinessName,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          const CommonTextField(
            label: AppStrings.locationI,
            hintText: AppStrings.enterBarnLocation,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          const CommonTextField(
            label: AppStrings.locationIiOptional,
            hintText: AppStrings.enterYourBusinessName,
          ),
        ],
      ),
    );
  }

  Widget _buildFederationInfoCard() {
    return _buildCard(
      title: AppStrings.federationInformation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.inputBackground,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFederation,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
                items: ['USEF (United States)', 'Other Federation']
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: CommonText(
                          e,
                          fontSize: AppTextSizes.size14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() => _selectedFederation = val!);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          const CommonTextField(
            label: AppStrings.federationIdNumber,
            hintText: AppStrings.idNumber,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4), // Light green background
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF16A34A),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      CommonText(
                        AppStrings.federationVerification,
                        fontSize: AppTextSizes.size12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF16A34A),
                      ),
                      SizedBox(height: 2),
                      CommonText(
                        AppStrings
                            .yourFederationNumberWillBeVerifiedToEnsureProperCityAndStateCalculations,
                        fontSize: AppTextSizes.size12,
                        color: Color(0xFF15803D),
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

  Widget _buildSocialMediaCard() {
    return _buildCard(
      title: AppStrings.socialMediaWebsite,
      child: Column(
        children: [
          const CommonTextField(
            label: AppStrings.facebook,
            hintText: AppStrings.facebookcomyourpage,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          const CommonTextField(
            label: AppStrings.websiteUrl,
            hintText: AppStrings.httpsyourwebsitecom,
            prefixIcon: Icon(
              Icons.link,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const CommonTextField(
            label: AppStrings.instagram,
            hintText: AppStrings.yourusername,
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard() {
    return _buildCard(
      title: AppStrings.experience,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            AppStrings.yearsInIndustry,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.inputBackground,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedYears,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
                items: ['Select years', '1-5 years', '5-10 years', '10+ years']
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: CommonText(
                          e,
                          fontSize: AppTextSizes.size14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() => _selectedYears = val!);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          const CommonTextField(
            label: AppStrings.bio,
            hintText: AppStrings.writeAShortBio,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          const CommonText(
            AppStrings.programTags,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.inputBackground,
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ..._programTags.map(
                  (tag) => _buildTag(tag, () {
                    setState(() => _programTags.remove(tag));
                  }),
                ),
                const CommonText(
                  AppStrings.well,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorseShowsCard() {
    return _buildCard(
      title: AppStrings.horseShowsCircuitsFrequented,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            AppStrings.selectLocation,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.inputBackground,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ..._horseShows.map(
                        (tag) => _buildTag(tag, () {
                          setState(() => _horseShows.remove(tag));
                        }),
                      ),
                      const CommonText(
                        AppStrings.well,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
        color: AppColors.background,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonText(
            text,
            fontSize: AppTextSizes.size12,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class DashPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1,
    this.dashWidth = 5,
    this.dashSpace = 3,
    this.borderRadius = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(DashPainter oldDelegate) => false;
}
