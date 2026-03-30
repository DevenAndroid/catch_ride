import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';

class BookingView extends StatefulWidget {
  const BookingView({super.key});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  int _selectedTab = 0; // 0 for Upcoming, 1 for Past Clients

  final List<Map<String, dynamic>> _bookings = [
    {
      'trainer': 'Emma Caldwell',
      'location': 'Tampa, FL, USA',
      'dates': '01 Apr - 07 Apr 2026',
      'service': 'Braiding',
      'note': 'Looking for a reliable braiding!',
      'avatar': 'https://i.pravatar.cc/150?u=1'
    },
    {
      'trainer': 'Mark Lee',
      'location': 'Tampa, FL, USA',
      'dates': '01 Apr - 07 Apr 2026',
      'service': 'Braiding',
      'note': 'Looking for a reliable braider!',
      'avatar': 'https://i.pravatar.cc/150?u=2'
    },
    {
      'trainer': 'Mark Lee',
      'location': 'Tampa, FL, USA',
      'dates': '01 Apr - 07 Apr 2026',
      'service': 'Braiding',
      'note': 'Looking for a reliable braiding!',
      'avatar': 'https://i.pravatar.cc/150?u=2'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const CommonText(
          'Bookings',
          fontSize: AppTextSizes.size24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  _buildTab('Upcoming', 0),
                  _buildTab('Past Clients', 1),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _bookings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                return _buildBookingCard(booking);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          alignment: Alignment.center,
          child: CommonText(
            label,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: AppTextSizes.size14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 34,
                backgroundImage: NetworkImage(booking['avatar']),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      'Trainer : ${booking['trainer']}',
                      fontSize: AppTextSizes.size16,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        CommonText(booking['location'], fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        CommonText(booking['dates'], fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: CommonText(
                  booking['service'],
                  fontSize: AppTextSizes.size12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CommonText(
            'NOTE : ${booking['note']}',
            fontSize: AppTextSizes.size14,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.secondary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.chat_bubble_outline, color: AppColors.secondary, size: 20),
                  SizedBox(width: 8),
                  CommonText(
                    'Message',
                    color: AppColors.secondary,
                    fontSize: AppTextSizes.size16,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
