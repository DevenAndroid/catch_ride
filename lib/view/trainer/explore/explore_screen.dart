import 'package:flutter/material.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/view/trainer/explore/filter_modal.dart';
import 'package:catch_ride/widgets/horse_card.dart';
import 'package:catch_ride/view/trainer/explore/horse_detail_screen.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';
import 'package:get/get.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _openDateRangePicker() async {
    final range = await AppDatePicker.pickDateRange(
      context,
      initialRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  void _clearDates() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Explore'),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.mutedGold,
            labelColor: AppColors.deepNavy,
            unselectedLabelColor: AppColors.grey600,
            tabs: [
              Tab(text: 'All Horses'),
              Tab(text: 'Hunters'),
              Tab(text: 'Jumpers'),
              Tab(text: 'Equitation'),
              Tab(text: 'Vendors'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Search & Filter Row
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'City, Show Venue, or Zip',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.grey100,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Date Picker Button
                  DateRangeChip(
                    startDate: _startDate,
                    endDate: _endDate,
                    onTap: _openDateRangePicker,
                    onClear: _startDate != null ? _clearDates : null,
                  ),

                  const SizedBox(width: 8),

                  // Filter Button
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => const FilterModal(),
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.filter_list, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Selected Date Range Display (if dates are picked)
            if (_startDate != null && _endDate != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: AppColors.deepNavy.withOpacity(0.04),
                child: Row(
                  children: [
                    const Icon(
                      Icons.date_range,
                      size: 16,
                      color: AppColors.deepNavy,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppDateFormatter.formatRange(_startDate!, _endDate!),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.deepNavy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _clearDates,
                      child: Text(
                        'Clear',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.softRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildHorseList(), // All Horses
                  _buildHorseList(), // Hunters
                  _buildHorseList(), // Jumpers
                  _buildHorseList(), // Equitation
                  _buildVendorList(), // Vendors
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorseList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Dummy data count
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Get.to(() => const HorseDetailScreen());
            },
            child: const HorseCard(
              name: 'Thunderbolt',
              location: 'Wellington, FL',
              price: '\$45,000',
              breed: 'Warmblood',
              height: '16.2hh',
              age: '8 yrs',
              imageUrl:
                  'https://images.unsplash.com/photo-1553284965-0b0eb9e7f724?q=80&w=2574&auto=format&fit=crop',
              isTopRated: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildVendorList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        final titles = [
          'Elite Grooming',
          'Superior Braiding',
          'SafeRide Transport',
          'Ocala Farrier',
        ];
        final services = ['Grooming', 'Braiding', 'Shipping', 'Farrier'];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage('https://via.placeholder.com/150'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titles[index], style: AppTextStyles.titleMedium),
                    Text(
                      services[index],
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.mutedGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.9 (12 reviews)',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        Get.to(() => const VendorPublicProfileScreen()),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('View'),
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      size: 20,
                      color: AppColors.deepNavy,
                    ),
                    onPressed: () =>
                        Get.snackbar('Inbox', 'Opening chat with vendor...'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class VendorPublicProfileScreen extends StatelessWidget {
  const VendorPublicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reusing existing screen
    return const Scaffold(body: Center(child: Text('Vendor Profile')));
  }
}
