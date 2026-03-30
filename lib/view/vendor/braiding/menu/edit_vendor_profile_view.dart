import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/common_textfield.dart';

class EditVendorProfileView extends StatefulWidget {
  const EditVendorProfileView({super.key});

  @override
  State<EditVendorProfileView> createState() => _EditVendorProfileViewState();
}

class _EditVendorProfileViewState extends State<EditVendorProfileView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _paymentMethods = ['Venmo', 'Zelle', 'Cash', 'Credit Card', 'ACH/Bank Transfer', 'Other'];
  final List<String> _selectedPayments = ['Venmo', 'Zelle', 'Other'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText('Edit Profile', fontSize: AppTextSizes.size18, fontWeight: FontWeight.bold),
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _tabController.index == 0 
                  ? Column(children: [_buildBasicDetails(), const SizedBox(height: 20), _buildPaymentMethods(), const SizedBox(height: 20), _buildExperienceHighlights(), const SizedBox(height: 40)])
                  : _buildBraidingTab(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.textPrimary,
            indicatorWeight: 3,
            tabs: const [
              Tab(child: CommonText('Details', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold)),
              Tab(child: CommonText('Braiding', fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 1, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildBasicDetails() {
    return _buildCard(
      title: 'Basic Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPhotoSection(),
          const SizedBox(height: 24),
          _buildBannerSection(),
          const SizedBox(height: 24),
          const CommonTextField(label: 'Full Name', hintText: 'Enter your full name', isRequired: true),
          const SizedBox(height: 20),
          _buildFieldLabel('Phone Number'),
          _buildPhoneField(),
          const SizedBox(height: 20),
          const CommonTextField(label: 'Business Name', hintText: 'Enter your business name', suffixLabel: '(optional)'),
          const SizedBox(height: 20),
          const CommonTextField(label: 'About', hintText: 'Write a short bio', maxLines: 4),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonText('Profile Photo', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
        const SizedBox(height: 16),
        Center(
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), shape: BoxShape.circle),
                child: const Icon(Icons.person_outline, size: 50, color: Colors.grey),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.borderLight)),
                  child: const Icon(Icons.edit_outlined, size: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBannerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            CommonText('Banner Image', fontSize: AppTextSizes.size14, color: AppColors.textSecondary),
            Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid), // Should be dashed in pure CSS, using solid for now
          ),
          child: const Center(child: Icon(Icons.add, color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Row(
            children: const [
              CommonText('+1', fontSize: AppTextSizes.size14),
              Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(hintText: 'Enter phone number', border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return _buildCard(
      title: 'Payment Methods',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _paymentMethods.map((method) => _buildPaymentChip(method)).toList(),
          ),
          const SizedBox(height: 20),
          const CommonTextField(label: '', hintText: 'Write here...', maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildPaymentChip(String method) {
    final isSelected = _selectedPayments.contains(method);
    return Container(
      width: (Get.width - 80) / 2, // Precise 2-column layout
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isSelected ? const Color(0xFF000B48) : AppColors.borderLight, width: 1.5),
        boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getPaymentIcon(method),
          const SizedBox(width: 8),
          Expanded(
            child: CommonText(
              method,
              fontSize: AppTextSizes.size14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              maxLines: 1, // Keep it one line to maintain premium feel, but truncate if needed
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPaymentIcon(String method) {
    if (method == 'Venmo') return _buildCircleIcon(Icons.bolt, const Color(0xFF008CFF));
    if (method == 'Zelle') return _buildCircleIcon(Icons.bolt, const Color(0xFF673AB7));
    if (method == 'Cash') return _buildCircleIcon(Icons.account_balance_wallet, const Color(0xFF10B981));
    if (method == 'Credit Card') return _buildCircleIcon(Icons.credit_card, const Color(0xFF001F3F));
    if (method == 'ACH/Bank Transfer') return _buildCircleIcon(Icons.account_balance, const Color(0xFF78350F));
    return _buildCircleIcon(Icons.add, Colors.grey, isCircle: true);
  }

  Widget _buildCircleIcon(IconData icon, Color color, {bool isCircle = false}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isCircle ? color : color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: isCircle ? Colors.white : color, size: 20),
    );
  }

  Widget _buildExperienceHighlights() {
    return _buildCard(
      title: 'Experience Highlights',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonTextField(label: '', hintText: 'Write here...'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: const CommonText('+ Add More', color: AppColors.linkBlue, fontSize: AppTextSizes.size14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBraidingTab() {
    return Column(
      children: [
        _buildHomeBaseLocation(),
        const SizedBox(height: 20),
        _buildExperienceSection(),
        const SizedBox(height: 20),
        _buildDisciplinesSection(),
        const SizedBox(height: 20),
        _buildHorseLevelSection(),
        const SizedBox(height: 20),
        _buildRegionsCoveredSection(),
        const SizedBox(height: 20),
        _buildSocialMediaSection(),
        const SizedBox(height: 20),
        _buildAddPhotosSection(),
        const SizedBox(height: 20),
        _buildBarnSupportSection(),
        const SizedBox(height: 20),
        _buildHorseHandlingSection(),
        const SizedBox(height: 20),
        _buildAdditionalSkillsSection(),
        const SizedBox(height: 20),
        _buildTravelPreferencesSection(),
        const SizedBox(height: 20),
        _buildCancellationPolicySection(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildHomeBaseLocation() {
    return _buildCard(
      title: 'Home Base Location',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          CommonTextField(label: 'City', hintText: 'Select city', suffixIcon: Icon(Icons.keyboard_arrow_down)),
          SizedBox(height: 16),
          CommonTextField(label: 'State/Province', hintText: 'Select state/province', isRequired: true, suffixIcon: Icon(Icons.keyboard_arrow_down)),
          SizedBox(height: 16),
          CommonTextField(label: 'Country', hintText: 'Select Country', isRequired: true, suffixIcon: Icon(Icons.keyboard_arrow_down)),
        ],
      ),
    );
  }

  Widget _buildExperienceSection() {
    return _buildCard(
      title: 'Experience',
      child: const CommonTextField(label: '', hintText: 'Select years of experience', suffixIcon: Icon(Icons.keyboard_arrow_down)),
    );
  }

  Widget _buildDisciplinesSection() {
    return _buildCard(
      title: 'Disciplines',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip('Eventing', false),
              _buildChoiceChip('Hunter/Jumper', false),
              _buildChoiceChip('Dressage', true),
              _buildChoiceChip('Other', true),
            ],
          ),
          const SizedBox(height: 16),
          const CommonTextField(label: '', hintText: 'Write here...', maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildHorseLevelSection() {
    return _buildCard(
      title: 'Typical Level of Horses',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildChoiceChip('AAAA Circuit', false),
          _buildChoiceChip('FEI', false),
          _buildChoiceChip('Grand Prix', false),
          _buildChoiceChip('Young horses', true),
        ],
      ),
    );
  }

  Widget _buildRegionsCoveredSection() {
    return _buildCard(
      title: 'Regions Covered',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Select the regions you work. Community work in availability details will be added later.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          _buildRemovableTag('Northeast (Hamp...'),
          const SizedBox(height: 8),
          _buildRemovableTag('Florida (Wellington • Ocala • Gulf Coast)', showRemove: true),
          const SizedBox(height: 8),
          _buildRemovableTag('Southeast (Thermal • AZ winter circuit)', showRemove: true),
          const SizedBox(height: 8),
          _buildRemovableTag('Southwest (Kilen • Tigard • Wills Park)', showRemove: true),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return _buildCard(
      title: 'Social Media & Website',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          CommonText('Please include at least one profile link or portfolio.', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          SizedBox(height: 16),
          CommonTextField(label: 'Facebook', hintText: 'facebook.com/yourpage'),
          SizedBox(height: 16),
          CommonTextField(label: 'Instagram', hintText: '@yourusername', prefixIcon: Icon(Icons.alternate_email, size: 18)),
        ],
      ),
    );
  }

  Widget _buildAddPhotosSection() {
    return _buildCard(
      title: 'Add Photos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText('Upload photos to showcase your work and details', fontSize: AppTextSizes.size12, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildPhotoUploadBox(imageUrl: 'https://i.pravatar.cc/100?u=horse1'),
              const SizedBox(width: 12),
              _buildPhotoUploadBox(),
              const SizedBox(width: 12),
              _buildPhotoUploadBox(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarnSupportSection() {
    return _buildCard(
      title: 'Show & Barn Support',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildChoiceChip('Show Braiding', false),
          _buildChoiceChip('Monthly Jobs', false),
          _buildChoiceChip('Fill In Daily Braiding Support', true),
          _buildChoiceChip('Weekly Jobs', false),
          _buildChoiceChip('Seasonal Jobs', false),
          _buildChoiceChip('Travel Jobs', false),
        ],
      ),
    );
  }

  Widget _buildHorseHandlingSection() {
    return _buildCard(
      title: 'Horse Handling',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildChoiceChip('Lunging', false),
          _buildChoiceChip('Non Riding exercise only', false),
        ],
      ),
    );
  }

  Widget _buildAdditionalSkillsSection() {
    return _buildCard(
      title: 'Additional Skills',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildChoiceChip('Braiding', false),
          _buildChoiceChip('Clipping', false),
        ],
      ),
    );
  }

  Widget _buildTravelPreferencesSection() {
    return _buildCard(
      title: 'Travel Preferences',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildChoiceChip('Local Only', false),
          _buildChoiceChip('Regional', false),
          _buildChoiceChip('Nationwide', false),
          _buildChoiceChip('International', false),
        ],
      ),
    );
  }

  Widget _buildCancellationPolicySection() {
    return _buildCard(
      title: 'Cancellation policy',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonTextField(label: '', hintText: 'Select Cancellation', suffixIcon: Icon(Icons.keyboard_arrow_down)),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(value: false, onChanged: (v) {}, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
              const CommonText('Custom', fontSize: AppTextSizes.size14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
      ),
      child: CommonText(label, fontSize: AppTextSizes.size12, color: isSelected ? AppColors.primary : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
    );
  }

  Widget _buildRemovableTag(String label, {bool showRemove = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: showRemove ? const Color(0xFFF3F4F6) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(child: CommonText(label, fontSize: AppTextSizes.size14)),
          if (showRemove) const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadBox({String? imageUrl}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        image: imageUrl != null ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
      ),
      child: imageUrl == null ? const Icon(Icons.add, color: AppColors.textSecondary) : null,
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(title, fontSize: AppTextSizes.size16, fontWeight: FontWeight.bold),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false, bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CommonText(label, fontSize: AppTextSizes.size14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          if (isRequired) const CommonText(' *', color: Colors.red, fontSize: AppTextSizes.size14),
          if (isOptional) const CommonText(' (optional)', color: AppColors.textSecondary, fontSize: AppTextSizes.size12),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.borderLight))),
      child: SafeArea(
        child: Row(
          children: [
             Expanded(
               child: CommonButton(
                 text: 'Cancel',
                 backgroundColor: Colors.white,
                 textColor: AppColors.textPrimary,
                 borderColor: AppColors.borderLight,
                 onPressed: () => Get.back(),
               ),
             ),
             const SizedBox(width: 16),
             Expanded(
               child: CommonButton(
                 text: 'Save',
                 onPressed: () => Get.back(),
               ),
             ),
          ],
        ),
      ),
    );
  }
}
