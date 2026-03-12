import 'dart:io';
import 'dart:ui';

import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:catch_ride/view/trainer/trainer_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:form_field_validator/form_field_validator.dart';

class TrainerCompleteProfileView extends StatefulWidget {
  const TrainerCompleteProfileView({super.key});

  @override
  State<TrainerCompleteProfileView> createState() => _TrainerCompleteProfileViewState();
}

class _TrainerCompleteProfileViewState extends State<TrainerCompleteProfileView> {
  final ProfileController profileController = Get.put(ProfileController());
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _barnNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _location1Controller = TextEditingController();
  final TextEditingController _location2Controller = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _searchCircuitsController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  File? _bannerImage;
  final RxList<String> _selectedProgramTags = <String>[].obs;
  final RxList<String> _selectedHorseShows = <String>[].obs;
  final RxList<String> _selectedTags = <String>[].obs;

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
    
    _selectedProgramTags.assignAll(profileController.selectedProgramTags);
    _selectedHorseShows.assignAll(profileController.selectedHorseShows);
    _selectedTags.assignAll(profileController.user.value?.tags ?? []);
    
    if (profileController.userData.isEmpty) {
      profileController.fetchProfile().then((_) {
        _fullNameController.text = profileController.fullName;
        _phoneController.text = profileController.phone;
        _barnNameController.text = profileController.barnName;
        _bioController.text = profileController.bio;
        _location1Controller.text = profileController.location;
        _yearsController.text = profileController.yearsExperience > 0 ? profileController.yearsExperience.toString() : '';
        _selectedProgramTags.assignAll(profileController.selectedProgramTags);
        _selectedHorseShows.assignAll(profileController.selectedHorseShows);
        _selectedTags.assignAll(profileController.user.value?.tags ?? []);
      });
    }

    // Add listener for real-time searching
    _searchCircuitsController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _barnNameController.dispose();
    _bioController.dispose();
    _location1Controller.dispose();
    _location2Controller.dispose();
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
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Complete your Profile',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                  _buildUploadImageSection(),
                  const SizedBox(height: 16),
                  _buildBasicDetailsSection(),
                  const SizedBox(height: 16),
                  _buildBarnInformationSection(),
                  const SizedBox(height: 16),
                  _buildExperienceSection(),
                  const SizedBox(height: 16),
                  _buildFrequentedCircuitsSection(),
                  const SizedBox(height: 16),
                  _buildDynamicTagsSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }


  Widget _buildSectionContainer({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
      ),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(title, fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildUploadImageSection() {
    return _buildSectionContainer(
      title: 'Upload Image',
      children: [
        const CommonText('Profile Photo', fontSize: 13, color: AppColors.textPrimary),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: () => _pickImage(true),
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(_profileImage!, fit: BoxFit.cover)
                        : profileController.avatar.isNotEmpty 
                            ? CommonImageView(
                                url: profileController.avatar,
                                fit: BoxFit.cover,
                                fallbackIcon: Icons.person_outline_rounded,
                              )
                            : const Icon(Icons.person_outline_rounded, size: 48, color: AppColors.textSecondary),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const CommonText('Banner Image  (optional)', fontSize: 13, color: AppColors.textPrimary),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _pickImage(false),
          child: CustomPaint(
            painter: _bannerImage == null && profileController.coverImage.isEmpty 
                ? DashPainter(color: AppColors.border, borderRadius: 12) 
                : null,
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
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
                            child: Icon(Icons.add, color: AppColors.textSecondary, size: 28),
                          ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicDetailsSection() {
    return _buildSectionContainer(
      title: 'Basic Details',
      children: [
        _buildTextField(
          'Full Name', 
          _fullNameController, 
          hint: 'Enter your full name', 
          isRequired: true,
          validator: RequiredValidator(errorText: 'Please enter your full name'),
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
          hint: 'Enter your business name', 
          isRequired: true,
          validator: RequiredValidator(errorText: 'Please enter your barn name'),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          'Location I', 
          _location1Controller, 
          hint: 'Enter barn location', 
          isRequired: true,
          validator: RequiredValidator(errorText: 'Please enter your location'),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          'Location II', 
          _location2Controller, 
          hint: 'Enter your business name', 
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
          validator: RequiredValidator(errorText: 'Please write a short bio'),
        ),
      ],
    );
  }

  Widget _buildExperienceDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Years in Industry', fontSize: 13, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showSingleSelectBottomSheet(
            title: 'Years in Industry',
            currentValue: _yearsController.text,
            items: List.generate(51, (index) => index.toString(),),
            onSelected: (val) {
              setState(() => _yearsController.text = val);
            },
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: CommonText(
                    _yearsController.text.isEmpty ? 'Select years' : _yearsController.text,
                    fontSize: 14,
                    color: _yearsController.text.isEmpty
                        ? AppColors.textSecondary.withOpacity(0.5)
                        : AppColors.textPrimary,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ],
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
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: CommonText(title, fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                          ),
                          child: Center(
                            child: CommonText(
                              item,
                              fontSize: 16,
                              color: isSelected ? const Color(0xFF000B48) : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildFrequentedCircuitsSection() {
    return _buildSectionContainer(
      title: 'Horse Shows & Circuits Frequented',
      children: [
        _buildTextField(
          'Search Horse Shows & Circuits', 
          _searchCircuitsController, 
          hint: 'Search horse shows & circuits', 
          isRequired: true,
          validator: (val) {
            if (_selectedHorseShows.isEmpty) return 'Please select at least one circuit';
            return null;
          }
        ),
        const SizedBox(height: 16),
        Obx(() {
          final query = _searchCircuitsController.text.toLowerCase();
          final shows = profileController.allHorseShows.where((s) => s.toLowerCase().contains(query)).toList();
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: shows.map((tag) {
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
            }).toList(),
          );
        }),
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

          return _buildSectionContainer(
            title: typeName,
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
                          // Check if any other tag of this type is already selected
                          final valueIds = values.map((v) => v['_id'] as String).toList();
                          final hasExistingSelection = _selectedTags.any((id) => valueIds.contains(id));
                          
                          if (hasExistingSelection) {
                            Get.snackbar(
                              'Selection Limit', 
                              'Please select only one value for $typeName',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          } else {
                            _selectedTags.add(tagId);
                          }
                        }
                      } else {
                        if (isSelected) {
                          _selectedTags.remove(tagId);
                        } else {
                          _selectedTags.add(tagId);
                        }
                      }
                    },
                    child: isSelected ? _buildSelectedTag(tagName) : _buildTag(tagName),
                  );
                }).toList(),
              ),
            ],
          );
        }).toList(),
      );
    });
  }



  Widget _buildTextField(String label, TextEditingController controller, {String? hint, bool isRequired = false, int maxLines = 1, String? suffix, IconData? prefixIcon, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return CommonTextField(
      label: label,
      controller: controller,
      hintText: hint ?? '',
      isRequired: isRequired,
      maxLines: maxLines,
      suffixLabel: suffix,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: AppColors.textSecondary) : null,
      keyboardType: keyboardType,
      validator: validator,
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    CommonText('+1', fontSize: 14, color: AppColors.textPrimary),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.textSecondary),
                  ],
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 14),
                  validator: RequiredValidator(errorText: 'Please enter your phone number'),
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
      ),
      child: CommonText(text, fontSize: 13, color: AppColors.textPrimary),
    );
  }

  Widget _buildSelectedTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF000B48).withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF000B48), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: CommonText(text, fontSize: 13, color: const Color(0xFF000B48), fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Icon(Icons.close, size: 16, color: Color(0xFF000B48)),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Obx(() => GestureDetector(
        onTap: profileController.isLoading.value ? null : () async {
          if (!_formKey.currentState!.validate()) {
            return;
          }

          if (_profileImage == null && profileController.avatar.isEmpty) {
            Get.snackbar('Error', 'Please upload a profile photo', backgroundColor: Colors.red, colorText: Colors.white);
            return;
          }


          // 1. Upload Images
          if (_profileImage != null) {
            await profileController.uploadImage(_profileImage!.path, 'avatar');
          }
          if (_bannerImage != null) {
            await profileController.uploadImage(_bannerImage!.path, 'cover');
          }

          // 2. Prepare Name
          final nameParts = _fullNameController.text.trim().split(' ');
          final firstName = nameParts.first;
          final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : ' ';

          // 3. Update Text Profile — include isProfileCompleted:true
          final success = await profileController.updateProfile({
            'firstName': firstName,
            'lastName': lastName,
            'phone': _phoneController.text.trim(),
            'barnName': _barnNameController.text.trim(),
            'bio': _bioController.text.trim(),
            'location': _location1Controller.text.trim(),
            'location2': _location2Controller.text.trim(),
            'yearsExperience': int.tryParse(_yearsController.text) ?? 0,
            'programTags': _selectedProgramTags.toList(),
            'showCircuits': _selectedHorseShows.toList(),
            'tags': _selectedTags.toList(),
            'isProfileCompleted': true,
          });

          if (success) {
            // Save flag locally
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isProfileCompleted', true);
            // Navigate to trainer dashboard
            Get.offAll(() => const TrainerBottomNav());
          }
        },
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF000B48),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: profileController.isLoading.value
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const CommonText('Complete', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      )),
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

    Path dashPath = Path();
    double distance = 0.0;
    for (var measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashPath.addPath(
          measurePath.extractPath(distance, distance + dashWidth),
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
