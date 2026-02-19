
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';

class FilterModal extends StatelessWidget {
  const FilterModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: AppTextStyles.headlineMedium),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Reset', style: TextStyle(color: AppColors.softRed)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Text('Location', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          _buildFilterChip('Nearby', true),
          
          const SizedBox(height: 24),
          Text('Price Range', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          RangeSlider(
            values: const RangeValues(2000, 10000),
            min: 500,
            max: 20000,
            activeColor: AppColors.deepNavy,
            inactiveColor: AppColors.grey300,
            onChanged: (values) {},
          ),
          
          const SizedBox(height: 24),
          Text('Breed', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('Warmblood', true),
              _buildFilterChip('Thoroughbred', false),
              _buildFilterChip('Quarter Horse', false),
            ],
          ),
          
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {},
      selectedColor: AppColors.deepNavy.withOpacity(0.1),
      checkmarkColor: AppColors.deepNavy,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.deepNavy : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
