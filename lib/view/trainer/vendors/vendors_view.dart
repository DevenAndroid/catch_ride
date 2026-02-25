import 'package:catch_ride/constant/app_colors.dart';
import 'package:catch_ride/constant/app_text_sizes.dart';
import 'package:catch_ride/constant/app_constants.dart';
import 'package:catch_ride/widgets/common_text.dart';
import 'package:catch_ride/widgets/common_image_view.dart';
import 'package:flutter/material.dart';

class VendorsView extends StatefulWidget {
  const VendorsView({super.key});

  @override
  State<VendorsView> createState() => _VendorsViewState();
}

class _VendorsViewState extends State<VendorsView> {
  int _selectedFilterIndex = 1; // 'Groomer' selected by default in image
  final List<String> _filters = [
    'All',
    'Groomer',
    'Shipping',
    'Braider',
    'Farrier',
  ];

  final List<Map<String, dynamic>> _vendors = [
    {
      'name': 'Ria Gabrial',
      'services': 'Shipping, Braider',
      'exp': 'Exp: 8 Years',
      'rating': '4.8',
      'image': AppConstants.dummyImageUrl,
    },
    {
      'name': 'Candice David',
      'services': 'Shipping, Braider',
      'exp': 'Exp: 8 Years',
      'rating': '4.8',
      'image': AppConstants.dummyImageUrl,
    },
    {
      'name': 'Jamie Hook',
      'services': 'Shipping, Braider',
      'exp': 'Exp: 8 Years',
      'rating': '4.8',
      'image': AppConstants.dummyImageUrl,
    },
    {
      'name': 'Ria Gabrial',
      'services': 'Shipping, Braider',
      'exp': 'Exp: 8 Years',
      'rating': '4.8',
      'image': AppConstants.dummyImageUrl,
    },
    {
      'name': 'Jamie Hook',
      'services': 'Shipping, Braider',
      'exp': 'Exp: 8 Years',
      'rating': '4.8',
      'image': AppConstants.dummyImageUrl,
    },
    {
      'name': 'Ria Gabrial',
      'services': 'Shipping, Braider',
      'exp': 'Exp: 8 Years',
      'rating': '4.8',
      'image': AppConstants.dummyImageUrl,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const CommonText(
          'Vendors',
          fontSize: AppTextSizes.size22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _vendors.length,
              itemBuilder: (context, index) {
                return _buildVendorCard(_vendors[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by trainers or horses',
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 24,
          ),
          fillColor: const Color(0xFFF9FAFB),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.transparent : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppColors.textPrimary : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: CommonText(
                _filters[index],
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVendorCard(Map<String, dynamic> vendor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CommonImageView(
                  url: vendor['image'],
                  height: 80,
                  width: 80,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF13CA8B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 12),
                    const SizedBox(width: 2),
                    CommonText(
                      vendor['rating'],
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CommonText(
            vendor['name'],
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              CommonText(
                vendor['services'],
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              CommonText(
                vendor['exp'],
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: double.infinity,
              height: 36,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.textPrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const CommonText(
                  'Book Now',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
