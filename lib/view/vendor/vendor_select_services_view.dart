import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:catch_ride/controllers/auth_controller.dart';

class VendorSelectServicesView extends StatefulWidget {
  const VendorSelectServicesView({super.key});

  @override
  State<VendorSelectServicesView> createState() => _VendorSelectServicesViewState();
}

class _VendorSelectServicesViewState extends State<VendorSelectServicesView> {
  final List<Map<String, String>> _services = [
    {
      'name': 'Grooming',
      'image': 'https://images.unsplash.com/photo-1598974357801-cb9267104f2d?q=80&w=2670&auto=format&fit=crop',
    },
    {
      'name': 'Braiding',
      'image': 'https://images.unsplash.com/photo-1596245347206-897db67204ee?q=80&w=2576&auto=format&fit=crop',
    },
    {
      'name': 'Clipping',
      'image': 'https://images.unsplash.com/photo-1628155930542-3c7a64e2c833?q=80&w=2574&auto=format&fit=crop',
    },
    {
      'name': 'Bodywork',
      'image': 'https://images.unsplash.com/photo-1530268576251-d4190c6ca38a?q=80&w=2670&auto=format&fit=crop',
    },
    {
      'name': 'Shipping',
      'image': 'https://images.unsplash.com/photo-1551062029-7ca656f5c888?q=80&w=2670&auto=format&fit=crop',
    },
    {
      'name': 'Farrier',
      'image': 'https://images.unsplash.com/photo-1534067783941-51c9c23eccfd?q=80&w=2574&auto=format&fit=crop',
    },
  ];

  final Set<String> _selectedServices = {};

  void _toggleService(String serviceName) {
    setState(() {
      if (_selectedServices.contains(serviceName)) {
        _selectedServices.remove(serviceName);
      } else {
        if (_selectedServices.length < 2) {
          _selectedServices.add(serviceName);
        } else {
          Get.snackbar(
            'Limit Reached',
            'You can select a maximum of 2 services.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const CommonText(
          'Select your Services',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1D2939),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFEAECF0), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: CommonText(
                'Select maximum 2 services.',
                fontSize: 16,
                color: Color(0xFF667085),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  final isSelected = _selectedServices.contains(service['name']);
                  return _buildServiceCard(service, isSelected);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: CommonButton(
                text: 'Continue',
                onPressed: _selectedServices.isEmpty
                    ? null
                    : () {
                        // In a real app, we'd send these services to the backend here.
                        Get.find<AuthController>().navigateAfterRoleSet();
                      },
                backgroundColor: const Color(0xFF00083D),
                borderRadius: 12,
                height: 56,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, String> service, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleService(service['name']!),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00083D) : const Color(0xFFEAECF0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF00083D).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: CachedNetworkImage(
                      imageUrl: service['image']!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFFF2F4F7),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFF2F4F7),
                        child: const Icon(Icons.error_outline, color: Color(0xFFD0D5DD)),
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00083D),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 14, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEDF2FE) : Colors.white,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                ),
                alignment: Alignment.center,
                child: CommonText(
                  service['name']!,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2939),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
