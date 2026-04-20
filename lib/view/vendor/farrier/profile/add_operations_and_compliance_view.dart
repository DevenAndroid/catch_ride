import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/controllers/profile_controller.dart';
import 'package:catch_ride/models/user_model.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class OperationsAndComplianceView extends StatefulWidget {
  const OperationsAndComplianceView({super.key});

  @override
  State<OperationsAndComplianceView> createState() =>
      _OperationsAndComplianceViewState();
}

class _OperationsAndComplianceViewState
    extends State<OperationsAndComplianceView> {
  final ProfileController _profileController = Get.find<ProfileController>();
  final ImagePicker _picker = ImagePicker();

  bool _acceptingRequests = true;
  final TextEditingController _providerNameController = TextEditingController();
  final TextEditingController _policyNumberController = TextEditingController();
  final TextEditingController _expirationDateController =
      TextEditingController();

  String? _uploadedDocumentUrl;
  bool _isUploading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final user = _profileController.user.value;
    if (user != null && user.compliance != null) {
      final compliance = user.compliance!;
      _acceptingRequests = compliance.acceptingRequests;
      if (compliance.insurance != null) {
        final insurance = compliance.insurance!;
        _providerNameController.text = insurance.providerName ?? '';
        _policyNumberController.text = insurance.policyNumber ?? '';
        if (insurance.expirationDate != null) {
          final date = insurance.expirationDate!;
          _expirationDateController.text =
              "${date.day}/${date.month}/${date.year}";
        }
        _uploadedDocumentUrl = insurance.documentUrl;
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() => _isUploading = true);
        final url = await _profileController.uploadRawFile(image.path,
            type: 'document');
        setState(() {
          _uploadedDocumentUrl = url;
          _isUploading = false;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      setState(() => _isUploading = false);
    }
  }

  Future<void> _save() async {
    try {
      setState(() => _isSaving = true);

      DateTime? expiry;
      if (_expirationDateController.text.isNotEmpty) {
        try {
          expiry = DateFormat('d/M/y').parse(_expirationDateController.text);
        } catch (e) {
          _expirationDateController.text = "";
        }
      }

      final complianceData = {
        'acceptingRequests': _acceptingRequests,
        'insurance': {
          'providerName': _providerNameController.text.trim(),
          'policyNumber': _policyNumberController.text.trim(),
          'expirationDate': expiry?.toIso8601String(),
          'documentUrl': _uploadedDocumentUrl,
        }
      };

      final success = await _profileController.updateProfile({
        'compliance': complianceData,
      });

      if (success) {
        Get.back();
        Get.snackbar(
          'Success',
          'Operation settings updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successPrimary,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error saving compliance: $e');
    } finally {
      setState(() => _isSaving = false);
    }
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
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Operations & Compliance',
          fontSize: AppTextSizes.size20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.borderLight, height: 1.0),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Accepting Requests Toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CommonText(
                              'Accepting new requests',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(height: 4),
                            const CommonText(
                              'Trainers can send service requests when this is enabled.',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _acceptingRequests,
                        onChanged: (val) =>
                            setState(() => _acceptingRequests = val),
                        activeColor: AppColors.successPrimary,
                        activeTrackColor:
                            AppColors.successPrimary.withOpacity(0.1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Insurance Form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonText(
                        'Insurance',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      const CommonText(
                        'Keep your insurance information up to date to remain active and continue receiving requests.',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 24),

                      // Upload Document
                      const CommonText(
                        'Upload current Insurance Document',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _isUploading ? null : _pickDocument,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.borderLight, width: 1.5),
                          ),
                          child: _isUploading
                              ? const Center(child: CircularProgressIndicator())
                              : _uploadedDocumentUrl != null
                                  ? Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: CommonImageView(
                                            url: _uploadedDocumentUrl,
                                            height: 120,
                                            width: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const CommonText(
                                          'Change Document',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.linkBlue,
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF9FAFB),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: AppColors.borderLight),
                                          ),
                                          child: const Icon(
                                              Icons.cloud_upload_outlined,
                                              color: AppColors.textSecondary,
                                              size: 28),
                                        ),
                                        const SizedBox(height: 16),
                                        RichText(
                                          text: const TextSpan(
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: 'Outfit'),
                                            children: [
                                              TextSpan(
                                                text: 'Click to upload ',
                                                style: TextStyle(
                                                    color: AppColors.linkBlue,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: 'or drag and drop',
                                                style: TextStyle(
                                                    color: AppColors
                                                        .textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const CommonText(
                                          'PNG, JPG or PDF (max. 800x400px)',
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Fields
                      _buildLabel('Provider name', optional: true),
                      _buildTextField(
                          _providerNameController, 'Enter provider name'),
                      const SizedBox(height: 20),

                      _buildLabel('Policy number', optional: true),
                      _buildTextField(
                          _policyNumberController, 'Enter policy number'),
                      const SizedBox(height: 20),

                      _buildLabel('Expiration date', required: true),
                      _buildTextField(
                        _expirationDateController,
                        'Enter expiration date',
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (date != null) {
                            setState(() {
                              _expirationDateController.text =
                                  "${date.day}/${date.month}/${date.year}";
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120), // Space for bottom buttons
              ],
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const CommonText('Cancel',
                    fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSaving || _isUploading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const CommonText('Save',
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label,
      {bool optional = false, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CommonText(
            label,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          if (optional) ...[
            const SizedBox(width: 4),
            const CommonText(' (optional)',
                fontSize: 13, color: AppColors.textSecondary),
          ],
          if (required) ...[
            const CommonText(' *',
                fontSize: 14,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool readOnly = false, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
