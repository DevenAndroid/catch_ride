import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/add_new_listing_controller.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ListingPreviewView extends StatefulWidget {
  const ListingPreviewView({super.key});

  @override
  State<ListingPreviewView> createState() => _ListingPreviewViewState();
}

class _ListingPreviewViewState extends State<ListingPreviewView> {
  final controller = Get.find<AddNewListingController>();
  final profileController = Get.find<ProfileController>();

  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Video state
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoPlayerController;
  bool _isYoutube = false;
  bool _hasVideo = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    final String videoLink = controller.videoLinkController.text;
    if (videoLink.isEmpty) return;

    _hasVideo = true;
    final String? youtubeId = YoutubePlayer.convertUrlToId(videoLink);

    if (youtubeId != null) {
      _isYoutube = true;
      _youtubeController = YoutubePlayerController(
        initialVideoId: youtubeId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    } else {
      _isYoutube = false;
      try {
        _videoPlayerController =
            VideoPlayerController.networkUrl(Uri.parse(videoLink))
              ..initialize().then((_) {
                setState(() {});
              });
      } catch (e) {
        print('Error initializing video: $e');
        _hasVideo = false;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _youtubeController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = profileController.user.value;
    final String userName = user?.fullName ?? 'User';
    final String userAvatar = user?.displayAvatar ?? '';

    return Scaffold(
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
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Horse Detail',
          fontSize: AppTextSizes.size18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Active Listing Toggle
            Obx(
              () => Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        CommonText(
                          'Active Listing',
                          fontWeight: FontWeight.bold,
                          fontSize: AppTextSizes.size14,
                        ),
                        SizedBox(height: 4),
                        CommonText(
                          'Make listing visible to others',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    Switch(
                      value: controller.activeStatus.value,
                      onChanged: (val) => controller.activeStatus.value = val,
                      activeThumbColor: const Color(0xFF047857),
                    ),
                  ],
                ),
              ),
            ),
            // Trainer Info
            ListTile(
              leading: CommonImageView(
                url: userAvatar,
                height: 44,
                width: 44,
                shape: BoxShape.circle,
                fallbackIcon: Icons.person_outline,
              ),
              title: CommonText(
                userName,
                fontWeight: FontWeight.bold,
                fontSize: AppTextSizes.size16,
              ),
              subtitle: const CommonText(
                'Professional Horse Trainer',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              trailing: const Icon(Icons.more_vert),
            ),
            // Image Carousel
            _buildImageSection(),
            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.selectedListingTypes
                                .map((tag) => _buildChip(tag))
                                .toList(),
                          ),
                        ),
                        const Icon(
                          Icons.share_outlined,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.bookmark_border,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CommonText(
                    controller.listingTitleController.text.isEmpty
                        ? 'Untitled Listing'
                        : controller.listingTitleController.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  if (controller.descriptionController.text.isNotEmpty)
                    CommonText(
                      controller.descriptionController.text,
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  const SizedBox(height: 16),
                  if (controller.availabilityEntries.isNotEmpty &&
                      controller.availabilityEntries.first.cityStateController
                          .text.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        CommonText(
                          controller.availabilityEntries.first
                              .cityStateController.text,
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // USEF Number
            if (controller.usefNumberController.text.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFFF9FAFB),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CommonText(
                      'Horse USEF number',
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    CommonText(
                      controller.usefNumberController.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ],
                ),
              ),
            // Details
            _buildDetailsSection(),
            // Availability
            _buildAvailabilitySection(),
            // Tags
            _buildTagsGridSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final images = controller.localImages;
    final int totalItems = images.length + (_hasVideo ? 1 : 0);

    if (totalItems == 0) {
      return const CommonImageView(
        height: 260,
        width: double.infinity,
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: totalItems,
            itemBuilder: (context, index) {
              if (index < images.length) {
                return CommonImageView(
                  file: images[index],
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              } else {
                return Container(
                  color: Colors.black,
                  child: _isYoutube
                      ? YoutubePlayer(
                          controller: _youtubeController!,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: AppColors.primary,
                        )
                      : _videoPlayerController!.value.isInitialized
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _videoPlayerController!.value.isPlaying
                                      ? _videoPlayerController!.pause()
                                      : _videoPlayerController!.play();
                                });
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AspectRatio(
                                    aspectRatio: _videoPlayerController!
                                        .value.aspectRatio,
                                    child: VideoPlayer(_videoPlayerController!),
                                  ),
                                  if (!_videoPlayerController!.value.isPlaying)
                                    const Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.white,
                                      size: 64,
                                    ),
                                ],
                              ),
                            )
                          : const Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ),
        if (totalItems > 1)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CommonText(
                '${_currentPage + 1} / $totalItems',
                color: Colors.white,
                fontSize: AppTextSizes.size12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    final List<Map<String, String>> detailItems = [
      if (controller.horseNameController.text.isNotEmpty)
        {'label': 'Horse name', 'value': controller.horseNameController.text},
      if (controller.ageController.text.isNotEmpty)
        {'label': 'Age', 'value': '${controller.ageController.text} Years'},
      if (controller.heightController.text.isNotEmpty)
        {'label': 'Height', 'value': controller.heightController.text},
      if (controller.breedController.text.isNotEmpty)
        {'label': 'Breed', 'value': controller.breedController.text},
      if (controller.colorController.text.isNotEmpty)
        {'label': 'Color', 'value': controller.colorController.text},
      if (controller.disciplineController.text.isNotEmpty)
        {'label': 'Discipline', 'value': controller.disciplineController.text},
    ];

    if (detailItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Details'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: detailItems.asMap().entries.map((entry) {
              final detail = entry.value;
              final isLast = entry.key == detailItems.length - 1;
              return Column(
                children: [
                  _buildDetailRow(detail['label']!, detail['value']!),
                  if (!isLast) const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    return Obx(() {
      final validEntries = controller.availabilityEntries
          .where((e) =>
              e.cityStateController.text.isNotEmpty ||
              e.showVenueController.text.isNotEmpty)
          .toList();

      if (validEntries.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Availability'),
          ...validEntries.map((entry) => _buildAvailabilityCard(entry)),
        ],
      );
    });
  }

  Widget _buildTagsGridSection() {
    return Obx(() {
      final hasPrograms = controller.selectedProgramTags.isNotEmpty;
      final hasOpportunities = controller.selectedOpportunityTags.isNotEmpty;
      final hasExperience = controller.selectedExperienceTags.isNotEmpty;
      final hasPersonalities = controller.selectedPersonalityTags.isNotEmpty;

      if (!hasPrograms &&
          !hasOpportunities &&
          !hasExperience &&
          !hasPersonalities) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (hasPrograms || hasOpportunities)
              Row(
                children: [
                  if (hasPrograms)
                    Expanded(
                        child: _buildTagCard('Program Tag',
                            controller.selectedProgramTags.first))
                  else if (hasOpportunities)
                    const Spacer(),
                  if (hasPrograms && hasOpportunities)
                    const SizedBox(width: 12),
                  if (hasOpportunities)
                    Expanded(
                        child: _buildTagCard('Opportunity Tag',
                            controller.selectedOpportunityTags.first))
                  else if (hasPrograms)
                    const Spacer(),
                ],
              ),
            if ((hasPrograms || hasOpportunities) &&
                (hasExperience || hasPersonalities))
              const SizedBox(height: 12),
            if (hasExperience || hasPersonalities)
              Row(
                children: [
                  if (hasExperience)
                    Expanded(
                        child: _buildTagCard('Experience',
                            controller.selectedExperienceTags.first))
                  else if (hasPersonalities)
                    const Spacer(),
                  if (hasExperience && hasPersonalities)
                    const SizedBox(width: 12),
                  if (hasPersonalities)
                    Expanded(
                        child: _buildTagCard('Personality Tag',
                            controller.selectedPersonalityTags.first))
                  else if (hasExperience)
                    const Spacer(),
                ],
              ),
          ],
        ),
      );
    });
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CommonText(label, fontSize: 12, color: AppColors.textSecondary),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: CommonText(title, fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: CommonText(
            label,
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const CommonText(' : ', fontWeight: FontWeight.bold, fontSize: 14),
        Expanded(
          child: CommonText(value, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildAvailabilityCard(AvailabilityEntry entry) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            'Location ${entry.id}',
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: CommonText(
                  '${entry.showVenueController.text}${entry.showVenueController.text.isNotEmpty && entry.cityStateController.text.isNotEmpty ? ", " : ""}${entry.cityStateController.text}',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (entry.startDateController.text.isNotEmpty ||
              entry.endDateController.text.isNotEmpty)
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                CommonText(
                  '${entry.startDateController.text} - ${entry.endDateController.text}',
                  fontSize: 12,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTagCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonText(title, fontSize: 10, color: AppColors.textSecondary),
          const SizedBox(height: 4),
          CommonText(
            value,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
