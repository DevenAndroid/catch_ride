import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/utils/date_util.dart';
import 'package:catch_ride/view/barn_manager/home/barn_manager_search_filter_overlay.dart';
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
import '../../trainer/settings/trainer_profile_view.dart';
import '../../trainer/list/edit_horse_listing_view.dart';

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
    final id = horse?.id ?? widget.horseId;
    if (id == null) return;
    try {
      setState(() => _isLoading = true);
      final ApiService api = Get.put(ApiService());
      final response = await api.getRequest('/horses/$id');
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

  Future<void> _checkIfRequested() async {
    final bookingController = Get.put(BarnManagerBookingController());

    // Fetch latest sent bookings from server to sync with DB
    await bookingController.fetchBookings(type: 'sent');

    final existingBooking = bookingController.sentBookings.firstWhereOrNull(
      (b) => b.horseId == horse?.id && b.status.toLowerCase() == 'pending',
    );

    setState(() {
      _isRequested = existingBooking != null;
    });
  }

  void _initVideo() {
    final String? videoLink = horse!.videoLink;
    if (videoLink == null || videoLink.isEmpty || videoLink == 'N/A') {
      _hasVideo = false;
      return;
    }

    _hasVideo = true;
    final String? youtubeId = YoutubePlayer.convertUrlToId(videoLink);

    if (youtubeId != null) {
      _isYoutube = true;
      _youtubeController = YoutubePlayerController(
        initialVideoId: youtubeId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    } else {
      _isYoutube = false;
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoLink))
            ..initialize().then((_) {
              setState(() {});
            });
    }
  }

  bool get isHorseOwner {
    final profileController = Get.find<ProfileController>();
    final horseTrainerId = horse?.trainerId;
    final profileTrainerId = profileController.trainerId;

    debugPrint('DEBUG: Horse Trainer ID: $horseTrainerId');
    debugPrint('DEBUG: Profile Trainer ID: $profileTrainerId');

    return horseTrainerId != null && horseTrainerId == profileTrainerId;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _youtubeController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isHorseOwner)
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.textPrimary),
                title: const CommonText('Edit Listing', fontSize: 16),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => EditHorseListingView(horse: horse!));
                },
              ),
            if (!isHorseOwner)
              ListTile(
                leading: const Icon(
                  Icons.person_outline,
                  color: AppColors.textPrimary,
                ),
                title: const CommonText('Trainer Details', fontSize: 16),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => TrainerProfileView(trainerId: horse?.trainerId));
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
            : Builder(
                builder: (context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              if (!isHorseOwner) _buildCancelationPolicy(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      if (!isHorseOwner) _buildBottomAction(),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
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
              _buildCircleButton(Icons.more_vert, () => _showMoreOptions()),
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: horse!.listingTypes
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
                          padding: EdgeInsets.only(
                            right:
                                entry.key == horse!.listingTypes.length - 1
                                    ? 0
                                    : 8,
                          ),
                          child: _buildOverlayBadge(
                            entry.value,
                            const Color(0xFFFDE4E1),
                            const Color(0xFFE11D48),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: CommonText(
                      (horse!.location == null || horse!.location!.isEmpty)
                          ? 'N/A'
                          : horse!.location!,
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
          color: Colors.white.withValues(alpha: 0.8),
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
        color: const Color(
          0xFF8B4242,
        ).withValues(alpha: 0.6), // Matched to mockup dark trans-red
        borderRadius: BorderRadius.circular(8),
      ),
      child: CommonText(
        text,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTrainerSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CommonImageView(
            url: horse!.trainerAvatar,
            height: 48,
            width: 48,
            shape: BoxShape.circle,
            isUserImage: true,
          ),

          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Get.to(() => TrainerProfileView(trainerId: horse?.trainerId)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    horse!.trainerName ?? 'N/A',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  CommonText(
                    horse!.location != null && horse!.location!.isNotEmpty
                        ? 'Location - ${horse!.location}'
                        : 'Location - N/A',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (!isHorseOwner)
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
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    CommonText(
                      'Message',
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(width: 8),
          if (!isHorseOwner)
            const Icon(Icons.more_vert, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildDescriptionAndTags() {
    final description =
        (horse!.description == null || horse!.description!.isEmpty)
        ? ''
        : horse!.description!;
    final tags = [
      ...horse!.programTags.map((t) => t.name),
      ...horse!.opportunityTags.map((t) => t.name),
      ...horse!.personalityTags.map((t) => t.name),
    ];

    if (description.isEmpty && tags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CommonText(
              description,
              fontSize: 14,
              color: AppColors.textPrimary.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: tags
                  .map(
                    (tag) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CommonText(
                        tag,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2939),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Details',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              children: [
                _buildPremiumDetailItem(
                  'Horse name',
                  horse!.name.isEmpty ? 'N/A' : horse!.name,
                ),
                _buildPremiumDetailItem(
                  'USEF number',
                  (horse!.usefNumber == null ||
                          horse!.usefNumber.toString().isEmpty)
                      ? 'N/A'
                      : horse!.usefNumber.toString(),
                ),
                _buildPremiumDetailItem(
                  'Age',
                  horse!.age.toString().isEmpty ? 'N/A' : '${horse!.age} Years',
                ),
                _buildPremiumDetailItem(
                  'Height',
                  (horse!.height == null || horse!.height!.isEmpty)
                      ? 'N/A'
                      : horse!.height!,
                ),
                _buildPremiumDetailItem(
                  'Breed',
                  horse!.breed.isEmpty ? 'N/A' : horse!.breed,
                ),
                _buildPremiumDetailItem(
                  'Color',
                  (horse!.color == null || horse!.color!.isEmpty)
                      ? 'N/A'
                      : horse!.color!,
                ),
                _buildPremiumDetailItem(
                  'Discipline',
                  horse!.displayDiscipline.isEmpty
                      ? 'N/A'
                      : horse!.displayDiscipline,
                ),
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
        Container(height: 1, color: AppColors.border.withValues(alpha: 0.3)),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    if (horse!.showAvailability.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Availability',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: horse!.showAvailability.asMap().entries.map((entry) {
                final index = entry.key;
                final show = entry.value;
                return Column(
                  children: [
                    if (index > 0) const SizedBox(height: 16),
                    _buildPremiumAvailabilityItem(
                      'Location ${index + 1}',
                      show.showVenue,
                      DateUtil.formatRange(show.startDate, show.endDate),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumAvailabilityItem(
    String title,
    String location,
    String dates,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(title, fontSize: 13, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            CommonText(
              location.isEmpty ? 'N/A' : location,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            CommonText(
              dates.trim() == '-' || dates.isEmpty ? 'N/A' : dates,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
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
                decoration: const BoxDecoration(
                  color: Color(0xFFF04438),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const CommonText(
                'Cancelation Policy',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB42318),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const CommonText(
            'The reservation is non-refundable and non-transferable.',
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: CommonButton(
        text: _isRequested ? 'Your request is submitted' : 'Request a Trial',
        backgroundColor: _isRequested
            ? Colors.grey
            : const Color(0xFF00083B), // Navy blue
        textColor: Colors.white,
        onPressed: _isRequested ? null : () => _showBookingRequestBottomSheet(),
      ),
    );
  }

  Widget _buildImageSection() {
    final images = horse!.images;
    final int totalItems = images.length + (_hasVideo ? 1 : 0);

    if (totalItems == 0) {
      return const CommonImageView(
        url: null,
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
                                aspectRatio:
                                    _videoPlayerController!.value.aspectRatio,
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

  void _showBookingRequestBottomSheet() {
    DateTime? startDate;
    String selectedType = 'Trial';
    String? selectedLocation;
    final TextEditingController messageController = TextEditingController();
    final BarnManagerBookingController bookingController = Get.put(BarnManagerBookingController());

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
              const CommonText(
                'Request a Trial',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 16),

              // Horse Card
              _buildBookingHorseCard(),
              const SizedBox(height: 20),

              // Single Date
              const CommonText(
                'Date',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              _buildDateSelector(
                startDate != null
                    ? DateFormat('dd MMM yyyy').format(startDate!)
                    : 'Select Date',
                () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setSheetState(() {
                      startDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Location
              const CommonText(
                'Location',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedLocation,
                    isExpanded: true,
                    items: horse!.showAvailability
                        .map((show) => show.showVenue)
                        .where((venue) => venue.isNotEmpty)
                        .toSet() // Unique venues
                        .map((venue) => DropdownMenuItem(
                              value: venue,
                              child: CommonText(
                                venue,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ))
                        .toList(),
                    hint: const CommonText(
                      'Select Location',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    onChanged: (val) {
                      setSheetState(() {
                        selectedLocation = val;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Message
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'Outfit',
                  ),
                  children: [
                    TextSpan(text: 'Message '),
                    TextSpan(
                      text: '(optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Please include your preferred time frame for the trial...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
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
                          child: CommonText(
                            'Cancel',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(
                      () => GestureDetector(
                        onTap: bookingController.isLoading.value
                            ? null
                            : () async {
                                if (startDate == null) {
                                  Get.snackbar(
                                    'Error',
                                    'Please select a date',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                    barBlur: 0,
                                    margin: const EdgeInsets.all(16),
                                  );
                                  return;
                                }

                                if (selectedLocation == null) {
                                  Get.snackbar(
                                    'Error',
                                    'Please select a location',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                    barBlur: 0,
                                    margin: const EdgeInsets.all(16),
                                  );
                                  return;
                                }

                                final success = await bookingController
                                    .createBooking({
                                      'horseId': horse!.id,
                                      'horseName': horse!.name,
                                      'trainerId': horse!.trainerId,
                                      'type': selectedType,
                                      'date': DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(startDate!),
                                      'location': selectedLocation ?? 'N/A',
                                      'notes': messageController.text,
                                      'service': selectedType,
                                      'price': horse!.price ?? 0,
                                      'clientId': Get.find<ProfileController>()
                                          .user
                                          .value
                                          ?.id,
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
                                  _fetchHorseDetails(); // re-fetch to auto update based on requested state
                                }
                              },
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: bookingController.isLoading.value
                                ? AppColors.inputBackground
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: bookingController.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const CommonText(
                                    'Submit',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
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
      ),
    );
  }

  Widget _buildBookingHorseCard() {
    final hasImages = horse != null && horse!.images.isNotEmpty;
    final photoUrl =
        horse?.photo ??
        (hasImages ? horse!.images.first : '');


    // Extract dynamic venue and dates
    String venueText = 'Venue - N/A';
    String dateRangeText = 'N/A';
    if (horse != null && horse!.showAvailability.isNotEmpty) {
      final firstShow = horse!.showAvailability.first;
      if (firstShow.showVenue.isNotEmpty) {
        venueText = firstShow.showVenue;
      }
      if (firstShow.startDate.isNotEmpty && firstShow.endDate.isNotEmpty) {
        dateRangeText = '${firstShow.startDate} - ${firstShow.endDate}';
      } else if (firstShow.startDate.isNotEmpty) {
        dateRangeText = firstShow.startDate;
      } else if (firstShow.endDate.isNotEmpty) {
        dateRangeText = firstShow.endDate;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CommonImageView(
              url: photoUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Outfit',
                    ),
                    children: [
                      TextSpan(text: horse?.name ?? 'Unknown'),
                      TextSpan(
                        text: ' - ${horse?.discipline ?? horse?.breed}',
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                CommonText(
                  venueText,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: CommonText(
                        horse?.location ?? 'N/A',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: CommonText(
                        dateRangeText,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: horse!.listingTypes
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: EdgeInsets.only(
                              right:
                                  entry.key == horse!.listingTypes.length - 1
                                      ? 0
                                      : 8,
                            ),
                            child: _buildOverlayBadge(
                              entry.value,
                              const Color(0xFFFDE4E1),
                              const Color(0xFFE11D48),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            const Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
