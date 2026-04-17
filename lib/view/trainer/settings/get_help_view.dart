import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/controllers/support_controller.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/view/trainer/settings/support_tickets_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/view/trainer/settings/request_horse_show_view.dart';
import '../../../controllers/google_api_controller.dart';

class GetHelpView extends StatefulWidget {
  const GetHelpView({super.key});

  @override
  State<GetHelpView> createState() => _GetHelpViewState();
}

class _GetHelpViewState extends State<GetHelpView> {
  final SupportController _controller = Get.put(SupportController());
  final ProfileController _profileController = Get.find<ProfileController>();
  final  googleApiController = Get.put(GoogleApiController());
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _categories = [
    'Technical',
    'Billing',
    'General',
    'Feedback',
    'Other',
  ];

  @override
  void dispose() {
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
              ..._categories.map(
                (cat) => ListTile(
                  title: CommonText(cat, fontSize: 16),
                  onTap: () => Navigator.pop(context, cat),
                ),
              ),
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
          'Get Help',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Popular Resources
                  const CommonText(
                    'Frequently asked questions',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (_controller.isLoadingFaqs.value && _controller.faqs.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (_controller.faqs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CommonText(
                          'No FAQs available',
                          fontSize: 14,
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                      );
                    }
                    return Column(
                      children: _controller.faqs.map((faq) => _buildResourceTile(faq)).toList(),
                    );
                  }),

                  const SizedBox(height: 12),

                  // Need any help? card
                  Obx(() {
                    final phoneNo = _profileController.helpPhoneNumber.value;
                    if (phoneNo.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () async {

                          googleApiController.openSMS(phoneNo);


                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.chat_outlined,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CommonText(
                                      'Need any help?',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    const SizedBox(height: 2),
                                    CommonText(
                                      phoneNo,
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  GestureDetector(
                    onTap: () => Get.to(() => const RequestHorseShowView()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/images/logo.svg",
                            height: 30,
                            width: 30,
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText(
                                  'Can\'t find the horse show you want?',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                SizedBox(height: 2),
                                CommonText(
                                  'Please reach out here to have it added.',
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Raise a ticket Form
                  const CommonText(
                    'Raise a ticket',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    label: 'Subject',
                    controller: _subjectController,
                    hint: 'Brief description of your issue',
                  ),
                  const SizedBox(height: 24),
                  _buildDropdownField(
                    label: 'Category',
                    controller: _categoryController,
                    hint: 'Select category',
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    label: 'Describe your issue',
                    controller: _descriptionController,
                    hint:
                        'Describe the issue or question you\'re experiencing...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  // View All Tickets
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const SupportTicketsView());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1EDE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.help_outline_rounded,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: CommonText(
                              'View All Tickets',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
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


  Widget _buildResourceTile(Map<String, dynamic> faq) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.only(bottom: 0),
        iconColor: AppColors.textSecondary,
        collapsedIconColor: AppColors.textSecondary,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF4FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.question_mark_rounded,
                size: 14,
                color: Color(0xFF3538CD),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CommonText(
                faq['question']?.toString() ?? 'FAQ',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 44, right: 16, bottom: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CommonText(
                faq['answer']?.toString() ?? '',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
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
        CommonText(label, fontSize: 14, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 15,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.2,
              ),
            ),
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
        CommonText(label, fontSize: 14, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showCategoryPicker,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CommonText(
                    controller.text.isEmpty ? hint : controller.text,
                    fontSize: 15,
                    color: controller.text.isEmpty
                        ? AppColors.textSecondary.withValues(alpha: 0.5)
                        : AppColors.textPrimary,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(color: Colors.white),
      child: Obx(
        () => GestureDetector(
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
                    _categoryController.text = '';
                    _descriptionController.clear();
                  }
                },
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: _controller.isSubmitting.value
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
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
      ),
    );
  }
}
