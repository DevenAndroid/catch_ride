import 'package:catch_ride/constant/app_strings.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';

import 'package:flutter/material.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_button.dart';

class TrainerHorseDetailView extends StatefulWidget {
  final bool fromBooking;

  const TrainerHorseDetailView({super.key, this.fromBooking = false});

  @override
  State<TrainerHorseDetailView> createState() => _TrainerHorseDetailViewState();
}

class _TrainerHorseDetailViewState extends State<TrainerHorseDetailView> {
  bool _isRequested = false;

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
          onPressed: () => Navigator.pop(context),
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
        child: Column(
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
                          // if (!widget.fromBooking) ...[
                          //   _buildTalkToBarnManagerSection(),
                          //   const SizedBox(height: 24),
                          // ],

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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Button
            Padding(
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
                          _showSelectAvailabilityBottomSheet();
                        }
                      },
                    ),
            ),
          ],
        ),
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
                    const CommonImageView(
                      url: AppConstants.dummyImageUrl,
                      height: 50,
                      width: 50,
                      shape: BoxShape.circle,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CommonText(
                            'Mark Lee',
                            fontSize: AppTextSizes.size16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(
                                Icons.location_on_outlined,
                                color: AppColors.textSecondary,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: CommonText(
                                  'Cypress, CA, United States',
                                  fontSize: AppTextSizes.size12,
                                  color: AppColors.textSecondary,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.textSecondary,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              CommonText(
                                '01 Apr - 07 Apr 2026',
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
                  children: const [
                    CommonText(
                      'John Snow',
                      fontSize: AppTextSizes.size16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    CommonText(
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
              children: const [
                CommonText(
                  AppStrings.aryaStark,
                  fontSize: AppTextSizes.size14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                CommonText(
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
    return Stack(
      children: [
        const CommonImageView(
          url: AppConstants.dummyImageUrl,
          height: 240,
          width: double.infinity,
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const CommonText(
              AppStrings.num112,
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
                  children: ['For sale', 'Weekly Lease']
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
          const CommonText(
            AppStrings.demoHorseYoungDevelopingHunter,
            fontSize: AppTextSizes.size18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
          const SizedBox(height: 8),
          const CommonText(
            AppStrings
                .anIdealSmallPonyAndGreatForAChildAnIdealSmallPonyAndGreatForAChildanIdealSmallPonyAndGreatForAChildAnIdealSmallPonyAndGreatForAChild,
            fontSize: AppTextSizes.size14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.textSecondary,
                size: 16,
              ),
              SizedBox(width: 4),
              CommonText(
                AppStrings.ocklawahaUsaUnitedStates,
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
    return Container(
      width: double.infinity,
      color: const Color(0xFFF3F4F6), // Light gray background
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          CommonText(
            AppStrings.horseUsefNumber,
            fontSize: AppTextSizes.size14,
            color: AppColors.textSecondary,
          ),
          CommonText(
            AppStrings.num5w3bnd67,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildTalkToBarnManagerSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F9), // Light blue-ish gray
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            AppStrings.talkToBarnManger,
            fontSize: AppTextSizes.size12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CommonImageView(
                  url: AppConstants.dummyImageUrl,
                  height: 50,
                  width: 50,
                  shape: BoxShape.circle,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonText(
                        AppStrings.lisaJames,
                        fontSize: AppTextSizes.size14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(
                            Icons.location_on_outlined,
                            color: AppColors.textSecondary,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: CommonText(
                              AppStrings.ocklawahaUsaUnitedStates,
                              fontSize: AppTextSizes.size12,
                              color: AppColors.textSecondary,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          if (!_isRequested) {
                            _showSelectAvailabilityBottomSheet();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _isRequested
                                ? AppColors.inputBackground
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CommonText(
                            _isRequested
                                ? 'Requested'
                                : AppStrings.requestBooking,
                            color: _isRequested
                                ? AppColors.textSecondary
                                : Colors.white,
                            fontSize: AppTextSizes.size12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildDetailRow('Horse name', 'Thunderbolt'),
          const SizedBox(height: 16),
          _buildDetailRow('Age', '14 Years'),
          const SizedBox(height: 16),
          _buildDetailRow('Height', '16.2hh'),
          const SizedBox(height: 16),
          _buildDetailRow('Breed', 'Thoroughbred'),
          const SizedBox(height: 16),
          _buildDetailRow('Color', 'Brown'),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Discipline',
            '\$100',
          ), // Screenshot says Discipline : $100
        ],
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
    return Column(
      children: [
        _buildLocationCard(
          'Location 1',
          'Ocklawaha, USA, United States',
          '05 Feb - 10 Feb 2026',
        ),
        const SizedBox(height: 12),
        _buildLocationCard(
          'Location 2',
          'Ocklawaha, USA, United States',
          '05 Feb - 10 Feb 2026',
        ),
      ],
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTagCard('Program Tag', 'Big Equitation')),
            const SizedBox(width: 12),
            Expanded(child: _buildTagCard('Opportunity Tag', 'Firesale')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTagCard('Experience', 'Division Pony')),
            const SizedBox(width: 12),
            Expanded(child: _buildTagCard('Personality Tag', 'Brave / Bold')),
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
          const SizedBox(height: 4),
          CommonText(
            value,
            fontSize: AppTextSizes.size12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  void _showSelectAvailabilityBottomSheet() {
    int selectedAvailabilityIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CommonText(
                    'Select Availability',
                    fontSize: AppTextSizes.size18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 20),
                  _buildAvailabilityOption(
                    index: 0,
                    selectedIndex: selectedAvailabilityIndex,
                    label: 'Location 1',
                    address: 'Ocklawaha, USA, United States',
                    date: '05 Feb - 10 Feb 2026',
                    onTap: () {
                      setSheetState(() {
                        selectedAvailabilityIndex = 0;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildAvailabilityOption(
                    index: 1,
                    selectedIndex: selectedAvailabilityIndex,
                    label: 'Location 2',
                    address: 'Ocklawaha, USA, United States',
                    date: '05 Feb - 10 Feb 2026',
                    onTap: () {
                      setSheetState(() {
                        selectedAvailabilityIndex = 1;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  CommonButton(
                    text: 'Next',
                    onPressed: () {
                      Navigator.pop(context);
                      _showSelectBookingTypeBottomSheet();
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvailabilityOption({
    required int index,
    required int selectedIndex,
    required String label,
    required String address,
    required String date,
    required VoidCallback onTap,
  }) {
    bool isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
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
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.border,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectBookingTypeBottomSheet() {
    int selectedTypeIndex = 0;
    List<String> types = [
      'Sale',
      'Annual Lease',
      'Short Term or Circuit Lease',
      'Weekly Lease',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CommonText(
                    'Select Booking Type',
                    fontSize: AppTextSizes.size18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(types.length, (index) {
                    bool isSelected = index == selectedTypeIndex;
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() {
                          selectedTypeIndex = index;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CommonText(
                              types[index],
                              fontSize: AppTextSizes.size14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: AppColors.textPrimary,
                            ),
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showSelectAvailabilityBottomSheet();
                          },
                          child: Container(
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const CommonText(
                              'Previous',
                              fontSize: AppTextSizes.size16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CommonButton(
                          text: 'Send Request',
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _isRequested = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
