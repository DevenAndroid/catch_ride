import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/support_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BraidingSupportTicketsView extends StatefulWidget {
  const BraidingSupportTicketsView({super.key});

  @override
  State<BraidingSupportTicketsView> createState() => _BraidingSupportTicketsViewState();
}

class _BraidingSupportTicketsViewState extends State<BraidingSupportTicketsView> {
  final SupportController _controller = Get.put(SupportController());

  @override
  void initState() {
    super.initState();
    _controller.fetchTickets();
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
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Tickets', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoadingTickets.value && _controller.tickets.isEmpty) return const Center(child: CircularProgressIndicator());
        if (_controller.tickets.isEmpty) return const Center(child: CommonText('No tickets found', color: AppColors.textSecondary, fontSize: 16));
        return RefreshIndicator(
          onRefresh: () => _controller.fetchTickets(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: _controller.tickets.length,
            itemBuilder: (context, index) => _buildTicketCard(_controller.tickets[index]),
          ),
        );
      }),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final String category = ticket['category'] ?? 'General';
    final String subject = ticket['subject'] ?? '';
    final String status = (ticket['status'] ?? 'Pending').toString().toLowerCase();
    String formattedDate = 'Recently';
    try {
      if (ticket['createdAt'] != null) {
        final DateTime dt = DateTime.parse(ticket['createdAt'].toString());
        formattedDate = DateFormat('ddth MMM yyyy, hh:mm a').format(dt);
      }
    } catch (e) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: CommonText(category, fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 4),
          CommonText(formattedDate, fontSize: 12, color: AppColors.textSecondary),
          if (subject.isNotEmpty) ...[
            const SizedBox(height: 12),
            CommonText(subject, fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary, maxLines: 4),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor; Color textColor; String label;
    switch (status) {
      case 'solved': case 'resolved': case 'closed': bgColor = const Color(0xFFECFDF3); textColor = const Color(0xFF027A48); label = 'Solved'; break;
      case 'cancelled': case 'cancel': bgColor = const Color(0xFFFEF3F2); textColor = const Color(0xFFB42318); label = 'Cancel'; break;
      default: bgColor = const Color(0xFFFFFAEB); textColor = const Color(0xFFB54708); label = 'Pending'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: textColor.withValues(alpha: 0.1))),
      child: CommonText(label, fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
    );
  }
}
