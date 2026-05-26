import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/barn_manager/barn_manager_booking_controller.dart';
import '../../../models/booking_model.dart';

class PastServicesView extends StatefulWidget {
  const PastServicesView({super.key});

  @override
  State<PastServicesView> createState() => _PastServicesViewState();
}

class _PastServicesViewState extends State<PastServicesView> with SingleTickerProviderStateMixin {
  final BarnManagerBookingController controller = Get.put(BarnManagerBookingController());
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPastServices();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _fetchPastServices() {
    controller.fetchBookings(type: 'sent', time: 'past', status: 'completed');
    controller.fetchBookings(type: 'received', time: 'past', status: 'completed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF344054),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Past services',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF344054),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          indicatorWeight: 2,
          labelColor: Colors.black,
          unselectedLabelColor: const Color(0xFF98A2B3),
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            fontFamily: 'Outfit',
          ),
          tabs: const [
            Tab(text: 'Services'),
            Tab(text: 'Trials'),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<BookingModel> combinedBookings = [
          ...controller.sentBookings,
          ...controller.receivedBookings,
        ];
        
        // Sort by date (descending)
        combinedBookings.sort((a, b) => b.date.compareTo(a.date));

        final services = combinedBookings.where((b) => b.type != 'Trial').toList();
        final trials = combinedBookings.where((b) => b.type == 'Trial').toList();

        return TabBarView(
          controller: _tabController,
          children: [
            _buildBookingList(services),
            _buildBookingList(trials),
          ],
        );
      }),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const CommonText(
              'No records found',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _fetchPastServices(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildPremiumPastCard(bookings[index]);
        },
      ),
    );
  }

  Widget _buildPremiumPastCard(BookingModel booking) {
    final status = (booking.status).toLowerCase();
    bool isCancelled = status == 'cancelled' || status == 'rejected' || status == 'declined';
    
    String displayStatus = isCancelled ? 'Cancelled' : 'Completed';
    Color statusColor = isCancelled ? const Color(0xFFB42318) : const Color(0xFF12B76A);
    Color statusBg = isCancelled ? const Color(0xFFFEF3F2) : const Color(0xFFECFDF3);

    // Dynamic Title Selection
    String mainTitle = booking.trainerName ?? booking.vendorName ?? booking.clientName ?? 'Unknown';
    if (booking.type == 'Trial' && booking.horseName != null) {
      mainTitle = booking.horseName!;
    }

    // Secondary Info
    String subtitle = booking.type;
    if (booking.providerBarnName != null) {
      subtitle = "$subtitle • ${booking.providerBarnName}";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CommonImageView(
                    url: booking.horseImage ?? booking.trainerImage ?? booking.clientImage,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: CommonText(
                      displayStatus,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Content Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CommonText(
                          mainTitle,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF101828),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: CommonText(
                          booking.type,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.location_on_outlined, booking.location ?? 'N/A'),
                  const SizedBox(height: 6),
                  _buildDetailRow(
                    booking.type == 'Trial' ? Icons.pets_outlined : Icons.person_outline, 
                    subtitle
                  ),
                  const SizedBox(height: 6),
                  _buildDetailRow(Icons.calendar_today_outlined, booking.date),
                  
                  if (booking.senderBarnName != null || booking.barnManagerName != null)
                     Padding(
                       padding: const EdgeInsets.only(top: 10),
                       child: Wrap(
                         spacing: 8,
                         runSpacing: 4,
                         children: [
                           if (booking.senderBarnName != null)
                             _buildMiniTag(Icons.house_outlined, booking.senderBarnName!),
                           if (booking.barnManagerName != null)
                             _buildMiniTag(Icons.group_outlined, booking.barnManagerName!),
                         ],
                       ),
                     ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF98A2B3)),
        const SizedBox(width: 8),
        Expanded(
          child: CommonText(
            text,
            fontSize: 13,
            color: const Color(0xFF667085),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: const Color(0xFF98A2B3)),
          const SizedBox(width: 4),
          CommonText(
            text,
            fontSize: 10,
            color: const Color(0xFF667085),
          ),
        ],
      ),
    );
  }
}


