import 'dart:io';
import 'dart:ui' as ui;
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/validators.dart';

class EditBarnManagerProfileView extends StatefulWidget {
  const EditBarnManagerProfileView({super.key});

  @override
  State<EditBarnManagerProfileView> createState() =>
      _EditBarnManagerProfileViewState();
}

class _EditBarnManagerProfileViewState
    extends State<EditBarnManagerProfileView> {
  final ProfileController profileController = Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _barnNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _selectedYears;

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  File? _bannerImage;

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
    _emailController.text = profileController.user.value?.email ?? '';
    _barnNameController.text = profileController.barnName;
    _bioController.text = profileController.bio;

    // For years, we might need to find which option matches.
    // BarnManager model usually stores it as string in the specific model
    // which is synced to user.yearsExperience (int) for trainers,
    // but for barn managers we use 'yearsInIndustry' string field in backend.
    final rawData = profileController.userData;
    if (rawData['barnManagerId'] != null &&
        rawData['barnManagerId']['yearsInIndustry'] != null) {
      _selectedYears = rawData['barnManagerId']['yearsInIndustry'];
    }

    // If profile is empty, fetch it
    if (profileController.userData.isEmpty) {
      profileController.fetchProfile().then((_) {
        setState(() {
          _fullNameController.text = profileController.fullName;
          _phoneController.text = profileController.phone;
          _emailController.text = profileController.user.value?.email ?? '';
          _barnNameController.text = profileController.barnName;
          _bioController.text = profileController.bio;

          final updatedRawData = profileController.userData;
          if (updatedRawData['barnManagerId'] != null &&
              updatedRawData['barnManagerId']['yearsInIndustry'] != null) {
            _selectedYears = updatedRawData['barnManagerId']['yearsInIndustry'];
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _barnNameController.dispose();
    _bioController.dispose();
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Edit Profile',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF344054),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFEAECF0), height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEAECF0)),
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
                        'Profile Photo',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF344054),
                      ),
                      const SizedBox(height: 16),
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
                                  border: Border.all(
                                    color: const Color(0xFFEAECF0),
                                    width: 1,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _profileImage != null
                                      ? Image.file(
                                          _profileImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : CommonImageView(
                                          url: profileController.avatar,
                                          fit: BoxFit.cover,
                                          fallbackIcon:
                                              Icons.person_outline_rounded,
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFD0D5DD),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                    color: Color(0xFF667085),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CommonText(
                            'Banner Image',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF344054),
                          ),
                          GestureDetector(
                            onTap: () => _pickImage(false),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _pickImage(false),
                        child: Container(
                          height: 130,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              if (_bannerImage != null ||
                                  profileController.coverImage.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _bannerImage != null
                                      ? Image.file(
                                          _bannerImage!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        )
                                      : CommonImageView(
                                          url: profileController.coverImage,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                )
                              else
                                CustomPaint(
                                  painter: DashedBorderPainter(),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add,
                                      color: Color(0xFF667085),
                                      size: 24,
                                    ),
                                  ),
                                ),
                            ],
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
                      const SizedBox(height: 20),
                      _buildTextField(
                        'Email',
                        _emailController,
                        hint: 'Enter your email',
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        'Barn Name',
                        _barnNameController,
                        hint: 'Enter your barn name',
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        'About',
                        _bioController,
                        hint: 'Write a short bio',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),
                      const CommonText(
                        'Years in industry',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF344054),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showSingleSelectBottomSheet(
                          title: 'Years in industry',
                          currentValue: _selectedYears ?? '',
                          items: List.generate(51, (index) => index.toString()),
                          onSelected: (val) {
                            setState(() => _selectedYears = val);
                          },
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD0D5DD)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: CommonText(
                                  (_selectedYears == null ||
                                          _selectedYears!.isEmpty)
                                      ? 'Select years'
                                      : _selectedYears!,
                                  fontSize: 15,
                                  color:
                                      (_selectedYears == null ||
                                          _selectedYears!.isEmpty)
                                      ? const Color(0xFF98A2B3)
                                      : const Color(0xFF101828),
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF667085),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF344054),
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
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15, color: Color(0xFF101828)),
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF00083B),
                width: 1.5,
              ),
            ),
            hintStyle: TextStyle(
              color: const Color(0xFF667085).withValues(alpha: 0.5),
              fontSize: 15,
            ),
            fillColor: Colors.white,
            filled: true,
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
          color: Color(0xFF344054),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD0D5DD)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Color(0xFFD0D5DD))),
                ),
                child: Row(
                  children: const [
                    CommonText('+91', fontSize: 15, color: Color(0xFF101828)),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: Color(0xFF667085),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  validator: Validations.phoneValidator,
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF101828),
                  ),
                  decoration: const InputDecoration(
                    counterText: "",
                    hintText: 'Enter phone number',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    hintStyle: TextStyle(
                      color: Color(0xFF98A2B3),
                      fontSize: 15,
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

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAECF0))),
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
                  border: Border.all(color: const Color(0xFFD0D5DD)),
                ),
                child: const Center(
                  child: CommonText(
                    'Cancel',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF344054),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => GestureDetector(
                onTap: profileController.isLoading.value
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;

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

                        final nameParts = _fullNameController.text.trim().split(
                          ' ',
                        );
                        final firstName = nameParts.isNotEmpty
                            ? nameParts.first
                            : '';
                        final lastName = nameParts.length > 1
                            ? nameParts.sublist(1).join(' ')
                            : '';

                        final success = await profileController.updateProfile({
                          'firstName': firstName,
                          'lastName': lastName,
                          'phone': _phoneController.text.trim(),
                          'barnName': _barnNameController.text.trim(),
                          'bio': _bioController.text.trim(),
                          'yearsInIndustry': _selectedYears,
                        });

                        if (success) {
                          Get.back();
                        }
                      },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00083B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: profileController.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const CommonText(
                            'Save',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
                    color: const Color(0xFF344054),
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
                                  ? const Color(0xFF00083B)
                                  : const Color(0xFF344054),
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
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFD0D5DD)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double dashWidth = 8;
    const double dashSpace = 4;
    final RRect rrect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      const Radius.circular(12),
    );
    final Path path = Path()..addRRect(rrect);

    final Path dashedPath = Path();
    for (final ui.PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0;
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
