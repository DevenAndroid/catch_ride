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
import 'package:intl/intl.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/barn_manager/barn_manager_booking_controller.dart';
import '../../../services/api_service.dart';

class BarnManagerHorseDetailView extends StatefulWidget {
  final HorseModel? horse;
  final String? horseId;
  final bool fromBooking;
  final bool isOwnHorse;

  const BarnManagerHorseDetailView({
    super.key,
    this.horse,
    this.horseId,
    this.fromBooking = false,
    this.isOwnHorse = false,
  });

  @override
  State<BarnManagerHorseDetailView> createState() => _BarnManagerHorseDetailViewState();
}

class _BarnManagerHorseDetailViewState extends State<BarnManagerHorseDetailView> {
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.horse != null) {
      horse = widget.horse;
      _initVideo();
      _checkIfRequested();
    } else if (widget.horseId != null) {
      _fetchHorseDetails();
    }
  }

  Future<void> _fetchHorseDetails() async {
    try {
      setState(() => _isLoading = true);
      final ApiService api = Get.find<ApiService>();
      final response = await api.getRequest('/horses/${widget.horseId}');
      if (response.statusCode == 200) {
        final data = response.body['data'];
        if (data != null) {
          setState(() {
            horse = HorseModel.fromJson(data);
            _initVideo();
            _checkIfRequested();
          });
        }
      } else {
        Get.snackbar('Error', 'Failed to load horse details');
      }
    } catch (e) {
      debugPrint('Error fetching horse: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _checkIfRequested() {
    final bookingController = Get.find<BarnManagerBookingController>();
    final currentUserId = Get.find<ProfileController>().id;
    
    final existingBooking = bookingController.bookings.firstWhereOrNull(
      (b) => b.horseId == horse?.id && 
             b.status.toLowerCase() == 'pending'
    );
    
    if (existingBooking != null) {
      setState(() => _isRequested = true);
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (horse == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Details')),
        body: const Center(child: Text('Horse details not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0), // Hide default app bar
        child: AppBar(elevation: 0, backgroundColor: Colors.white),
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
                            _buildPremiumHeader(),
                            _buildTrainerSection(),
                            _buildDescriptionAndTags(),
                            _buildDetailsSection(),
                            _buildAvailabilitySection(),
                            _buildCancelationPolicy(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomAction(),
                  ],
                );
              }),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    final tags = horse!.listingTypes;
    return Stack(
      children: [
        _buildImageSection(),
        // Header Controls
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCircleButton(Icons.arrow_back_ios_new, () => Get.back()),
              _buildCircleButton(Icons.more_vert, () {}),
            ],
          ),
        ),
        // Title & Badges Overlay
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                '${horse!.name} - ${horse!.displayDiscipline}',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (horse!.listingTypes.isNotEmpty)
                    _buildOverlayBadge(horse!.listingTypes.first, const Color(0xFFFDE4E1), const Color(0xFFE11D48)),
                  const SizedBox(width: 8),
                  _buildOverlayBadge('Weekly Lease', const Color(0xFFFDE4E1), const Color(0xFFE11D48)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: CommonText(
                      horse!.location ?? '931 Powderhouse Rd SE, Aiken, SC 29803, USA',
                      fontSize: 12,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.black),
      ),
    );
  }

  Widget _buildOverlayBadge(String text, Color bg, Color textC) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF8B4242).withOpacity(0.6), // Matched to mockup dark trans-red
        borderRadius: BorderRadius.circular(8),
      ),
      child: CommonText(text, fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildTrainerSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CommonImageView(
            url: horse!.trainerAvatar ?? AppConstants.dummyImageUrl,
            height: 48,
            width: 48,
            shape: BoxShape.circle,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(horse!.trainerName ?? 'John Snow', fontSize: 16, fontWeight: FontWeight.bold),
                CommonText('Barn - Winter Equestrian', fontSize: 13, color: AppColors.textSecondary),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 40,
              width: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF8B4242),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 16, color: Colors.white),
                  SizedBox(width: 8),
                  CommonText('Message', color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.more_vert, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildDescriptionAndTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: CommonText(
            horse!.description ?? 'An ideal small pony and great for a Child An ideal small pony and great for a Child...',
            fontSize: 14,
            color: AppColors.textPrimary.withOpacity(0.7),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              'Big Equitation', 'Firesale', 'Division Pony', 'Brave / Bold'
            ].map((tag) => Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CommonText(tag, fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1D2939)),
            )).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
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
                color: Colors.black.withOpacity(0.6),
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

  // Methods removed in favor of premium builder

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Details', fontSize: 18, fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              children: [
                _buildPremiumDetailItem('Horse name', horse!.name),
                _buildPremiumDetailItem('USEF number', horse!.usefNumber ?? '5w3bnd67'),
                _buildPremiumDetailItem('Age', '${horse!.age} Years'),
                _buildPremiumDetailItem('Height', horse!.height ?? '16.2hh'),
                _buildPremiumDetailItem('Breed', horse!.breed),
                _buildPremiumDetailItem('Color', horse!.color ?? 'Brown'),
                _buildPremiumDetailItem('Discipline', horse!.displayDiscipline),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 13, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        CommonText(value, fontSize: 15, fontWeight: FontWeight.bold),
        const SizedBox(height: 4),
        Container(height: 1, color: AppColors.border.withOpacity(0.3)),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Availability', fontSize: 18, fontWeight: FontWeight.bold),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPremiumAvailabilityItem('Location 1', 'Ocklawaha, USA, United States', '05 Feb - 10 Feb 2026'),
                const SizedBox(height: 16),
                _buildPremiumAvailabilityItem('Location 2', 'Ocklawaha, USA, United States', '05 Feb - 10 Feb 2026'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumAvailabilityItem(String title, String location, String dates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(title, fontSize: 13, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            CommonText(location, fontSize: 14, fontWeight: FontWeight.w500),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            CommonText(dates, fontSize: 14, fontWeight: FontWeight.bold),
          ],
        ),
      ],
    );
  }

  Widget _buildCancelationPolicy() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE4E1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFFF04438), shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const CommonText('Cancelation Policy', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFB42318)),
            ],
          ),
          const SizedBox(height: 12),
          const CommonText(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,',
            fontSize: 13,
            color: Color(0xFFB42318),
            height: 1.5,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: CommonButton(
        text: 'Request a Trial',
        backgroundColor: const Color(0xFF00083B), // Navy blue
        textColor: Colors.white,
        onPressed: () => _showBookingRequestBottomSheet(),
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
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
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
    DateTime? startDate;
    DateTime? endDate;
    String selectedType = 'Trial';
    final TextEditingController messageController = TextEditingController();
    final BarnManagerBookingController bookingController = Get.find<BarnManagerBookingController>();

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
                    color: AppColors.border.withOpacity(0.6),
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
                        _buildDateSelector(
                          startDate != null ? DateFormat('dd MMM yyyy').format(startDate!) : 'Select Date',
                          () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setSheetState(() => startDate = date);
                            }
                          },
                        ),
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
                        _buildDateSelector(
                          endDate != null ? DateFormat('dd MMM yyyy').format(endDate!) : 'Select Date',
                          () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? startDate ?? DateTime.now(),
                              firstDate: startDate ?? DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setSheetState(() => endDate = date);
                            }
                          },
                        ),
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
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Write here...',
                    hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 14),
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
                    child: Obx(() => GestureDetector(
                      onTap: bookingController.isLoading.value ? null : () async {
                        if (startDate == null || endDate == null) {
                          Get.snackbar(
                            'Error', 
                            'Please select both start and end dates',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                            barBlur: 0,
                            margin: const EdgeInsets.all(16),
                          );
                          return;
                        }

                        final success = await bookingController.createBooking({
                          'horseId': horse!.id,
                          'horseName': horse!.name,
                          'trainerId': horse!.trainerId,
                          'type': selectedType,
                          'date': DateFormat('yyyy-MM-dd').format(startDate!),
                          'endDate': DateFormat('yyyy-MM-dd').format(endDate!),
                          'location': 'WEF, Wellington',
                          'notes': messageController.text,
                          'service': selectedType,
                          'price': horse!.price ?? 0,
                          'clientId': Get.find<ProfileController>().user.value?.id,
                        });

                        if (success) {
                          Get.back(); // Close bottom sheet
                          Get.snackbar(
                            'Success', 
                            'Booking request sent successfully',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF17B26A),
                            colorText: Colors.white,
                            barBlur: 0,
                            margin: const EdgeInsets.all(16),
                          );
                          setState(() => _isRequested = true);
                        }
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: bookingController.isLoading.value ? AppColors.inputBackground : AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: bookingController.isLoading.value 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const CommonText('Submit', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    )),
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
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
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
          boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
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

  Widget _buildDateSelector(String hint, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(hint, fontSize: 14, color: AppColors.textPrimary),
            const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
