import 'dart:io';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/vendor/groom/edit_vendor_profile_controller.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:catch_ride/view/vendor/braiding/profile/braiding_edit_profile_tab.dart';
import 'package:catch_ride/view/vendor/clipping/profile/clipping_edit_profile_tab.dart';
import 'package:catch_ride/view/vendor/farrier/profile/farrier_edit_profile_tab.dart';
import 'package:catch_ride/view/vendor/bodywork/profile/bodywork_edit_profile_tab.dart';
import '../../../../widgets/common_textfield.dart';

class EditVendorProfileView extends StatefulWidget {
  const EditVendorProfileView({super.key});

  @override
  State<EditVendorProfileView> createState() => _EditVendorProfileViewState();
}

class _EditVendorProfileViewState extends State<EditVendorProfileView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final controller = Get.put(EditVendorProfileController());

  @override
  void initState() {
    super.initState();
    // Initialize length correctly from start
    final initialLength = controller.assignedServices.length + 1;
    _tabController = TabController(length: initialLength, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Watch services list for changes and update controller count
    ever(controller.assignedServices, (services) {
      if (mounted) {
        _setupTabController(services.length + 1);
      }
    });

    // Ensure we trigger data fetch and sync initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (controller.assignedServices.isNotEmpty) {
          _setupTabController(controller.assignedServices.length + 1);
        } else {
          controller.fetchProfileData();
        }
      }
    });
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      controller.selectedServiceIndex.value = _tabController.index;
      controller.populateServiceData();
      setState(() {});
    }
  }

  void _setupTabController(int length) {
    if (_tabController.length != length) {
      if (!mounted) return;
      final oldIndex = _tabController.index;
      _tabController.removeListener(_handleTabChange);
      _tabController.dispose();
      _tabController = TabController(
        length: length,
        vsync: this,
        initialIndex: oldIndex < length ? oldIndex : 0,
      );
      _tabController.addListener(_handleTabChange);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Edit Profile',
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            _buildTabs(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Builder(
                  builder: (context) {
                    // Ensure index is valid for current controller
                    final currentIndex = _tabController.index;
                    if (currentIndex >= _tabController.length) {
                      return const SizedBox.shrink();
                    }
                    if (currentIndex == 0) {
                      return Column(
                        children: [
                          _buildBasicDetails(),
                          const SizedBox(height: 20),
                          _buildPaymentMethods(),
                          const SizedBox(height: 20),
                          _buildExperienceHighlights(),
                          const SizedBox(height: 40),
                        ],
                      );
                    } else {
                      final serviceIndex = currentIndex - 1;
                      if (serviceIndex < controller.assignedServices.length) {
                        final service =
                            controller.assignedServices[serviceIndex];
                        if (service['serviceType'] == 'Grooming') {
                          return _buildGroomingTab();
                        } else if (service['serviceType'] == 'Braiding') {
                          return _buildBraidingTab();
                        } else if (service['serviceType'] == 'Clipping') {
                          return ClippingEditProfileTab(controller: controller);
                        } else if (service['serviceType'] == 'Farrier') {
                          return FarrierEditProfileTab(controller: controller);
                        } else if (service['serviceType'] == 'Bodywork') {
                          return BodyworkEditProfileTab(controller: controller);
                        }
                      }
                      return const Center(
                        child: CommonText('Service details soon...'),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildTabs() {
    return Obx(() {
      final servicesList = controller.assignedServices;
      return Container(
        key: ValueKey('edit_tabs_container_${_tabController.length}_${servicesList.length}'), 
        color: Colors.white,
        child: Column(
          children: [
            TabBar(
              key: ValueKey('tab_bar_len_${_tabController.length}'),
              controller: _tabController,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.textPrimary,
              indicatorWeight: 3,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: List.generate(_tabController.length, (index) {
                if (index == 0) {
                  return const Tab(
                    child: CommonText(
                      'Basic Info',
                      fontSize: AppTextSizes.size14,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                final serviceIndex = index - 1;
                final serviceText = (serviceIndex < servicesList.length)
                    ? (servicesList[serviceIndex]['serviceType'] ?? 'Service')
                    : 'Service';
                return Tab(
                  child: CommonText(
                    serviceText,
                    fontSize: AppTextSizes.size14,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            ),
            const Divider(height: 1, thickness: 1),
          ],
        ),
      );
    });
  }

  Widget _buildBasicDetails() {
    return _buildCard(
      title: 'Basic Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPhotoSection(),
          const SizedBox(height: 24),
          _buildBannerSection(),
          const SizedBox(height: 24),
          CommonTextField(
            label: 'Full Name',
            hintText: 'Enter your full name',
            isRequired: true,
            controller: controller.fullNameController,
          ),
          const SizedBox(height: 20),
          _buildFieldLabel('Phone Number'),
          _buildPhoneField(),
          const SizedBox(height: 20),
          CommonTextField(
            label: 'Business Name',
            hintText: 'Enter your business name',
            suffixLabel: '(optional)',
            controller: controller.businessNameController,
          ),
          const SizedBox(height: 20),
          CommonTextField(
            label: 'About',
            hintText: 'Write a short bio',
            maxLines: 4,
            controller: controller.aboutController,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText(
          'Profile Photo',
          fontSize: AppTextSizes.size14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 16),
        Center(
          child: Stack(
            children: [
              Obx(
                () => Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                    image: controller.newProfileImage.value != null
                        ? DecorationImage(
                            image: FileImage(controller.newProfileImage.value!),
                            fit: BoxFit.cover,
                          )
                        : (controller.profilePhotoUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(
                                    controller.profilePhotoUrl.value,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null),
                  ),
                  child:
                      (controller.newProfileImage.value == null &&
                          controller.profilePhotoUrl.isEmpty)
                      ? const Icon(
                          Icons.person_outline,
                          size: 50,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: controller.pickProfileImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: Colors.black,
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

  Widget _buildBannerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CommonText(
              'Banner Image',
              fontSize: AppTextSizes.size14,
              color: AppColors.textSecondary,
            ),
            GestureDetector(
              onTap: controller.pickCoverImage,
              child: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(
          () => Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderLight,
                style: BorderStyle.solid,
              ),
              image: controller.newCoverImage.value != null
                  ? DecorationImage(
                      image: FileImage(controller.newCoverImage.value!),
                      fit: BoxFit.cover,
                    )
                  : (controller.coverImageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(controller.coverImageUrl.value),
                            fit: BoxFit.cover,
                          )
                        : null),
            ),
            child:
                (controller.newCoverImage.value == null &&
                    controller.coverImageUrl.isEmpty)
                ? const Center(
                    child: Icon(Icons.add, color: AppColors.textSecondary),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Row(
            children: const [
              CommonText('+1', fontSize: AppTextSizes.size14),
              Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller.phoneController,
              decoration: const InputDecoration(
                hintText: 'Enter phone number',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return _buildCard(
      title: 'Payment Methods',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Select the payment methods you accept.',
            fontSize: AppTextSizes.size14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 20),
          Obx(
            () => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.paymentOptions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio:
                    2.4, // Match balance between width and content
              ),
              itemBuilder: (context, index) {
                return _buildPaymentChip(controller.paymentOptions[index]);
              },
            ),
          ),
          Obx(() {
            if (controller.selectedPayments.contains('Other')) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CommonTextField(
                  label: '',
                  hintText: 'Write here...',
                  controller: controller.otherPaymentController,
                  maxLines: 4,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentChip(String method) {
    return Obx(() {
      final isSelected = controller.selectedPayments.contains(method);
      return GestureDetector(
        onTap: () => controller.togglePayment(method),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF3F4FF) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1E1B4B)
                  : AppColors.borderLight,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isSelected ? 0.08 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _getPaymentIcon(method),
              const SizedBox(width: 8),
              Expanded(
                child: CommonText(
                  method,
                  fontSize: AppTextSizes.size12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _getPaymentIcon(String method) {
    if (method == 'Venmo')
      return _buildCircleIcon(null, const Color(0xFF008CFF), text: 'V');
    if (method == 'Zelle')
      return _buildCircleIcon(null, const Color(0xFF673AB7), text: 'Z');
    if (method == 'Cash')
      return _buildCircleIcon(Icons.money, const Color(0xFF10B981));
    if (method == 'Credit Card')
      return _buildCircleIcon(Icons.credit_card, const Color(0xFF001F3F));
    if (method == 'ACH/Bank Transfer')
      return _buildCircleIcon(Icons.account_balance, const Color(0xFF78350F));
    return _buildCircleIcon(Icons.add, const Color(0xFF64748B));
  }

  Widget _buildCircleIcon(IconData? icon, Color color, {String? text}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: text != null
          ? Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            )
          : Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _buildExperienceHighlights() {
    return _buildCard(
      title: 'Experience Highlights',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Column(
              children: controller.highlightControllers.asMap().entries.map((
                entry,
              ) {
                final index = entry.key;
                final ctrl = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          label: '',
                          hintText: 'Write here...',
                          controller: ctrl,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => controller.removeHighlight(index),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: controller.addHighlight,
            child: const CommonText(
              '+ Add More',
              color: AppColors.linkBlue,
              fontSize: AppTextSizes.size14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroomingTab() {
    return Column(
      children: [
        _buildHomeBaseLocation(),
        const SizedBox(height: 20),
        _buildExperienceSection(),
        const SizedBox(height: 20),
        _buildDisciplinesSection(),
        const SizedBox(height: 20),
        _buildHorseLevelSection(),
        const SizedBox(height: 20),
        _buildRegionsCoveredSection(),
        const SizedBox(height: 20),
        _buildSocialMediaSection(),
        const SizedBox(height: 20),
        _buildAddPhotosSection(),
        const SizedBox(height: 20),
        _buildBarnSupportSection(),
        const SizedBox(height: 20),
        _buildHorseHandlingSection(),
        const SizedBox(height: 20),
        _buildAdditionalSkillsSection(),
        const SizedBox(height: 20),
        _buildTravelPreferencesSection(),
        const SizedBox(height: 20),
        _buildCancellationPolicySection(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildBraidingTab() {
    return BraidingEditProfileTab(controller: controller);
  }

  Widget _buildHomeBaseLocation() {
    return _buildCard(
      title: 'Home Base Location',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonTextField(
            label: 'Country',
            hintText: 'Select Country',
            isRequired: true,
            readOnly: true,
            controller: controller.countryController,
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('State/Province', isRequired: true),
          Obx(() => _buildDropdownTrigger(
            value: controller.selectedStateNode.value?['name'],
            isLoading: controller.isLoadingStates.value,
            hint: 'Select state/province',
            onTap: () => _showLocationBottomSheet(
              title: 'Select State',
              options: controller.states,
              onSelected: (node) => controller.onStateSelected(node),
            ),
          )),
          const SizedBox(height: 16),
          _buildFieldLabel('City', isRequired: true),
          Obx(() => _buildDropdownTrigger(
            value: controller.selectedCityNode.value?['name'],
            isLoading: controller.isLoadingCities.value,
            hint: controller.selectedStateNode.value == null ? 'Select state first' : 'Select city',
            onTap: controller.selectedStateNode.value == null 
                ? null 
                : () => _showLocationBottomSheet(
              title: 'Select City',
              options: controller.cities,
              onSelected: (node) => controller.onCitySelected(node),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildExperienceSection() {
    return _buildCard(
      title: 'Experience',
      child: Obx(
        () => _buildDropdownTrigger(
          value: controller.experience.value,
          hint: 'Select years of experience',
          onTap: () => _showPickerBottomSheet(
            title: 'Experience',
            options: controller.experienceOptions,
            onSelected: (val) => controller.experience.value = val,
          ),
        ),
      ),
    );
  }

  Widget _buildDisciplinesSection() {
    return _buildCard(
      title: 'Disciplines',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Select the disciplines you most commonly work with.',
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.disciplineOptions.map((disc) {
                final isSelected = controller.selectedDisciplines.contains(
                  disc,
                );
                return GestureDetector(
                  onTap: () => controller.toggleDiscipline(disc),
                  child: _buildChoiceChip(disc, isSelected),
                );
              }).toList(),
            ),
          ),
          Obx(() {
            if (controller.selectedDisciplines.contains('Other')) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CommonTextField(
                  label: '',
                  hintText: 'Write here...',
                  controller: controller.otherDisciplineController,
                  maxLines: 3,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildHorseLevelSection() {
    return _buildCard(
      title: 'Typical Level of Horses',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Select the level of horses you most commonly work with.',
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.horseLevelOptions.map((level) {
                final isSelected = controller.selectedHorseLevels.contains(
                  level,
                );
                return GestureDetector(
                  onTap: () => controller.toggleHorseLevel(level),
                  child: _buildChoiceChip(level, isSelected),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionsCoveredSection() {
    return _buildCard(
      title: 'Regions Covered',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Select the regions you work. Community work in availability details will be added later.',
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          _buildDropdownTrigger(
            hint: 'Select Regions...',
            onTap: () => _showMultiSelectBottomSheet(
              title: 'Select Regions',
              options: controller.regionOptions,
              selectedItems: controller.selectedRegions,
              onToggle: (v) => controller.toggleRegion(v),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              children: controller.selectedRegions
                  .map(
                    (region) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildRemovableTag(
                        region,
                        showRemove: true,
                        onRemove: () => controller.toggleRegion(region),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return _buildCard(
      title: 'Social Media & Website',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Please include at least one profile link or portfolio.',
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          CommonTextField(
            label: 'Facebook',
            hintText: 'facebook.com/yourpage',
            controller: controller.facebookController,
          ),
          const SizedBox(height: 16),
          CommonTextField(
            label: 'Instagram',
            hintText: '@yourusername',
            prefixIcon: const Icon(Icons.alternate_email, size: 18),
            controller: controller.instagramController,
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotosSection() {
    return _buildCard(
      title: 'Add Photos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Upload photos to showcase your work and details',
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Obx(
            () => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ...controller.existingPhotos.asMap().entries.map(
                  (entry) => _buildPhotoUploadBox(
                    imageUrl: entry.value,
                    onRemove: () => controller.removeExistingPhoto(entry.key),
                  ),
                ),
                ...controller.newPhotos.asMap().entries.map(
                  (entry) => _buildPhotoUploadBox(
                    imageFile: entry.value,
                    onRemove: () => controller.removeNewPhoto(entry.key),
                  ),
                ),
                _buildPhotoUploadBox(onTap: controller.addGroomingPhoto),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarnSupportSection() {
    return _buildCard(
      title: 'Show & Barn Support',
      child: Obx(
        () => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.supportOptions.map((opt) {
            final isSelected = controller.selectedSupport.contains(opt);
            return GestureDetector(
              onTap: () => controller.selectedSupport.contains(opt)
                  ? controller.selectedSupport.remove(opt)
                  : controller.selectedSupport.add(opt),
              child: _buildChoiceChip(opt, isSelected),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHorseHandlingSection() {
    return _buildCard(
      title: 'Horse Handling',
      child: Obx(
        () => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.handlingOptions.map((opt) {
            final isSelected = controller.selectedHandling.contains(opt);
            return GestureDetector(
              onTap: () => controller.selectedHandling.contains(opt)
                  ? controller.selectedHandling.remove(opt)
                  : controller.selectedHandling.add(opt),
              child: _buildChoiceChip(opt, isSelected),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAdditionalSkillsSection() {
    return _buildCard(
      title: 'Additional Skills',
      child: Obx(
        () => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.additionalSkillsOptions.map((opt) {
            final isSelected = controller.selectedAdditionalSkills.contains(
              opt,
            );
            return GestureDetector(
              onTap: () => controller.selectedAdditionalSkills.contains(opt)
                  ? controller.selectedAdditionalSkills.remove(opt)
                  : controller.selectedAdditionalSkills.add(opt),
              child: _buildChoiceChip(opt, isSelected),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTravelPreferencesSection() {
    return _buildCard(
      title: 'Travel Preferences',
      child: Obx(
        () => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.travelOptions.map((opt) {
            final isSelected = controller.selectedTravel.contains(opt);
            return GestureDetector(
              onTap: () => controller.selectedTravel.contains(opt)
                  ? controller.selectedTravel.remove(opt)
                  : controller.selectedTravel.add(opt),
              child: _buildChoiceChip(opt, isSelected),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCancellationPolicySection() {
    return _buildCard(
      title: 'Cancellation policy',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Set your cancellation preferences for bookings.',
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Obx(
            () => _buildDropdownTrigger(
              value: controller.cancellationPolicy.value,
              hint: 'Select Cancellation',
              onTap: () => _showPickerBottomSheet(
                title: 'Cancellation Policy',
                options: [
                  'Flexible (24+ hrs)',
                  'Moderate (48+ hrs)',
                  'Strict (7 days+)',
                ],
                onSelected: (val) => controller.cancellationPolicy.value = val,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: controller.isCustomCancellation.value,
                        onChanged: (v) =>
                            controller.isCustomCancellation.value = v ?? false,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const CommonText('Custom', fontSize: AppTextSizes.size14),
                  ],
                ),
                if (controller.isCustomCancellation.value) ...[
                  const SizedBox(height: 16),
                  CommonTextField(
                    label: '',
                    hintText: 'Write here...',
                    controller: controller.customCancellationController,
                    maxLines: 4,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Custom Widgets
  Widget _buildDropdownTrigger({
    String? value,
    required String hint,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CommonText(
                value ?? hint,
                color: value == null ? Colors.grey : AppColors.textPrimary,
                fontSize: AppTextSizes.size14,
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              )
            else
              const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: isSelected ? const Color(0xFF1E1B4B) : AppColors.borderLight,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: CommonText(
        label,
        fontSize: AppTextSizes.size12,
        color: isSelected ? const Color(0xFF1E1B4B) : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _buildRemovableTag(
    String label, {
    bool showRemove = false,
    VoidCallback? onRemove,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: showRemove ? const Color(0xFFF3F4F6) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(child: CommonText(label, fontSize: AppTextSizes.size14)),
          if (showRemove)
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadBox({
    String? imageUrl,
    File? imageFile,
    VoidCallback? onTap,
    VoidCallback? onRemove,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
              image: imageFile != null
                  ? DecorationImage(
                      image: FileImage(imageFile),
                      fit: BoxFit.cover,
                    )
                  : (imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null),
            ),
            child: (imageUrl == null && imageFile == null)
                ? const Icon(Icons.add, color: AppColors.textSecondary)
                : null,
          ),
        ),
        if (imageUrl != null || imageFile != null)
          Positioned(
            right: -2,
            top: -2,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 10),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            title,
            fontSize: AppTextSizes.size16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(
    String label, {
    bool isRequired = false,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CommonText(
            label,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          if (isRequired)
            const CommonText(
              ' *',
              color: Colors.red,
              fontSize: AppTextSizes.size14,
            ),
          if (isOptional)
            const CommonText(
              ' (optional)',
              color: AppColors.textSecondary,
              fontSize: AppTextSizes.size12,
            ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CommonButton(
                text: 'Cancel',
                backgroundColor: Colors.white,
                textColor: AppColors.textPrimary,
                borderColor: AppColors.borderLight,
                onPressed: () => Get.back(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(
                () => CommonButton(
                  text: controller.isSaving.value ? 'Saving...' : 'Save',
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.saveProfile,
                  isLoading: controller.isSaving.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pickers
  void _showPickerBottomSheet({
    required String title,
    required List<String> options,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: CommonText(
              title,
              fontSize: AppTextSizes.size18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: options
                  .map(
                    (opt) => ListTile(
                      title: Center(child: CommonText(opt)),
                      onTap: () {
                        onSelected(opt);
                        Navigator.pop(ctx);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showMultiSelectBottomSheet({
    required String title,
    required List<String> options,
    required List<String> selectedItems,
    required Function(String) onToggle,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scroll) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: CommonText(
                title,
                fontSize: AppTextSizes.size18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scroll,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final opt = options[index];
                  return Obx(
                    () => CheckboxListTile(
                      title: CommonText(opt),
                      value: selectedItems.contains(opt),
                      onChanged: (v) => onToggle(opt),
                      activeColor: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: CommonButton(
                text: 'Done',
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationBottomSheet({
    required String title,
    required List<Map<String, dynamic>> options,
    required Function(Map<String, dynamic>) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scroll) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: CommonText(
                title,
                fontSize: AppTextSizes.size18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scroll,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final node = options[index];
                  return ListTile(
                    title: CommonText(node['name'] ?? ''),
                    onTap: () {
                      onSelected(node);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
