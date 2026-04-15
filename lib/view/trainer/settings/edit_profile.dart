import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../constant/app_strings.dart';
import '../../../utils/validators.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ProfileController profileController = Get.put(ProfileController());
  final _formKey = GlobalKey<FormState>();

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
  final TextEditingController _federationNameController = TextEditingController();
  final TextEditingController _federationNumberController = TextEditingController();
  final TextEditingController _searchCircuitsController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  File? _bannerImage;
  final RxList<String> _selectedProgramTags = <String>[].obs;
  final RxList<String> _selectedHorseShows = <String>[].obs;
  final RxList<String> _selectedHorseShowIds = <String>[].obs;
  final RxList<String> _selectedTags = <String>[].obs;

  Future<void> _pickImage(bool isProfile) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: isProfile ? 800 : 1600, // Profile is smaller, banner can be wider
        maxHeight: isProfile ? 800 : 1600,
        imageQuality: 85, // Adds native compression
      );
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
    debugPrint(
      '📝 EditProfileView: Initializing with ${profileController.yearsExperience} years, barn: ${profileController.barnName}',
    );

    _fullNameController.text = profileController.fullName;
    _phoneController.text = profileController.phone;
    _barnNameController.text = profileController.barnName;
    _bioController.text = profileController.bio;
    _location1Controller.text = profileController.location;
    _location2Controller.text = profileController.location2;
    
    final trainerData = profileController.userData['trainerId'] ?? profileController.userData;
    _federationNameController.text = trainerData['federationName'] ?? 'USEF (United States)';
    _federationNumberController.text = trainerData['federationNumber'] ?? profileController.userData['federationId'] ?? '';

    final expItems = ['0-1', '2-4', '5-9', '10+'];
    _yearsController.text = expItems.contains(profileController.yearsExperience)
        ? profileController.yearsExperience
        : '';

    _facebookController.text = profileController.user.value?.facebook ?? '';
    _websiteController.text = profileController.user.value?.website ?? '';
    _instagramController.text = profileController.user.value?.instagram ?? '';

    _selectedProgramTags.assignAll(profileController.selectedProgramTags);
    _selectedHorseShows.assignAll(profileController.selectedHorseShows.map((e) => _normalizeHorseShow(e)));

    _selectedHorseShowIds.assignAll(profileController.selectedHorseShowIds);
    _selectedTags.assignAll(profileController.user.value?.tags ?? []);

    // If profile is empty, fetch it
    if (profileController.userData.isEmpty) {
      profileController.fetchProfile().then((_) {
        if (mounted) {
          debugPrint(
            '🔄 EditProfileView: Re-initializing after fetch - ${profileController.yearsExperience} years',
          );
          setState(() {
            _fullNameController.text = profileController.fullName;
            _phoneController.text = profileController.phone;
            _barnNameController.text = profileController.barnName;
            _bioController.text = profileController.bio;
            _location1Controller.text = profileController.location;
            _location2Controller.text = profileController.location2;
            _facebookController.text =
                profileController.user.value?.facebook ?? '';
            _websiteController.text =
                profileController.user.value?.website ?? '';
            _instagramController.text =
                profileController.user.value?.instagram ?? '';
            
            final updatedTrainerData = profileController.userData['trainerId'] ?? profileController.userData;
            _federationNameController.text = updatedTrainerData['federationName'] ?? 'USEF (United States)';
            _federationNumberController.text = updatedTrainerData['federationNumber'] ?? profileController.userData['federationId'] ?? '';
            
            final expItems = ['0-1', '2-4', '5-9', '10+'];
            _yearsController.text = expItems.contains(profileController.yearsExperience)
                ? profileController.yearsExperience
                : '';

            _selectedProgramTags.assignAll(
              profileController.selectedProgramTags,
            );
            _selectedHorseShows.assignAll(profileController.selectedHorseShows.map((e) => _normalizeHorseShow(e)));

            _selectedHorseShowIds.assignAll(
              profileController.selectedHorseShowIds,
            );
            _selectedTags.assignAll(profileController.user.value?.tags ?? []);
          });
        }
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
    _federationNameController.dispose();
    _federationNumberController.dispose();
    _searchCircuitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Edit Profile',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicDetailsSection(),
                    _buildBarnInformationSection(),
                    _buildExperienceSection(),
                    _buildSocialMediaSection(),
                    _buildFrequentedCircuitsSection(),
                    _buildFederationInformationSection(),
                    _buildDynamicTagsSection(),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            title,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBasicDetailsSection() {
    return _buildSectionContainer(
      title: 'Basic Details',
      children: [
        const CommonText(
          'Profile Photo',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: () => _pickImage(true),
            child: Stack(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
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
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 18,
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
          'Banner image',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _pickImage(false),
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _bannerImage != null
                  ? Image.file(_bannerImage!, fit: BoxFit.cover)
                  : profileController.coverImage.isNotEmpty
                  ? CommonImageView(
                      url: profileController.coverImage,
                      fit: BoxFit.cover,
                    )
                  : const Center(
                      child: Icon(
                        Icons.add,
                        color: AppColors.textSecondary,
                        size: 28,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          'Full Name',
          _fullNameController,
          hint: 'Enter your full name',
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildPhoneField(),
      ],
    );
  }

  Widget _buildBarnInformationSection() {
    return _buildSectionContainer(
      title: 'Barn Information',
      children: [
        _buildTextField(
          'Barn Name',
          _barnNameController,
          hint: 'Enter your barn name',
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          'Location I',
          _location1Controller,
          hint: 'Enter barn location',
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          'Location II',
          _location2Controller,
          hint: 'Enter barn location',
          suffix: '(optional)',
        ),
      ],
    );
  }

  Widget _buildExperienceSection() {
    return _buildSectionContainer(
      title: 'Experience',
      children: [
        _buildExperienceDropdown(),
        const SizedBox(height: 20),
        _buildTextField(
          'Bio',
          _bioController,
          hint: 'Write a short bio',
          maxLines: 4,
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildExperienceDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText(
          AppStrings.yearsInIndustry,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _yearsController.text.isEmpty ? null : _yearsController.text,
          items: ['0-1', '2-4', '5-9', '10+'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: CommonText(value, fontSize: 14),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => _yearsController.text = val ?? '');
          },
          decoration: InputDecoration(
            hintText: 'Select years',
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderMedium),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderMedium),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMediaSection() {
    return _buildSectionContainer(
      title: 'Social Media & Website',
      children: [
        _buildTextField(
          'Facebook',
          _facebookController,
          hint: 'facebook.com/yourpage',

          validator: Validations.facebookValidator,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          'Website URI',
          _websiteController,
          hint: 'https://yourwebsite.com',
          prefixIcon: Icons.link_rounded,
          validator: Validations.urlValidator,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          'Instagram',
          _instagramController,
          isRequired: true,
          hint: '@yourusername',
          validator: Validations.instagramValidator,
        ),
      ],
    );
  }

  Widget _buildFrequentedCircuitsSection() {
    return _buildSectionContainer(
      title: 'Horse Shows & Circuits Frequented',
      children: [
        GestureDetector(
          onTap: () => _showHorseShowsBottomSheet(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderMedium),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CommonText(
                    'Search Horse Shows & Circuits',
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (_selectedHorseShows.isEmpty) return const SizedBox.shrink();
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _selectedHorseShows.map((tag) {
              return GestureDetector(
                onTap: () => _selectedHorseShows.remove(tag),
                child: _buildSelectedTag(_toTitleCase(tag)),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildFederationInformationSection() {
    return _buildSectionContainer(
      title: 'Federation Information',
      children: [
        _buildTextField(
          'Federation Name',
          _federationNameController,
          hint: 'e.g. USEF (United States)',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          'Federation ID Number',
          _federationNumberController,
          hint: 'ID Number',
        ),
      ],
    );
  }

  Widget _buildDynamicTagsSection() {
    return Obx(() {
      if (profileController.tagTypes.isEmpty) return const SizedBox.shrink();

      return Column(
        children: profileController.tagTypes.map((type) {
          final typeId = type['_id'] ?? '';
          final typeName = type['name'] ?? '';
          final values = (type['values'] as List? ?? []);
          final isSingleSelect = type['selectionType'] == 'single';
          final isRequired = type['isRequired'] == true;

          return _buildSectionContainer(
            title: isRequired ? '$typeName *' : typeName,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: values.map((val) {
                  final tagId = val['_id'] ?? '';
                  final tagName = val['name'] ?? '';
                  final isSelected = _selectedTags.contains(tagId);

                  return GestureDetector(
                    onTap: () {
                      if (isSingleSelect) {
                        if (isSelected) {
                          _selectedTags.remove(tagId);
                        } else {
                          // Remove others of same type
                          final allTypeTagIds = values
                              .map((v) => v['_id'] as String)
                              .toList();
                          _selectedTags.removeWhere(
                            (id) => allTypeTagIds.contains(id),
                          );
                          _selectedTags.add(tagId);
                        }
                      } else {
                        if (isSelected) {
                          _selectedTags.remove(tagId);
                        } else {
                          _selectedTags.add(tagId);
                        }
                      }
                    },
                    child: isSelected
                        ? _buildSelectedTag(tagName)
                        : _buildTag(tagName),
                  );
                }).toList(),
              ),
            ],
          );
        }).toList(),
      );
    });
  }

  void _showTagsBottomSheet({
    required String title,
    required bool isSingleSelect,
    required List values,
  }) {
    final TextEditingController searchController = TextEditingController();
    final RxList filteredValues = values.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.95,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText(
                        title,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: searchController,
                    onChanged: (val) {
                      filteredValues.assignAll(
                        values
                            .where(
                              (v) => (v['name'] as String)
                                  .toLowerCase()
                                  .contains(val.toLowerCase()),
                            )
                            .toList(),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: 'Search $title...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Obx(
                        () => Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: filteredValues.map((val) {
                            final tagId = val['_id'] ?? '';
                            final tagName = val['name'] ?? '';
                            final isSelected = _selectedTags.contains(tagId);

                            return GestureDetector(
                              onTap: () {
                                if (isSingleSelect) {
                                  if (isSelected) {
                                    _selectedTags.remove(tagId);
                                  } else {
                                    // Remove others of same type
                                    final allTagIds = values
                                        .map((v) => v['_id'] as String)
                                        .toList();
                                    _selectedTags.removeWhere(
                                      (id) => allTagIds.contains(id),
                                    );
                                    _selectedTags.add(tagId);
                                  }
                                } else {
                                  if (isSelected) {
                                    _selectedTags.remove(tagId);
                                  } else {
                                    _selectedTags.add(tagId);
                                  }
                                }
                              },
                              child: isSelected
                                  ? _buildSelectedTag(tagName)
                                  : _buildTag(tagName),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    bool isRequired = false,
    int maxLines = 1,
    String? suffix,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontFamily: 'Outfit',
            ),
            children: [
              TextSpan(text: label),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              if (suffix != null)
                TextSpan(
                  text: ' $suffix',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return 'Please enter ${label.toLowerCase()}';
            }
            if (validator != null && value != null && value.isNotEmpty) {
              return validator(value);
            }
            return null;
          },
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: AppColors.textSecondary)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderMedium),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderMedium),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value) {
    bool isPlaceholder = value.toLowerCase().contains('select');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          label,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.borderMedium),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                value,
                fontSize: 15,
                color: isPlaceholder
                    ? AppColors.textSecondary.withValues(alpha: 0.5)
                    : AppColors.textSecondary,
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText(
          'Phone Number',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderMedium),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    CommonText(
                      '+1',
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 24, color: AppColors.borderMedium),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  validator: Validations.phoneValidator,
                  maxLength: 10,
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: 'Enter phone number',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: CommonText(
        text,
        fontSize: 14,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  Widget _buildSelectedTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF000B48), width: 1.5),
      ),
      child: CommonText(
        text,
        fontSize: 14,
        color: const Color(0xFF000B48),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
  
  String _normalizeHorseShow(String text) {
    if (text.isEmpty) return text;
    if (text.contains(' • ')) {
      final parts = text.split(' • ');
      final circuit = parts.last.trim();
      final venue = parts.first.trim();
      
      // Prioritize Circuit (last part) if it's not a placeholder
      if (circuit.isNotEmpty && circuit != "-") return circuit;
      return venue;
    }
    return text;
  }

  void _showHorseShowsBottomSheet() {
    final TextEditingController searchController = TextEditingController();
    final List<Map<String, dynamic>> allShows = profileController.rawHorseShows;

    // Collect unique venue/circuit pairs
    final Set<String> uniqueLabelsSet = {};
    for (var show in allShows) {
      String venue = (show['showVenue']?.toString().trim() ?? '');
      if (venue == "-") venue = "";
      String circuit = (show['circuit']?.toString().trim() ?? '');
      if (circuit == "-") circuit = "";

      String label = "";
      if (circuit.isNotEmpty) {
        label = circuit;
      } else if (venue.isNotEmpty) {
        label = venue;
      } else {
        String showName = (show['name']?.toString().trim() ?? '');
        if (showName == "-") showName = "";
        label = showName;
      }

      if (label.isNotEmpty) {
        uniqueLabelsSet.add(label);
      }
    }

    final List<String> sortedLabels = uniqueLabelsSet.toList()..sort();
    final RxList<String> filteredLabels = RxList<String>(sortedLabels);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.95,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CommonText(
                        'Horse Shows & Circuits',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: searchController,
                    onChanged: (val) {
                      filteredLabels.assignAll(
                        sortedLabels
                            .where(
                              (s) => s.toLowerCase().contains(val.toLowerCase()),
                            )
                            .toList(),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: 'Search Horse Shows & Circuits...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Obx(
                        () => Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: filteredLabels.map((label) {
                            final isSelected = _selectedHorseShows.contains(
                              label,
                            );

                            return GestureDetector(
                              onTap: () {
                                if (isSelected) {
                                  _selectedHorseShows.remove(label);
                                } else {
                                  _selectedHorseShows.add(label);
                                }
                              },
                              child: isSelected
                                  ? _buildSelectedTag(_toTitleCase(label))
                                  : _buildTag(_toTitleCase(label)),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  void _showSingleSelectBottomSheet({
    required String title,
    required String currentValue,
    required List<String> items,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.95,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: CommonText(
                    title,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = item == currentValue;
                      return InkWell(
                        onTap: () {
                          onSelected(item);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade100),
                            ),
                          ),
                          child: Center(
                            child: CommonText(
                              item,
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMultiSelectBottomSheet({
    required String title,
    required RxList<String> selectedItems,
    required List<String> allItems,
    String? hint,
  }) {
    final TextEditingController searchController = TextEditingController();
    final RxList<String> filteredItems = RxList<String>(allItems);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.95,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText(
                        title,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: searchController,
                    onChanged: (val) {
                      filteredItems.assignAll(
                        allItems
                            .where(
                              (s) =>
                                  s.toLowerCase().contains(val.toLowerCase()),
                            )
                            .toList(),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: hint ?? 'Search...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderMedium,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Obx(
                        () => Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: filteredItems.map((item) {
                            final isSelected = selectedItems.contains(item);
                            return GestureDetector(
                              onTap: () {
                                if (isSelected) {
                                  selectedItems.remove(item);
                                } else {
                                  selectedItems.add(item);
                                }
                              },
                              child: isSelected
                                  ? _buildSelectedTag(item)
                                  : _buildTag(item),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -5),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderMedium),
                ),
                child: const Center(
                  child: CommonText(
                    'Cancel',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(
              () => GestureDetector(
                onTap: profileController.isLoading.value
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        // Dynamic Tag Validation
                        for (var type in profileController.tagTypes) {
                          if (type['isRequired'] == true) {
                            final typeName = type['name'] ?? 'Tag';
                            final values = (type['values'] as List? ?? []);
                            final allTypeTagIds = values
                                .map((v) => v['_id'] as String)
                                .toList();

                            final hasSelection = _selectedTags.any(
                              (id) => allTypeTagIds.contains(id),
                            );
                            if (!hasSelection) {
                              Get.snackbar(
                                'Required Field',
                                'Please select at least one $typeName',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                              );
                              return;
                            }
                          }
                        }
                        // 1. Upload Images if picked
                        if (_profileImage != null) {
                          await profileController.uploadImage(
                            _profileImage!.path,
                            'avatar',
                          );
                        }
                        if (_bannerImage != null) {
                          await profileController.uploadImage(
                            _bannerImage!.path,
                            'cover',
                          );
                        }

                        // 2. Prepare Name split
                        final nameParts = _fullNameController.text.trim().split(
                          ' ',
                        );
                        final firstName = nameParts.isNotEmpty
                            ? nameParts.first
                            : '';
                        final lastName = nameParts.length > 1
                            ? nameParts.sublist(1).join(' ')
                            : '';

                        // 3. Update Text Profile
                        final success = await profileController.updateProfile({
                          'firstName': firstName,
                          'lastName': lastName,
                          'phone': _phoneController.text.trim(),
                          'barnName': _barnNameController.text.trim(),
                          'bio': _bioController.text.trim(),
                          'location': _location1Controller.text.trim(),
                          'location2': _location2Controller.text.trim(),
                          'yearsExperience':
                             _yearsController.text.trim() ?? "",
                          'facebook': _facebookController.text.trim(),
                          'website': _websiteController.text.trim(),
                          'instagram': _instagramController.text.trim(),
                          'programTags': _selectedProgramTags.toList(),
                          'showCircuits': _selectedHorseShows.toList(),
                          'horseShows': _selectedHorseShowIds.toList(),
                          'tags': _selectedTags.toList(),
                          'federationName': _federationNameController.text.trim(),
                          'federationNumber': _federationNumberController.text.trim(),
                        });

                        if (success) {
                          Get.snackbar(
                            'Success',
                            'Profile updated successfully',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                          await Future.delayed(
                            const Duration(milliseconds: 1500),
                          );
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: profileController.isLoading.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const CommonText(
                            'Save',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
