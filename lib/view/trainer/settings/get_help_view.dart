import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/support_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GetHelpView extends StatefulWidget {
  const GetHelpView({super.key});

  @override
  State<GetHelpView> createState() => _GetHelpViewState();
}

class _GetHelpViewState extends State<GetHelpView> {
  final SupportController _controller = Get.put(SupportController());
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _categories = [
    'Technical',
    'Billing',
    'General',
    'Feedback',
    'Other'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _subjectController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showCategoryPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CommonText(
                'Select Category',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 10),
              ..._categories.map((cat) => ListTile(
                title: CommonText(cat, fontSize: 16),
                onTap: () => Navigator.pop(context, cat),
              )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _categoryController.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Get Help',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border.withOpacity(0.5), height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  _buildSearchBar(),
                  const SizedBox(height: 32),

                  // Popular Resources
                  Obx(() {
                    if (_controller.isLoadingFaqs.value && _controller.faqs.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          _searchController.text.isEmpty 
                              ? 'Popular help resources' 
                              : 'Search Results',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        if (_controller.faqs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CommonText('No resources found', color: AppColors.textSecondary),
                          )
                        else
                          ..._controller.faqs.map((faq) => _buildResourceTile(
                            faq['question'] ?? 'No Question',
                            faq['answer'] ?? 'No Answer',
                          )),
                      ],
                    );
                  }),
                  // Tickets History Section
                  Obx(() {
                    if (_controller.tickets.isEmpty) return const SizedBox.shrink();
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CommonText(
                          'My Support Tickets',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(height: 12),
                        ..._controller.tickets.map((ticket) => _buildTicketTile(ticket)),
                        const SizedBox(height: 32),
                      ],
                    );
                  }),

                  // Need More Help Form
                  const CommonText(
                    'Need More Help?',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Subject',
                    controller: _subjectController,
                    hint: 'Enter subject of your issue',
                  ),
                  const SizedBox(height: 20),
                  _buildDropdownField(
                    label: 'Category',
                    controller: _categoryController,
                    hint: 'Select a category',
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Describe your issue',
                    controller: _descriptionController,
                    hint: 'Write your message here...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildTicketTile(Map<String, dynamic> ticket) {
    final status = (ticket['status'] ?? 'open').toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(ticket['subject'] ?? 'No Subject', fontWeight: FontWeight.bold, fontSize: 14),
                const SizedBox(height: 4),
                CommonText(ticket['description'] ?? '', fontSize: 12, color: AppColors.textSecondary, maxLines: 1),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CommonText(
              status.toUpperCase(),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open': return Colors.blue;
      case 'in-progress': return Colors.orange;
      case 'resolved': return const Color(0xFF17B26A);
      case 'closed': return Colors.grey;
      default: return Colors.blue;
    }
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (val) => _controller.fetchFaqs(search: val),
      style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'How can we help you?',
        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 16),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _buildResourceTile(String title, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          iconColor: const Color(0xFF3538CD),
          collapsedIconColor: const Color(0xFF3538CD),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF4FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.question_mark_rounded, size: 14, color: Color(0xFF3538CD)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CommonText(
                  title,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 4, bottom: 8),
              child: CommonText(
                answer,
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showCategoryPicker,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CommonText(
                    controller.text.isEmpty ? hint : controller.text,
                    fontSize: 14,
                    color: controller.text.isEmpty 
                        ? AppColors.textSecondary.withOpacity(0.5) 
                        : AppColors.textPrimary,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Obx(() => GestureDetector(
        onTap: _controller.isSubmitting.value 
            ? null 
            : () async {
                final success = await _controller.submitTicket(
                  subject: _subjectController.text,
                  category: _categoryController.text,
                  description: _descriptionController.text,
                );
                if (success) {
                  _subjectController.clear();
                  _categoryController.text = ''; // Reset to hint
                  _descriptionController.clear();
                  // No Get.back() so user can see refreshed history
                }
              },
        child: Opacity(
          opacity: _controller.isSubmitting.value ? 0.7 : 1.0,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF000B48),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: _controller.isSubmitting.value
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const CommonText(
                      'Submit',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
      )),
    );
  }
}

