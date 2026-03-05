import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';

import 'package:catch_ride/models/horse_model.dart';
import '../../../controllers/profile_controller.dart';

class TrainerHorseDetailView extends StatefulWidget {
  final HorseModel? horse;
  final bool fromBooking;
  final bool isOwnHorse;

  const TrainerHorseDetailView({
    super.key,
    this.horse,
    this.fromBooking = false,
    this.isOwnHorse = false,
  });

  @override
  State<TrainerHorseDetailView> createState() => _TrainerHorseDetailViewState();
}

class _TrainerHorseDetailViewState extends State<TrainerHorseDetailView> {
  bool _isRequested = false;
  HorseModel? horse;
  
  // Image carousel state
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
    horse = widget.horse;
    if (horse != null) {
      _initVideo();
    }
  }

  void _initVideo() {
    final String? videoLink = horse!.videoLink;
    if (videoLink == null || videoLink.isEmpty) return;

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
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoLink))
        ..initialize().then((_) {
          setState(() {});
        });
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
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          AppStrings.horseDetail,
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
        child: horse == null
            ? const Center(child: CircularProgressIndicator())
            : Builder(builder: (context) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.fromBooking) _buildBookedByHeader(),
                            if (!widget.fromBooking) _buildHeader(),
                            _buildImageSection(),
                            _buildHeaderInfoSection(),
                            _buildUsefNumberBanner(),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CommonText(
                                    AppStrings.details,
                                    fontSize: AppTextSizes.size16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                          const SizedBox(height: 12),
                          _buildDetailsSection(),
                          const SizedBox(height: 24),

                          const CommonText(
                            AppStrings.availability,
                            fontSize: AppTextSizes.size16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(height: 12),
                          _buildAvailabilitySection(),
                          const SizedBox(height: 16),

                          _buildTagsGridSection(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Button
            Obx(() {
              final String currentUserId = Get.find<ProfileController>().user.value?.id ?? '';
              final String trainerProfileId = Get.find<ProfileController>().user.value?.trainerProfileId ?? '';
              final String horseTrainerId = horse!.trainerId ?? '';
              
              // Hide the booking request/message button if viewing own horse
              final bool isMyHorse = widget.isOwnHorse || 
                  (currentUserId.isNotEmpty && currentUserId == horseTrainerId) ||
                  (trainerProfileId.isNotEmpty && trainerProfileId == horseTrainerId);

              if (isMyHorse) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: widget.fromBooking
                    ? CommonButton(
                        text: 'Open Messages',
                        backgroundColor: Colors.white,
                        textColor: AppColors.primary,
                        onPressed: () {
                          // Open messages functionality
                        },
                      )
                    : CommonButton(
                        text: _isRequested
                            ? 'Requested'
                            : AppStrings.sendBookingRequest,
                        backgroundColor: _isRequested
                            ? AppColors.inputBackground
                            : AppColors.primary,
                        textColor: _isRequested
                            ? AppColors.textSecondary
                            : Colors.white,
                        onPressed: () {
                          if (!_isRequested) {
                            _showBookingRequestBottomSheet();
                          }
                        },
                      ),
              );
            }),
          ],
        );
      }),
    ),
  );
  }

  Widget _buildBookedByHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(
                0xFFFFF7F5,
              ), // Light reddish background from design
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE4E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CommonText(
                  'Booked by',
                  fontSize: AppTextSizes.size12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonImageView(
                      url: horse!.bookedByAvatar ?? AppConstants.dummyImageUrl,
                      height: 50,
                      width: 50,
                      shape: BoxShape.circle,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            horse!.bookedByName ?? 'Mark Lee',
                            fontSize: AppTextSizes.size16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.textSecondary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: CommonText(
                                  horse!.bookedByLocation ?? 'Cypress, CA, United States',
                                  fontSize: AppTextSizes.size12,
                                  color: AppColors.textSecondary,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.textSecondary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              CommonText(
                                horse!.bookingDates ?? '01 Apr - 07 Apr 2026',
                                fontSize: AppTextSizes.size12,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const CommonText(
                        'For Sale',
                        fontSize: AppTextSizes.size12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const CommonImageView(
                url: AppConstants.dummyImageUrl,
                height: 44,
                width: 44,
                shape: BoxShape.circle,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      horse!.trainerName ?? 'Unknown Trainer',
                      fontSize: AppTextSizes.size16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    const CommonText(
                      AppStrings.professionalHorseTrainer,
                      fontSize: AppTextSizes.size14,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: AppColors.textPrimary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CommonImageView(
            url: horse!.trainerAvatar ?? AppConstants.dummyImageUrl,
            height: 44,
            width: 44,
            shape: BoxShape.circle,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  horse!.trainerName ?? 'Unknown Trainer',
                  fontSize: AppTextSizes.size14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                const CommonText(
                  AppStrings.professionalHorseTrainer,
                  fontSize: AppTextSizes.size12,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    final images = horse!.images;
    final int totalItems = images.length + (_hasVideo ? 1 : 0);

    if (totalItems == 0) {
      return const CommonImageView(
        url: AppConstants.dummyImageUrl,
        height: 240,
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
                  url: images[index],
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

  Widget _buildHeaderInfoSection() {
    final tags = horse!.listingTypes;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tabBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CommonText(
                            tag,
                            fontSize: AppTextSizes.size12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const Icon(
                Icons.share_outlined,
                color: AppColors.textPrimary,
                size: 22,
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.bookmark_outline,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          CommonText(
            horse!.listingTitle ?? horse!.name,
            fontSize: AppTextSizes.size18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
          const SizedBox(height: 8),
          CommonText(
            horse!.description ?? 'No description provided.',
            fontSize: AppTextSizes.size14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          const SizedBox(height: 12),
          if (horse!.location != null && horse!.location!.isNotEmpty && horse!.location != 'N/A')
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 4),
              CommonText(
                horse!.location!,
                fontSize: AppTextSizes.size12,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsefNumberBanner() {
    final usef = horse!.usefNumber;
    if (usef == null || usef.toString().isEmpty || usef == 'N/A') {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      color: const Color(0xFFF3F4F6), // Light gray background
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CommonText(
            AppStrings.horseUsefNumber,
            fontSize: AppTextSizes.size14,
            color: AppColors.textSecondary,
          ),
          CommonText(
            usef.toString(),
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }


  Widget _buildDetailsSection() {
    final List<Map<String, String>> detailItems = [
      if (horse!.name.isNotEmpty)
        {'label': 'Horse name', 'value': horse!.name},
      if (horse!.age > 0)
        {'label': 'Age', 'value': '${horse!.age} Years'},
      if (horse!.height != null && horse!.height!.isNotEmpty)
        {'label': 'Height', 'value': horse!.height!},
      if (horse!.breed.isNotEmpty)
        {'label': 'Breed', 'value': horse!.breed},
      if (horse!.color != null && horse!.color!.isNotEmpty)
        {'label': 'Color', 'value': horse!.color!},
      if (horse!.discipline != null && horse!.discipline!.isNotEmpty)
        {'label': 'Discipline', 'value': horse!.discipline!},
    ];

    if (detailItems.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: CommonText(
            label,
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,
          ),
        ),
        const CommonText(
          ': ',
          fontSize: AppTextSizes.size12,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        Expanded(
          child: CommonText(
            value,
            fontSize: AppTextSizes.size12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    final availability = horse!.showAvailability
        .where((a) => a.cityState.isNotEmpty || a.showVenue.isNotEmpty)
        .toList();
        
    if (availability.isEmpty) {
      return const CommonText('No availability records found.', color: AppColors.textSecondary);
    }
    return Column(
      children: availability.map((a) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildLocationCard(
            'Location',
            '${a.showVenue}, ${a.cityState}'.trim(),
            '${a.startDate} - ${a.endDate}',
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationCard(String label, String address, String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            label,
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.textSecondary,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: CommonText(
                  address,
                  fontSize: AppTextSizes.size12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.textSecondary,
                size: 14,
              ),
              const SizedBox(width: 6),
              CommonText(
                date,
                fontSize: AppTextSizes.size12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagsGridSection() {
    final programs = horse!.programTags;
    final opportunities = horse!.opportunityTags;
    final experience = horse!.experienceLevel;
    final personalities = horse!.personalityTags;

    final bool hasPrograms = programs.isNotEmpty;
    final bool hasOpportunities = opportunities.isNotEmpty;
    final bool hasExperience = experience != null;
    final bool hasPersonalities = personalities.isNotEmpty;

    if (!hasPrograms && !hasOpportunities && !hasExperience && !hasPersonalities) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (hasPrograms || hasOpportunities)
          Row(
            children: [
              if (hasPrograms)
                Expanded(child: _buildTagCard('Program Tag', programs.first.name))
              else if (hasOpportunities)
                const Spacer(),
              
              if (hasPrograms && hasOpportunities) const SizedBox(width: 12),
              
              if (hasOpportunities)
                Expanded(child: _buildTagCard('Opportunity Tag', opportunities.first.name))
              else if (hasPrograms)
                const Spacer(),
            ],
          ),
        if ((hasPrograms || hasOpportunities) && (hasExperience || hasPersonalities))
          const SizedBox(height: 12),
        if (hasExperience || hasPersonalities)
          Row(
            children: [
              if (hasExperience)
                Expanded(child: _buildTagCard('Experience', experience.name))
              else if (hasPersonalities)
                const Spacer(),

              if (hasExperience && hasPersonalities) const SizedBox(width: 12),

              if (hasPersonalities)
                Expanded(child: _buildTagCard('Personality Tag', personalities.first.name))
              else if (hasExperience)
                const Spacer(),
            ],
          ),
      ],
    );
  }

  Widget _buildTagCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            label,
            fontSize: AppTextSizes.size12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          CommonText(
            value,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }


  void _showBookingRequestBottomSheet() {
    String selectedType = 'Trial';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Horse Card
              _buildBookingHorseCard(),
              const SizedBox(height: 20),

              // Type Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTypeToggleItem('Trial', selectedType == 'Trial', () {
                        setSheetState(() => selectedType = 'Trial');
                      }),
                    ),
                    Expanded(
                      child: _buildTypeToggleItem('Weekly Lease', selectedType == 'Weekly Lease', () {
                        setSheetState(() => selectedType = 'Weekly Lease');
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CommonText('Start Date', fontSize: 13, fontWeight: FontWeight.bold),
                        const SizedBox(height: 8),
                        _buildDateSelector('Select Date'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CommonText('End Date', fontSize: 13, fontWeight: FontWeight.bold),
                        const SizedBox(height: 8),
                        _buildDateSelector('Select Date'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Location
              const CommonText('Location', fontSize: 13, fontWeight: FontWeight.bold),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText('WEF, Wellington', fontSize: 14, color: AppColors.textPrimary),
                    Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Message
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'Outfit'),
                  children: [
                    TextSpan(text: 'Message '),
                    TextSpan(text: '(optional)', style: TextStyle(fontWeight: FontWeight.normal, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 100,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Write here...',
                    hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: CommonText('Cancel', fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        setState(() => _isRequested = true);
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: CommonText('Submit', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingHorseCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: const CommonImageView(
              url: AppConstants.dummyImageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'Outfit'),
                        children: [
                          TextSpan(text: 'Whirlwind'),
                          TextSpan(text: ' • Jumper', style: TextStyle(fontWeight: FontWeight.normal, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const CommonText('Lease', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const CommonText('Venue – Bruce\'s Field', fontSize: 12, color: AppColors.textSecondary),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                    SizedBox(width: 6),
                    CommonText('10 Jan - 18 Jan 2026', fontSize: 11, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 2),
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                    SizedBox(width: 6),
                    CommonText('Winterfell, USA, United States', fontSize: 11, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggleItem(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
        ),
        child: Center(
          child: CommonText(
            title,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CommonText(hint, fontSize: 14, color: AppColors.textSecondary.withValues(alpha: 0.6)),
          const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
