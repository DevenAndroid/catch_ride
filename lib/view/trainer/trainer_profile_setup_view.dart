import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/constant/app_urls.dart';
import 'package:catch_ride/services/api_service.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';

class TrainerProfileSetupView extends StatefulWidget {
  const TrainerProfileSetupView({super.key});

  @override
  State<TrainerProfileSetupView> createState() =>
      _TrainerProfileSetupViewState();
}

class _TrainerProfileSetupViewState extends State<TrainerProfileSetupView> {
  final AuthController _authController = Get.find<AuthController>();
  
  // Controllers for data collection
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _barnNameController = TextEditingController();
  final TextEditingController _location1Controller = TextEditingController();
  final TextEditingController _location2Controller = TextEditingController();
  final TextEditingController _federationIdController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _whyJoinController = TextEditingController();

  int _currentStep = 0;
  bool _isConfirmed = false;
  String _selectedFederation = 'USEF (United States)';
  int _selectedYears = 0;
  final TextEditingController _yearsExperienceController = TextEditingController();

  File? _profileImage;
  File? _bannerImage;
  final ImagePicker _picker = ImagePicker();

  // Dynamic data from API
  List<dynamic> _allProgramTags = [];
  List<dynamic> _allHorseShows = [];
  
  // Selected values
  final List<String> _selectedProgramTags = [];
  final List<String> _selectedHorseShows = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final apiService = Get.find<ApiService>();
    try {
      final tagsRes = await apiService.getRequest(AppUrls.programTags);
      final showsRes = await apiService.getRequest(AppUrls.horseShows);

      if (tagsRes.statusCode == 200) {
        setState(() {
          _allProgramTags = tagsRes.body['data'] ?? [];
        });
      }
      if (showsRes.statusCode == 200) {
        setState(() {
          _allHorseShows = showsRes.body['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching metadata: $e');
    }
  }

  void _showSelectionBottomSheet({
    required String title,
    required List<dynamic> options,
    required List<String> initialSelectedList,
    required Function(List<String>) onConfirm,
  }) {
    List<String> localSelected = List.from(initialSelectedList);

    Get.bottomSheet(
      StatefulBuilder(builder: (context, setSheetState) {
        return Container(
          height: Get.height * 0.7,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const CommonText("Cancel", color: Colors.grey),
                  ),
                  CommonText(title,
                      fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
                  TextButton(
                    onPressed: () {
                      onConfirm(localSelected);
                      Get.back();
                    },
                    child: const CommonText("Done",
                        color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final item = options[index];
                    final name = item['name'] ?? '';
                    final isSelected = localSelected.contains(name);

                    return ListTile(
                      title: CommonText(name),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primary)
                          : const Icon(Icons.circle_outlined),
                      onTap: () {
                        setSheetState(() {
                          if (isSelected) {
                            localSelected.remove(name);
                          } else {
                            localSelected.add(name);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _barnNameController.dispose();
    _location1Controller.dispose();
    _location2Controller.dispose();
    _federationIdController.dispose();
    _facebookController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _bioController.dispose();
    _whyJoinController.dispose();
    _yearsExperienceController.dispose();
    super.dispose();
  }

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
        title: CommonText(
          _currentStep == 1 ? "Complete Your Profile" : AppStrings.profileSetup,
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentStep == 1) ...[
                      const CommonText(
                        "Finish your Verified Trainer Application",
                        fontSize: AppTextSizes.size18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      CommonText(
                        "Step building a trusted network of professionals and partners in the horse world - let's get",
                        fontSize: AppTextSizes.size14,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _buildCurrentStep(),
                    const SizedBox(height: 40)
                  ],
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Obx(() => CommonButton(
                text: _currentStep == 1 ? AppStrings.submitApplication : 'Next',
                isLoading: _authController.isLoading.value,
                onPressed: () async {
                  if (_currentStep < 1) {
                    setState(() {
                      _currentStep++;
                    });
                  } else {
                    // Final Submission Logic with Validations
                    if (!_isConfirmed) {
                      Get.snackbar('Validation Error', 'Please confirm that all information provided is accurate.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                      return;
                    }

                    if (_fullNameController.text.trim().isEmpty) {
                      Get.snackbar('Input Required', 'Full Name is required to identify your professional profile.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                      return;
                    }

                    if (_phoneController.text.trim().isEmpty) {
                      Get.snackbar('Input Required', 'Contact Phone Number is required for profile verification.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                      return;
                    }

                    if (_barnNameController.text.trim().isEmpty) {
                      Get.snackbar('Input Required', 'Business or Barn Name is mandatory for trainers.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                      return;
                    }

                    if (_location1Controller.text.trim().isEmpty) {
                      Get.snackbar('Input Required', 'Primary Barn Location is required.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                      return;
                    }

                    if (_bioController.text.trim().length < 20) {
                      Get.snackbar('Content Too Short', 'Please provide a bio of at least 20 characters to help users know you better.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                      return;
                    }

                    if (_selectedYears == 0) {
                      Get.snackbar('Input Required', 'Please select your years of experience in the industry.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                      return;
                    }

                    // Split Name safely
                    final trimmedName = _fullNameController.text.trim();
                    final nameParts = trimmedName.split(' ');
                    final firstName = nameParts.length > 0 ? nameParts.first : '';
                    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : (nameParts.length == 1 ? '' : '');

                    final Map<String, dynamic> registrationData = {
                      'firstName': firstName,
                      'lastName': lastName,
                      'phone': _phoneController.text.trim(),
                      'location': _location1Controller.text.trim(),
                      'bio': _bioController.text.trim(),
                      'whyJoin': _whyJoinController.text.trim(),
                      'barnName': _barnNameController.text.trim(),
                      'yearsExperience': _selectedYears,
                      'programTags': _selectedProgramTags,
                      'showCircuits': _selectedHorseShows,
                      'facebook': _facebookController.text.trim(),
                      'website': _websiteController.text.trim(),
                      'instagram': _instagramController.text.trim(),
                      'federationId': _federationIdController.text.trim(),
                      'federationType': _selectedFederation,
                    };

                    try {
                      _authController.isLoading.value = true;
                      final apiService = Get.find<ApiService>();

                      // 1. Upload Profile Photo if selected
                      if (_profileImage != null) {
                        final avatarUrl = await _uploadFile(_profileImage!);
                        if (avatarUrl != null) {
                          registrationData['avatar'] = avatarUrl;
                        }
                      }

                      // 2. Upload Banner Image if selected
                      if (_bannerImage != null) {
                        final bannerUrl = await _uploadFile(_bannerImage!);
                        if (bannerUrl != null) {
                          registrationData['coverImage'] = bannerUrl;
                        }
                      }
                      
                      // 3. Submit all profile data to the unified endpoint
                      final response = await apiService.putRequest(
                        AppUrls.completeProfile,
                        registrationData,
                      );

                      if (response.statusCode == 200) {
                        Get.snackbar('Success', 'Your verified trainer application has been submitted successfully!',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.green,
                            colorText: Colors.white);
                        
                        // Navigate to the "Application Submitted" success view
                        _authController.navigateAfterRoleSet();
                      } else {
                        final errorMsg = response.body?['message'] ?? 'Unable to submit profile at this time. Please check your connection and try again.';
                        Get.snackbar('Submission Failed', errorMsg,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                      }
                    } catch (e) {
                      Get.snackbar('Error', 'An unexpected error occurred. Please try again later.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                    } finally {
                      _authController.isLoading.value = false;
                    }
                  }
                },
              )),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBasicDetailsCard();
      case 1:
        return Column(
          children: [
            _buildMediaCard(),
            const SizedBox(height: 16),
            _buildWhyJoinCard(),
            const SizedBox(height: 16),
            _buildExperienceCard(),
            const SizedBox(height: 16),
            _buildHorseShowsCard(),
            const SizedBox(height: 16),
            _buildSocialMediaCard(),
            const SizedBox(height: 16),
            _buildFederationInfoCard(),
            const SizedBox(height: 16),
            _buildBarnInfoCard(),
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
          CommonTextField(
            controller: _fullNameController,
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
                  controller: _phoneController,
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
          const SizedBox(height: 16),
          CommonTextField(
            controller: _barnNameController,
            label: AppStrings.barnName,
            hintText: AppStrings.enterYourBusinessName,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCard() {
    return _buildCard(
      title: "Upload Image",
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
        ],
      ),
    );
  }

  Widget _buildWhyJoinCard() {
    return _buildCard(
      title: "Why Join Our Community?",
      child: CommonTextField(
        label: "",
        controller: _whyJoinController,
        hintText: "Write a short note on why you are joining",
        maxLines: 4,
      ),
    );
  }

  Widget _buildBarnInfoCard() {
    return _buildCard(
      title: AppStrings.barnInformation,
      child: Column(
        children: [
          CommonTextField(
            controller: _location1Controller,
            label: AppStrings.locationI,
            hintText: AppStrings.enterBarnLocation,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: _location2Controller,
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
          CommonTextField(
            controller: _federationIdController,
            label: AppStrings.federationIdNumber,
            hintText: AppStrings.idNumber,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4), // Light green background from image
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.radio_button_unchecked, // Matches the thin circle in image
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
                      SizedBox(height: 4),
                      CommonText(
                        "Your federation number will be verified to ensure authenticity and maintain standards",
                        fontSize: AppTextSizes.size12,
                        color: Color(0xFF16A34A),
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
          CommonTextField(
            controller: _facebookController,
            label: AppStrings.facebook,
            hintText: AppStrings.facebookcomyourpage,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: _websiteController,
            label: AppStrings.websiteUrl,
            hintText: AppStrings.httpsyourwebsitecom,
            prefixIcon: const Icon(
              Icons.link,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: _instagramController,
            label: AppStrings.instagram,
            hintText: "@yourusername",
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
          GestureDetector(
            onTap: () {
              Get.bottomSheet(
                Container(
                  height: Get.height * 0.4,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      const CommonText("Years of Experience",
                          fontSize: AppTextSizes.size18,
                          fontWeight: FontWeight.bold),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: 101,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Center(
                                child: CommonText("$index Years",
                                    fontSize: AppTextSizes.size16,
                                    color: _selectedYears == index
                                        ? AppColors.primary
                                        : AppColors.textPrimary),
                              ),
                              onTap: () {
                                setState(() => _selectedYears = index);
                                Get.back();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.inputBackground,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText(
                    _selectedYears == 0 ? "Select years" : "$_selectedYears Years",
                    fontSize: AppTextSizes.size14,
                    color: _selectedYears == 0
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: _bioController,
            label: AppStrings.bio,
            hintText: "Write a short bio",
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
          GestureDetector(
            onTap: () => _showSelectionBottomSheet(
              title: "Select Program Tags",
              options: _allProgramTags,
              initialSelectedList: _selectedProgramTags,
              onConfirm: (list) {
                setState(() {
                  _selectedProgramTags.clear();
                  _selectedProgramTags.addAll(list);
                });
              },
            ),
            child: Container(
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
                  if (_selectedProgramTags.isEmpty)
                    const CommonText(
                      "Select your program specialties...",
                      color: AppColors.textSecondary,
                    ),
                  ..._selectedProgramTags.map(
                    (tag) => _buildTag(tag, () {
                      setState(() => _selectedProgramTags.remove(tag));
                    }),
                  ),
                ],
              ),
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
          GestureDetector(
            onTap: () => _showSelectionBottomSheet(
              title: "Select Horse Shows",
              options: _allHorseShows,
              initialSelectedList: _selectedHorseShows,
              onConfirm: (list) {
                setState(() {
                  _selectedHorseShows.clear();
                  _selectedHorseShows.addAll(list);
                });
              },
            ),
            child: Container(
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
                        if (_selectedHorseShows.isEmpty)
                          const CommonText(
                            "Select competition circuits...",
                            color: AppColors.textSecondary,
                          ),
                        ..._selectedHorseShows.map(
                          (tag) => _buildTag(tag, () {
                            setState(() => _selectedHorseShows.remove(tag));
                          }),
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

  Future<String?> _uploadFile(File file) async {
    final apiService = Get.find<ApiService>();
    try {
      final formData = FormData({
        'media': MultipartFile(file.path, filename: file.path.split('/').last),
      });

      final response = await apiService.postRequest(AppUrls.upload, formData);

      if (response.statusCode == 200) {
        return response.body['data']['url'];
      }
      debugPrint('Upload failed: ${response.statusText}');
      return null;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
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
