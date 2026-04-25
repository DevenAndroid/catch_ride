import 'dart:io';

import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/add_new_listing_controller.dart';
import 'package:catch_ride/view/trainer/list/listing_preview_view.dart';
import 'package:catch_ride/widgets/common_textfield.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:intl/intl.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controllers/google_api_controller.dart';

class AddNewListingView extends StatefulWidget {
  const AddNewListingView({super.key});

  @override
  State<AddNewListingView> createState() => _AddNewListingViewState();
}

class _AddNewListingViewState extends State<AddNewListingView> {
  final AddNewListingController controller = Get.put(AddNewListingController());
  final  googleApiController = Get.put(GoogleApiController());
  final ProfileController profileController = Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  int _currentStep = 1;

  Future<void> _selectDateTime(
    BuildContext context,
    TextEditingController textController,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      textController.text = DateFormat('dd MMM yyyy').format(pickedDate);
    }
  }

  List<String> get _locationSuggestions {
    final Set<String> locations = {};
    for (var show in profileController.rawHorseShows) {
      final city = show['city']?.toString().trim() ?? '';
      final state = show['state']?.toString().trim() ?? '';
      final country = show['country']?.toString().trim() ?? '';

      List<String> parts = [];
      if (city.isNotEmpty) parts.add(city);
      if (state.isNotEmpty) parts.add(state);
      if (country.isNotEmpty) parts.add(country);

      if (parts.isNotEmpty) {
        locations.add(parts.join(', '));
      }
    }
    final list = locations.toList();
    list.sort();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
      backgroundColor: Colors.white,
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
            if (_currentStep > 1) {
              setState(() {
                _currentStep--;
              });
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            } else {
              Get.back();
            }
          },
        ),
        title: const CommonText(
          'Add new listing',
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
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
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepIndicator(),
                    const SizedBox(height: 32),
                    if (_currentStep == 1) ...[
                      const CommonText(
                        'Horse Information',
                        fontSize: AppTextSizes.size18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 20),
                      Form(key: _formKey, child: _buildHorseInformationForm()),
                    ] else if (_currentStep == 2) ...[
                      const CommonText(
                        'Listing Type',
                        fontSize: AppTextSizes.size18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      const CommonText(
                        'Select one or more types',
                        fontSize: AppTextSizes.size14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 24),
                      _buildListingTypeSelection(),
                    ] else if (_currentStep == 3) ...[
                      const CommonText(
                        'Other information',
                        fontSize: AppTextSizes.size18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 20),
                      _buildOtherInformationForm(),
                    ] else if (_currentStep == 4) ...[
                      const CommonText(
                        'Upload Images and video',
                        fontSize: AppTextSizes.size18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 20),
                      _buildUploadCard(),
                    ] else if (_currentStep == 5) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CommonText(
                            'Availability',
                            fontSize: AppTextSizes.size18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.addEntry();
                            },
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.add,
                                  color: Color(0xFF2C74EA),
                                  size: 18,
                                ),
                                SizedBox(width: 4),
                                CommonText(
                                  'Add Entry',
                                  color: Color(0xFF2C74EA),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildAvailabilityForm(),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    ),
   );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final stepNumber = index + 1;
        final isActive = stepNumber == _currentStep;
        final isCompleted = stepNumber < _currentStep;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? const Color(0xFF047857)
                      : Colors.white, // Green for completed
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF047857)
                        : (isActive ? AppColors.textPrimary : AppColors.border),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : CommonText(
                        '$stepNumber',
                        fontSize: AppTextSizes.size14,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
              ),
              if (index < 4)
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColors.border,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUploadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Upload Photos',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 12),
          Obx(
            () => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ...controller.uploadedImages.asMap().entries.map((entry) {
                  int index = entry.key;
                  String url = entry.value;
                  return Stack(
                    children: [
                      Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: CommonImageView(
                            url: url,
                            fit: BoxFit.cover,
                            radius: 11,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.removeUploadedImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                ...controller.localImages.asMap().entries.map((entry) {
                  int index = entry.key;
                  File file = entry.value;
                  return Stack(
                    children: [
                      Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.file(file, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.removeLocalImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                GestureDetector(
                  onTap: () async {
                    final List<XFile> images = await controller.picker
                        .pickMultiImage(imageQuality: 80, maxWidth:  1600, // Profile is smaller, banner can be wider
                      maxHeight:  1600,);
                    if (images.isNotEmpty) {
                      controller.localImages.addAll(
                        images.map((x) => File(x.path)),
                      );
                    }
                  },
                  child: _buildAddButton(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const CommonText(
            'Upload Video',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 12),
          Obx(
            () => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ...controller.uploadedVideos.asMap().entries.map((entry) {
                  int index = entry.key;
                  String url = entry.value;
                  return Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.video_library,
                                color: AppColors.primary,
                                size: 40,
                              ),
                              SizedBox(height: 4),
                              CommonText(
                                'Uploaded',
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.removeUploadedVideo(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                ...controller.localVideos.asMap().entries.map((entry) {
                  int index = entry.key;
                  File file = entry.value;
                  return Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.videocam,
                                color: AppColors.primary,
                                size: 40,
                              ),
                              SizedBox(height: 4),
                              CommonText(
                                'Local Video',
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.removeVideo(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                GestureDetector(
                  onTap: () async {
                    final XFile? video = await controller.picker.pickVideo(
                      source: ImageSource.gallery,
                    );
                    if (video != null) {
                      final file = File(video.path);
                      if (file.lengthSync() > 200 * 1024 * 1024) {
                        Get.snackbar(
                          'Error',
                          'Video size exceeds 200 MB limit',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      } else {
                        controller.localVideos.add(file);
                      }
                    }
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.border,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_outlined,
                          color: AppColors.primary,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        CommonText(
                          'Add Video',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 4),
                        CommonText(
                          '(Max 200 MB)',
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              text: 'Video link ',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              children: const [
                TextSpan(
                  text: ' (optional)',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.link,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.videoLinkController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      hintText: 'https://url.com',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppTextSizes.size14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: 85,
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        color: const Color(0xFFFAFAFA),
      ),
      child: const Center(
        child: Icon(Icons.add, color: AppColors.textSecondary, size: 24),
      ),
    );
  }

  Widget _buildHorseInformationForm() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonTextField(
                label: 'Listing Title',
                controller: controller.listingTitleController,
                hintText: 'Children\'s Hunter',
                //textCapitalization: TextCapitalization.words,
                isRequired: true,
                validator: (val) {
                  if (val == null || val.trim().isEmpty)
                    return 'Please enter the listing title';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CommonTextField(
                label: 'Horse\'s Registered Name',
                controller: controller.horseNameController,
                //textCapitalization: TextCapitalization.words,
                hintText: 'Enter name',
                isRequired: true,
                validator: (val) {
                  if (val == null || val.trim().isEmpty)
                    return 'Please enter the horse name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'Location',
                      style: TextStyle(
                        fontSize: AppTextSizes.size14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                      children: [
                        // TextSpan(
                        //   text: ' *',
                        //   style: TextStyle(color: Color(0xFFD92D20)),
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  LayoutBuilder(
                    builder: (context, constraints) => Obx(() {
                      if(googleApiController.refreshInt.value>=0){}
                      // Accessing googleSuggestions here makes Obx listen to it
                      final gSuggestions = googleApiController.googleSuggestions;

                      return Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          final query = textEditingValue.text.trim();
                          
                          // If query is empty, show all local suggestions (on tap behavior)
                          if (query.isEmpty) {
                            return _locationSuggestions;
                          }

                          final queryLower = query.toLowerCase();
                          final local = _locationSuggestions.where((String option) {
                            return option.toLowerCase().contains(queryLower);
                          }).toList();
                          
                          final google = gSuggestions.map((e) => e['name']!).toList();
                          
                          // Combine and return unique results
                          return [...google].toSet().toList();
                        },
                        onSelected: (String selection) {
                          controller.locationController.text = selection;
                        },
                        fieldViewBuilder:
                            (
                              BuildContext context,
                              TextEditingController fieldTextEditingController,
                              FocusNode fieldFocusNode,
                              VoidCallback onFieldSubmitted,
                            ) {
                              if (controller.locationController.text.isNotEmpty &&
                                  fieldTextEditingController.text.isEmpty) {
                                fieldTextEditingController.text =
                                    controller.locationController.text;
                              }

                              // Use a custom listener instead of adding one every build
                              // For simplicity and alignment with search_filter_overlay, we use onChanged
                              
                              return TextFormField(
                                controller: fieldTextEditingController,
                                focusNode: fieldFocusNode,
                                textCapitalization: TextCapitalization.words,
                                onChanged: (val) {
                                  controller.locationController.text = val;
                                  googleApiController.searchGooglePlaces(val);
                                },
                                // validator: (val) {
                                //   if (val == null || val.trim().isEmpty)
                                //     return 'Please enter the location';
                                //   return null;
                                // },
                                style: const TextStyle(
                                  fontSize: AppTextSizes.size14,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Enter horse\'s location',
                                ),
                              );
                            },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                constraints: const BoxConstraints(maxHeight: 250),
                                width: constraints.maxWidth,
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(height: 1, color: AppColors.border),
                                  itemBuilder: (BuildContext context, int index) {
                                    final String option = options.elementAt(index);
                                    return InkWell(
                                      onTap: () => onSelected(option),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors.lightGray
                                                    .withOpacity(0.7),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.location_on_rounded,
                                                size: 16,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                option,
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonTextField(
                            label: 'Year Foaled',
                            controller: controller.ageController,
                            hintText: 'Enter year foaled',
                            keyboardType: TextInputType.number,
                           // isRequired: true,
                           //  validator: (val) {
                           //    if (val == null || val.trim().isEmpty)
                           //      return 'Required';
                           //    final year = int.tryParse(val);
                           //    if (year == null || val.length != 4)
                           //      return 'Enter 4-digit year';
                           //    if (year < 1900 || year > DateTime.now().year)
                           //      return 'Invalid year';
                           //    return null;
                           //  },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              controller.calculatedAge.value > 0
                                  ? '${controller.calculatedAge.value} years old'
                                  : "",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonTextField(
                          label: 'Height',
                          controller: controller.heightController,
                          hintText: 'Enter height',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          isRequired: false,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(""),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'Breed',
                      style: TextStyle(
                        fontSize: AppTextSizes.size14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                      children: [
                        // TextSpan(
                        //   text: ' *',
                        //   style: TextStyle(color: Color(0xFFD92D20)),
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  LayoutBuilder(
                    builder: (context, constraints) => Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        final query = textEditingValue.text.toLowerCase();
                        return controller.breeds.where((String option) {
                          return option.toLowerCase().contains(query);
                        });
                      },
                      onSelected: (String selection) {
                        controller.breedController.text = selection;
                      },
                      fieldViewBuilder:
                          (
                            BuildContext context,
                            TextEditingController fieldTextEditingController,
                            FocusNode fieldFocusNode,
                            VoidCallback onFieldSubmitted,
                          ) {
                            if (controller.breedController.text.isNotEmpty &&
                                fieldTextEditingController.text.isEmpty) {
                              fieldTextEditingController.text =
                                  controller.breedController.text;
                            }
                            fieldTextEditingController.addListener(() {
                              controller.breedController.text =
                                  fieldTextEditingController.text;
                            });

                            return TextFormField(
                              controller: fieldTextEditingController,
                              focusNode: fieldFocusNode,
                              textCapitalization: TextCapitalization.words,
                              // validator: (val) {
                              //   if (val == null || val.trim().isEmpty)
                              //     return 'Please enter the breed';
                              //   return null;
                              // },
                              style: const TextStyle(
                                fontSize: AppTextSizes.size14,
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Enter breed',
                              ),
                            );
                          },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              constraints: const BoxConstraints(maxHeight: 200),
                              width: constraints.maxWidth,
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(
                                      height: 1,
                                      color: AppColors.border,
                                    ),
                                itemBuilder: (BuildContext context, int index) {
                                  final String option = options.elementAt(
                                    index,
                                  );
                                  return InkWell(
                                    onTap: () {
                                      onSelected(option);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        option,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildColorSelection(),
              const SizedBox(height: 20),

              _buildDisciplineSelection(),
              const SizedBox(height: 20),
              CommonTextField(
                label: 'Description',
                controller: controller.descriptionController,
               // textCapitalization: TextCapitalization.sentences,
                hintText: 'Write here...',
              //  isRequired: true,
                maxLines: 4,
                // validator: (val) {
                //   if (val == null || val.trim().isEmpty)
                //     return 'Please enter the description';
                //   return null;
                // },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  text: 'USEF #',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: ' (optional)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: controller.usefNumberController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Enter USEF #',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: AppTextSizes.size14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListingTypeSelection() {
    return Obx(
      () => Column(
        children: [
          _buildListingTypeCard(
            title: 'Sale',
            isSelected: controller.selectedListingTypes.contains('Sale'),
            onTap: () => controller.toggleListingType('Sale'),
          ),
          const SizedBox(height: 16),
          _buildListingTypeCard(
            title: 'Annual Lease',
            isSelected: controller.selectedListingTypes.contains(
              'Annual Lease',
            ),
            onTap: () => controller.toggleListingType('Annual Lease'),
          ),
          const SizedBox(height: 16),
          _buildListingTypeCard(
            title: 'Short Term or Circuit Lease',
            isSelected: controller.selectedListingTypes.contains(
              'Short Term or Circuit Lease',
            ),
            onTap: () =>
                controller.toggleListingType('Short Term or Circuit Lease'),
          ),
          const SizedBox(height: 16),
          _buildListingTypeCard(
            title: 'Weekly Lease',
            isSelected: controller.selectedListingTypes.contains(
              'Weekly Lease',
            ),
            onTap: () => controller.toggleListingType('Weekly Lease'),
          ),
        ],
      ),
    );
  }

  Widget _buildListingTypeCard({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isInquire = controller.inquireForPrice[title] ?? false;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE9F0FF)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00084D)
                      : const Color(0xFFD1D5DB),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText(
                    title,
                    fontSize: AppTextSizes.size16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? const Color(0xFF00084D)
                        : const Color(0xFF475467),
                  ),
                ],
              ),
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.inquireForPrice[title] = !isInquire;
                      controller.inquireForPrice.refresh();
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isInquire
                                ? const Color(0xFF00084D)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isInquire
                                  ? const Color(0xFF00084D)
                                  : const Color(0xFFD0D5DD),
                            ),
                          ),
                          child: isInquire
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        const CommonText(
                          'Inquire for price',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                  if (!isInquire) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CommonText(
                                'Min Price',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF344054),
                              ),
                              const SizedBox(height: 8),
                              _buildPriceTextField(
                                controller:
                                    controller.minPriceControllers[title]!,
                                hintText: 'Enter min price',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CommonText(
                                'Max Price',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF344054),
                              ),
                              const SizedBox(height: 8),
                              _buildPriceTextField(
                                controller:
                                    controller.maxPriceControllers[title]!,
                                hintText: 'Enter max price',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
        ThousandsSeparatorInputFormatter(),
      ],
      style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF667085), fontSize: 16),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00084D), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildOtherInformationForm() {
    return Obx(() {
      if (controller.isTagsLoading.value) {
        return const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.tagTypes.isEmpty) {
        return const SizedBox(
          height: 100,
          child: Center(
            child: CommonText(
              'No tags available',
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return Column(
        children: controller.tagTypes.map((type) {
          final String typeName = type['name'] ?? 'Tag';
          final List values = type['values'] ?? [];
          final List<String> tagNames = values
              .map((v) => v['name'].toString())
              .toList();
          final Map<String, String> nameToId = {
            for (var v in values) v['name'].toString(): v['_id'].toString(),
          };
          final String selectionType = type['selectionType'] ?? 'multiple';
          final bool isRequired = type['isRequired'] ?? false;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildDynamicTagSection(
              title: typeName,
              tagNames: tagNames,
              nameToId: nameToId,
              selectionType: selectionType,
              isRequired: isRequired,
              values: values,
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildColorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText(
          'Color',
          fontSize: AppTextSizes.size14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 12),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 10,
            children: controller.colors.map((color) {
              final isSelected = controller.selectedColor.value == color;
              return GestureDetector(
                onTap: () {
                  controller.selectedColor.value = color;
                  controller.colorController.text = color;
                },
                child: _buildTagChip(color, isSelected),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDisciplineSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText(
          'Discipline',
          fontSize: AppTextSizes.size14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 12),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 10,
            children: ['Hunter', 'Jumper', 'Equitation'].map((discipline) {
              final isSelected = controller.selectedDisciplines.contains(
                discipline,
              );
              return GestureDetector(
                onTap: () {
                  if (isSelected) {
                    controller.selectedDisciplines.remove(discipline);
                  } else {
                    controller.selectedDisciplines.add(discipline);
                  }
                  controller.disciplineController.text = controller
                      .selectedDisciplines
                      .join(', ');
                },
                child: _buildTagChip(discipline, isSelected),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicTagSection({
    required String title,
    required List<String> tagNames,
    required Map<String, String> nameToId,
    required String selectionType,
    required bool isRequired,
    required List values,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: isRequired ? '$title ' : title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: '*',
                    style: TextStyle(color: Colors.red),
                  ),
                if (!isRequired &&
                    (title.toLowerCase().contains('optional') ||
                        title == 'Opportunity Tag'))
                  const TextSpan(
                    text: ' (optional)',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            return Wrap(
              spacing: 8,
              runSpacing: 12,
              children: tagNames.map((name) {
                final id = nameToId[name]!;
                final isSelected = controller.selectedTags.contains(id);
                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      controller.selectedTags.remove(id);
                    } else {
                      if (selectionType == 'single') {
                        final allTypeIds = values
                            .map((v) => v['_id'].toString())
                            .toList();
                        controller.selectedTags.removeWhere(
                          (tagId) => allTypeIds.contains(tagId),
                        );
                      }
                      controller.selectedTags.add(id);
                    }
                  },
                  child: _buildTagChip(name, isSelected),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF00084D) : const Color(0xFFE5E7EB),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: CommonText(
        label,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? const Color(0xFF00084D) : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildAvailabilityForm() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CommonText(
                    'Active Status',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 4),
                  CommonText(
                    'Make listing visible to others',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              Obx(
                () => Switch(
                  value: controller.activeStatus.value,
                  onChanged: (val) {
                    controller.activeStatus.value = val;
                  },
                  activeTrackColor: const Color(0xFF10B981),
                  activeColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => Column(
            children: [
              ...controller.availabilityEntries.asMap().entries.map((entry) {
                int index = entry.key;
                AvailabilityEntry availabilityEntry = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CommonText(
                              'Entry ${availabilityEntry.id}',
                              fontSize: AppTextSizes.size14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            SizedBox(height: 2,),
                            if (controller.availabilityEntries.length > 1)
                              GestureDetector(
                                onTap: () {
                                  controller.removeEntry(index);
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                        // New Searchable Autocomplete for Show, Venue, or Circuit
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                text: 'Show Venue',
                                style: TextStyle(
                                  fontSize: AppTextSizes.size14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Inter',
                                ),
                                children: [
                                  TextSpan(
                                    text: ' (optional)',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            LayoutBuilder(
                              builder: (context, constraints) => Autocomplete<Map<String, dynamic>>(
                                displayStringForOption: (option) =>
                                    option['name'] ?? '',
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text.isEmpty) {
                                        return const Iterable<
                                          Map<String, dynamic>
                                        >.empty();
                                      }
                                      final query = textEditingValue.text
                                          .toLowerCase();
                                      return profileController.rawHorseShows
                                          .where((show) {
                                            final name = (show['name'] ?? '')
                                                .toString()
                                                .toLowerCase();
                                            final venue =
                                                (show['showVenue'] ?? '')
                                                    .toString()
                                                    .toLowerCase();
                                            final circuit =
                                                (show['circuit'] ?? '')
                                                    .toString()
                                                    .toLowerCase();
                                            return name.contains(query) ||
                                                venue.contains(query) ||
                                                circuit.contains(query);
                                          });
                                    },
                                onSelected: (Map<String, dynamic> selection) {
                                  availabilityEntry.showVenueController.text =
                                      selection['name'] ?? '';
                                  availabilityEntry.showIdController.text =
                                      selection['_id'] ?? selection['id'] ?? '';

                                  // Auto-fill City/State
                                  final city = selection['city'] ?? '';
                                  final state = selection['state'] ?? '';
                                  final country = selection['country'] ?? '';
                                  
                                  List<String> parts = [];
                                  if (city.isNotEmpty) parts.add(city.toString());
                                  if (state.isNotEmpty) parts.add(state.toString());
                                  if (country.isNotEmpty) parts.add(country.toString());
                                  
                                  if (parts.isNotEmpty) {
                                    availabilityEntry.cityStateController.text = parts.join(', ');
                                  }

                                  // Auto-fill Dates
                                  final DateFormat formatter = DateFormat(
                                    'dd MMM yyyy',
                                  );
                                  if (selection['startDate'] != null) {
                                    try {
                                      final start = DateTime.parse(
                                        selection['startDate'],
                                      );
                                      availabilityEntry
                                          .startDateController
                                          .text = formatter.format(
                                        start,
                                      );
                                    } catch (_) {}
                                  }
                                  if (selection['endDate'] != null) {
                                    try {
                                      final end = DateTime.parse(
                                        selection['endDate'],
                                      );
                                      availabilityEntry.endDateController.text =
                                          formatter.format(end);
                                    } catch (_) {}
                                  }
                                },
                                fieldViewBuilder:
                                    (
                                      context,
                                      textController,
                                      focusNode,
                                      onFieldSubmitted,
                                    ) {
                                      // Sync with entry controller
                                      if (availabilityEntry
                                              .showVenueController
                                              .text
                                              .isNotEmpty &&
                                          textController.text.isEmpty) {
                                        textController.text = availabilityEntry
                                            .showVenueController
                                            .text;
                                      }
                                      textController.addListener(() {
                                        availabilityEntry
                                                .showVenueController
                                                .text =
                                            textController.text;
                                      });

                                      return TextFormField(
                                        controller: textController,
                                        focusNode: focusNode,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Search horse show, venue or circuit...',
                                          suffixIcon: const Icon(
                                            Icons.search,
                                            color: AppColors.textSecondary,
                                            size: 20,
                                          ),
                                        ),
                                        style: const TextStyle(fontSize: 14),
                                      );
                                    },
                                optionsViewBuilder: (context, onSelected, options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 4.0,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: constraints.maxWidth,
                                        constraints: const BoxConstraints(
                                          maxHeight: 300,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        child: ListView.separated(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: options.length,
                                          separatorBuilder: (context, index) =>
                                              const Divider(height: 1),
                                          itemBuilder: (context, index) {
                                            final show = options.elementAt(
                                              index,
                                            );
                                            final name = show['name'] ?? '';
                                            final venueName =
                                                show['showVenue'] ??
                                                'Unknown Venue';
                                            final city = show['city'] ?? '';
                                            final state = show['state'] ?? '';
                                            final country = show['country'] ?? '';

                                            String dateRange = '';
                                            try {
                                              if (show['startDate'] != null &&
                                                  show['endDate'] != null) {
                                                final start = DateTime.parse(
                                                  show['startDate'],
                                                );
                                                final end = DateTime.parse(
                                                  show['endDate'],
                                                );
                                                final df = DateFormat('MMM d');
                                                final dfYear = DateFormat(
                                                  'yyyy',
                                                );
                                                dateRange =
                                                    '${df.format(start)}–${df.format(end)}, ${dfYear.format(end)}';
                                              }
                                            } catch (_) {}

                                            return InkWell(
                                              onTap: () => onSelected(show),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CommonText(
                                                      name,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    CommonText(
                                                      '$venueName • $city${city.isNotEmpty && state.isNotEmpty ? ", " : ""}$state${(city.isNotEmpty || state.isNotEmpty) && country.isNotEmpty ? ", " : ""}$country • $dateRange',
                                                      fontSize: 12,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CommonTextField(
                          label: 'City/State',
                          controller: availabilityEntry.cityStateController,
                          hintText: 'e.g., Welling.',
                          readOnly: true, // Locked as per requirement
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CommonTextField(
                                label: 'Start Date',
                                controller:
                                    availabilityEntry.startDateController,
                                hintText: 'Select date',
                                readOnly: true,
                                onTap: () => _selectDateTime(
                                  context,
                                  availabilityEntry.startDateController,
                                ),
                                suffixIcon: const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CommonTextField(
                                label: 'End Date',
                                controller: availabilityEntry.endDateController,
                                hintText: 'Select date',
                                readOnly: true,
                                onTap: () => _selectDateTime(
                                  context,
                                  availabilityEntry.endDateController,
                                ),
                                suffixIcon: const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: controller.addEntry,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CommonText(
                      'Add another entry',
                      fontSize: AppTextSizes.size16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
    final bool isLastStep = _currentStep == 5;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isLastStep) {
                  Get.to(() => const ListingPreviewView());
                } else if (_currentStep > 1) {
                  setState(() {
                    _currentStep--;
                  });
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                } else {
                  Get.back();
                }
              },
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLastStep) ...[
                      const Icon(
                        Icons.remove_red_eye_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    CommonText(
                      isLastStep
                          ? 'Preview'
                          : (_currentStep > 1 ? 'Back' : 'Cancel'),
                      fontSize: AppTextSizes.size16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_currentStep < 5) {
                  if (_currentStep == 1) {
                    if (!_formKey.currentState!.validate()) return;
                    if (controller.selectedDisciplines.isEmpty) {
                      Get.snackbar(
                        'Required',
                        'Please select a discipline',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    if (controller.calculatedAge.value <= 0) {
                      Get.snackbar(
                        'Invalid Input',
                        'Please enter a valid Year Foaled',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }
                  } else if (_currentStep == 2) {
                    if (!controller.validateStep2()) return;
                  } else if (_currentStep == 3) {
                    if (!controller.validateStep3()) return;
                  } else if (_currentStep == 4) {
                    if (controller.localImages.isEmpty && controller.uploadedImages.isEmpty) {
                      Get.snackbar(
                        'Required',
                        'Please upload at least one image',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    if (!controller.validateStep4()) return;
                  }
                  setState(() {
                    _currentStep++;
                  });
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                } else {
                  controller.publishListing();
                }
              },
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CommonText(
                  isLastStep ? 'Publish Listing' : 'Next',
                  fontSize: AppTextSizes.size16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
                          child: Row(
                            children: [
                              Expanded(child: CommonText(item, fontSize: 15)),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                            ],
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

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = ',';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String oldText = oldValue.text.replaceAll(separator, '');
    String newText = newValue.text.replaceAll(separator, '');

    // Allow only one decimal point
    if (newText.contains('.')) {
      List<String> parts = newText.split('.');
      if (parts.length > 2) {
        return oldValue;
      }
      // Limit decimal places to 2
      if (parts[1].length > 2) {
        return oldValue;
      }
    }

    // Format integer part with commas
    String formattedText = _formatWithCommas(newText);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  String _formatWithCommas(String text) {
    if (text.isEmpty) return '';
    List<String> parts = text.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    integerPart = integerPart.replaceAllMapped(reg, (Match m) => '${m[1]},');

    return decimalPart != null ? '$integerPart.$decimalPart' : integerPart;
  }
}
