import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ProfileController profileController = Get.find<ProfileController>();
  
  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _barnNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _location1Controller = TextEditingController();
  final TextEditingController _location2Controller = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _searchCircuitsController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  File? _bannerImage;
  final RxList<String> _selectedProgramTags = <String>[].obs;
  final RxList<String> _selectedHorseShows = <String>[].obs;

  Future<void> _pickImage(bool isProfile) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (isProfile) {
            _profileImage = File(image.path);
          } else {
            _bannerImage = File(image.path);
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fullNameController.text = profileController.fullName;
    _phoneController.text = profileController.phone;
    _barnNameController.text = profileController.barnName;
    _bioController.text = profileController.bio;
    _location1Controller.text = profileController.location;
    _yearsController.text = profileController.yearsExperience > 0 ? profileController.yearsExperience.toString() : '';
    _facebookController.text = profileController.user.value?.facebook ?? '';
    _websiteController.text = profileController.user.value?.website ?? '';
    _instagramController.text = profileController.user.value?.instagram ?? '';
    
    _selectedProgramTags.assignAll(profileController.selectedProgramTags);
    _selectedHorseShows.assignAll(profileController.selectedHorseShows);
    
    // If profile is empty, fetch it
    if (profileController.userData.isEmpty) {
      profileController.fetchProfile().then((_) {
        _fullNameController.text = profileController.fullName;
        _phoneController.text = profileController.phone;
        _barnNameController.text = profileController.barnName;
        _bioController.text = profileController.bio;
        _location1Controller.text = profileController.location;
        _facebookController.text = profileController.user.value?.facebook ?? '';
        _websiteController.text = profileController.user.value?.website ?? '';
        _instagramController.text = profileController.user.value?.instagram ?? '';
        _yearsController.text = profileController.yearsExperience > 0 ? profileController.yearsExperience.toString() : '';
        _selectedProgramTags.assignAll(profileController.selectedProgramTags);
        _selectedHorseShows.assignAll(profileController.selectedHorseShows);
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _barnNameController.dispose();
    _bioController.dispose();
    _location1Controller.dispose();
    _location2Controller.dispose();
    _facebookController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _yearsController.dispose();
    _searchCircuitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Edit Profile',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border.withOpacity(0.5), height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildBasicDetailsSection(),
                  const SizedBox(height: 16),
                  _buildExperienceSection(),
                  const SizedBox(height: 16),
                  _buildBarnInformationSection(),
                  const SizedBox(height: 16),
                  _buildFrequentedCircuitsSection(),
                  const SizedBox(height: 16),
                  _buildSocialMediaSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(title, fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBasicDetailsSection() {
    return _buildSectionContainer(
      title: 'Basic Details',
      children: [
        const CommonText('Profile Photo', fontSize: 13, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: () => _pickImage(true),
            child: Stack(
              children: [
                Obx(() => Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(_profileImage!, fit: BoxFit.cover)
                        : CommonImageView(
                            url: profileController.avatar,
                            fit: BoxFit.cover,
                            fallbackIcon: Icons.person_outline_rounded,
                          ),
                  ),
                )),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const CommonText('Banner image', fontSize: 13, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(false),
          child: Obx(() => Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _bannerImage != null
                  ? Image.file(_bannerImage!, fit: BoxFit.cover)
                  : profileController.coverImage.isNotEmpty
                      ? CommonImageView(
                          url: profileController.coverImage,
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Icon(Icons.add, color: AppColors.textSecondary),
                        ),
            ),
          )),
        ),
        const SizedBox(height: 20),
        _buildTextField('Full Name', _fullNameController, hint: 'Enter your full name', isRequired: true),
        const SizedBox(height: 16),
        _buildPhoneField(),
        const SizedBox(height: 16),
        _buildTextField('Barn Name', _barnNameController, hint: 'Enter your business name'),
      ],
    );
  }

  Widget _buildExperienceSection() {
    return _buildSectionContainer(
      title: 'Experience',
      children: [
        _buildTextField('Years in Industry', _yearsController, hint: 'e.g. 5', keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildTextField('Bio', _bioController, hint: 'Write a short bio', maxLines: 4),
        const SizedBox(height: 16),
        const CommonText('Program tags', fontSize: 13, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: profileController.allProgramTags.map((tag) {
            return Obx(() {
              final isSelected = _selectedProgramTags.contains(tag);
              return GestureDetector(
                onTap: () {
                  if (isSelected) {
                    _selectedProgramTags.remove(tag);
                  } else {
                    _selectedProgramTags.add(tag);
                  }
                },
                child: isSelected ? _buildSelectedTag(tag) : _buildTag(tag),
              );
            });
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildBarnInformationSection() {
    return _buildSectionContainer(
      title: 'Barn Information',
      children: [
        _buildTextField('Barn Name', _barnNameController, hint: 'Enter your business name', isRequired: true),
        const SizedBox(height: 16),
        _buildTextField('Location I', _location1Controller, hint: 'Enter barn location', isRequired: true),
        const SizedBox(height: 16),
        _buildTextField('Location II', _location2Controller, hint: 'Enter your business name', suffix: '(optional)'),
      ],
    );
  }

  Widget _buildFrequentedCircuitsSection() {
    return _buildSectionContainer(
      title: 'Horse Shows & Circuits Frequented',
      children: [
        _buildTextField('Search Horse Shows & Circuits', _searchCircuitsController, hint: 'WEF'),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: profileController.allHorseShows.map((tag) {
            return Obx(() {
              final isSelected = _selectedHorseShows.contains(tag);
              return GestureDetector(
                onTap: () {
                  if (isSelected) {
                    _selectedHorseShows.remove(tag);
                  } else {
                    _selectedHorseShows.add(tag);
                  }
                },
                child: isSelected ? _buildSelectedTag(tag) : _buildTag(tag),
              );
            });
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildSocialMediaSection() {
    return _buildSectionContainer(
      title: 'Social Media & Website',
      children: [
        _buildTextField('Facebook', _facebookController, hint: 'facebook.com/yourpage', isRequired: true),
        const SizedBox(height: 16),
        _buildTextField('Website URI', _websiteController, hint: 'https://yourwebsite.com', prefixIcon: Icons.link),
        const SizedBox(height: 16),
        _buildTextField('Instagram', _instagramController, hint: '@yourusername'),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint, bool isRequired = false, int maxLines = 1, String? suffix, IconData? prefixIcon, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontFamily: 'Outfit'),
            children: [
              TextSpan(text: label),
              if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
              if (suffix != null) TextSpan(text: ' $suffix', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.normal)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: AppColors.textSecondary) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Phone Number', fontSize: 13, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: const [
                    CommonText('+1', fontSize: 14, color: AppColors.textPrimary),
                    Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textSecondary),
                  ],
                ),
              ),
              Container(width: 1, height: 24, color: AppColors.border),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.7)),
      ),
      child: CommonText(text, fontSize: 12, color: AppColors.textSecondary),
    );
  }

  Widget _buildSelectedTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF000B48).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF000B48)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonText(text, fontSize: 12, color: const Color(0xFF000B48), fontWeight: FontWeight.bold),
          const SizedBox(width: 4),
          const Icon(Icons.close, size: 14, color: Color(0xFF000B48)),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: CommonText('Cancel', fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => GestureDetector(
              onTap: profileController.isLoading.value ? null : () async {
                // 1. Upload Images if picked
                if (_profileImage != null) {
                  await profileController.uploadImage(_profileImage!.path, 'avatar');
                }
                if (_bannerImage != null) {
                  await profileController.uploadImage(_bannerImage!.path, 'cover');
                }

                // 2. Prepare Name split
                final nameParts = _fullNameController.text.trim().split(' ');
                final firstName = nameParts.isNotEmpty ? nameParts.first : '';
                final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

                // 3. Update Text Profile
                final success = await profileController.updateProfile({
                  'firstName': firstName,
                  'lastName': lastName,
                  'phone': _phoneController.text.trim(),
                  'barnName': _barnNameController.text.trim(),
                  'bio': _bioController.text.trim(),
                  'location': _location1Controller.text.trim(),
                  'yearsExperience': int.tryParse(_yearsController.text) ?? 0,
                  'facebook': _facebookController.text.trim(),
                  'website': _websiteController.text.trim(),
                  'instagram': _instagramController.text.trim(),
                  'programTags': _selectedProgramTags,
                  'showCircuits': _selectedHorseShows,
                });

                if (success) {
                  Get.snackbar('Success', 'Profile updated successfully',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2));
                  await Future.delayed(const Duration(milliseconds: 1500));
                  // Use Navigator instead of Get.back() to avoid dismissing the snackbar overlay
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: profileController.isLoading.value 
                      ? const Color(0xFF000B48).withOpacity(0.7) 
                      : const Color(0xFF000B48),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: profileController.isLoading.value
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const CommonText('Save', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}
