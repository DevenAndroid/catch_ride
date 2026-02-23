import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/trainer/onboarding/application_submit_trainer_screen.dart';

class EditProfileController extends GetxController {
  // Basic Details
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // Barns (Allow adding multiple barns with emails and locations)
  final RxList<Map<String, TextEditingController>> barns =
      <Map<String, TextEditingController>>[
        {
          'name': TextEditingController(),
          'email': TextEditingController(),
          'location': TextEditingController(),
        },
      ].obs;

  void addBarn() {
    barns.add({
      'name': TextEditingController(),
      'email': TextEditingController(),
      'location': TextEditingController(),
    });
  }

  void removeBarn(int index) {
    barns[index]['name']?.dispose();
    barns[index]['email']?.dispose();
    barns[index]['location']?.dispose();
    barns.removeAt(index);
  }

  // Federation Information
  final federationController = TextEditingController(
    text: 'USEF (United States)',
  );
  final federationIdController = TextEditingController();
  final RxBool federationVerification = false.obs;

  // Social Media & Website
  final facebookController = TextEditingController();
  final websiteController = TextEditingController();
  final instagramController = TextEditingController();

  // Experience
  final yearsInIndustryController = TextEditingController();
  final bioController = TextEditingController();

  // Program tags
  final availableTags = <String>['Jump', 'Dance', 'Walk', 'Trot', 'Canter'];
  final selectedTags = <String>[].obs;

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  // Horse Shows & Circuits Frequented (Mock Data from DB)
  final availableShows = <Map<String, String>>[
    {'venue': 'Wellington International', 'date': 'Jan 10 - Mar 31, 2026'},
    {
      'venue': 'World Equestrian Center, Ocala',
      'date': 'Feb 01 - Apr 15, 2026',
    },
    {'venue': 'HITS Saugerties', 'date': 'May 20 - Sep 05, 2026'},
  ];
  final Rx<Map<String, String>?> selectedShow = Rx<Map<String, String>?>(null);

  // Confirmation check
  final RxBool isConfirmed = false.obs;

  void saveProfile() {
    // if (!federationVerification.value || !isConfirmed.value) {
    //   Get.snackbar(
    //     'Required',
    //     'Please complete verification checks and confirm that all information is accurate.',
    //     backgroundColor: AppColors.softRed,
    //     colorText: Colors.white,
    //   );
    //   return;
    // }
    // Navigate to Application Submitted Screen
    Get.offAll(() => const ApplicationSubmitTrainerScreen());
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    for (var barn in barns) {
      barn['name']?.dispose();
      barn['email']?.dispose();
      barn['location']?.dispose();
    }
    federationController.dispose();
    federationIdController.dispose();
    facebookController.dispose();
    websiteController.dispose();
    instagramController.dispose();
    yearsInIndustryController.dispose();
    bioController.dispose();
    super.onClose();
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());

    return Scaffold(
      appBar: AppBar(title: const Text('Profile setup'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.grey200,
                      image: const DecorationImage(
                        image: NetworkImage('https://via.placeholder.com/150'),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.deepNavy,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Basic Details
            Text('Basic Details', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Full Name *',
              hint: 'Enter your full name',
              controller: controller.nameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Phone Number',
              hint: '+91 Enter phone number',
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 32),

            // Barn Information
            Text('Barn Information', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < controller.barns.length; i++)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Barn ${i + 1}',
                              style: AppTextStyles.titleMedium,
                            ),
                            if (controller.barns.length > 1)
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: AppColors.softRed,
                                ),
                                onPressed: () => controller.removeBarn(i),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: 'Barn ${i + 1} Name *',
                          hint: 'Enter your business name',
                          controller: controller.barns[i]['name']!,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Barn ${i + 1} Email',
                          hint: 'e.g. contact@barn.com',
                          controller: controller.barns[i]['email']!,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Location ${i + 1} *',
                          hint: 'Enter barn location',
                          controller: controller.barns[i]['location']!,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  TextButton.icon(
                    onPressed: controller.addBarn,
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.deepNavy,
                    ),
                    label: const Text(
                      'Add Another Barn',
                      style: TextStyle(
                        color: AppColors.deepNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Federation Information
            Text('Federation Information', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            Text('Federation', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: 'USEF (United States)',
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'USEF (United States)',
                  child: Text('USEF (United States)'),
                ),
              ],
              onChanged: (val) {},
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Federation ID Number',
              hint: 'ID Number',
              controller: controller.federationIdController,
            ),
            const SizedBox(height: 16),
            Obx(
              () => GestureDetector(
                onTap: () => controller.federationVerification.value =
                    !controller.federationVerification.value,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: controller.federationVerification.value
                        ? AppColors.successGreen.withOpacity(0.1)
                        : AppColors.grey50,
                    border: Border.all(
                      color: controller.federationVerification.value
                          ? AppColors.successGreen
                          : AppColors.grey300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        controller.federationVerification.value
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: controller.federationVerification.value
                            ? AppColors.successGreen
                            : AppColors.grey400,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Federation Verification',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: controller.federationVerification.value
                                    ? AppColors.successGreen
                                    : AppColors.grey700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your federation number will be verified to ensure name, city and state all match records.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: controller.federationVerification.value
                                    ? AppColors.successGreen
                                    : AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Social Media & Website
            Text('Social Media & Website', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Facebook *',
              hint: 'facebook.com/yourpage',
              controller: controller.facebookController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Website URL',
              hint: 'https://yourwebsite.com',
              controller: controller.websiteController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Instagram',
              hint: '@yourusername',
              controller: controller.instagramController,
            ),

            const SizedBox(height: 32),

            // Experience
            Text('Experience', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            Text('Years in industry', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'Select years',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              items: const [
                DropdownMenuItem(value: '1-5', child: Text('1-5 years')),
                DropdownMenuItem(value: '5-10', child: Text('5-10 years')),
                DropdownMenuItem(value: '10+', child: Text('10+ years')),
              ],
              onChanged: (val) {
                controller.yearsInIndustryController.text = val ?? '';
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Bio',
              hint: 'Write a short bio',
              controller: controller.bioController,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            Text('Program tags', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.availableTags.map((tag) {
                  final isSelected = controller.selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (_) => controller.toggleTag(tag),
                    selectedColor: AppColors.deepNavy,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Horse Shows & Circuits Frequented
            Text('Horse Shows & Circuits', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            Text('Select Upcoming Show', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Obx(
              () => DropdownButtonFormField<Map<String, String>>(
                value: controller.selectedShow.value,
                hint: const Text('Select a show from database'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                items: controller.availableShows.map((show) {
                  return DropdownMenuItem<Map<String, String>>(
                    value: show,
                    child: Text('${show['venue']} (${show['date']})'),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.selectedShow.value = value;
                },
                isExpanded: true,
              ),
            ),

            const SizedBox(height: 32),

            Obx(
              () => Row(
                children: [
                  Checkbox(
                    value: controller.isConfirmed.value,
                    onChanged: (val) {
                      controller.isConfirmed.value = val ?? false;
                    },
                    activeColor: AppColors.deepNavy,
                  ),
                  Expanded(
                    child: Text(
                      'I confirm all information is accurate',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Submit Application',
              onPressed: controller.saveProfile,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
