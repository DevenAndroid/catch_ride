import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';
import 'package:catch_ride/widgets/custom_button.dart';

// Mock Horse Data for Trainer
final List<Map<String, dynamic>> trainerHorses = [
  {
    'name': 'Midnight Star',
    'location': 'Wellington, FL',
    'price': '\$65,000',
    'breed': 'Warmblood',
    'height': '17.1hh',
    'age': '9 yrs',
    'imageUrl':
        'https://images.unsplash.com/photo-1534008897995-27a23e859048?auto=format&fit=crop&q=80&w=200',
    'availability': 'Mar 1 - Mar 15',
  },
  {
    'name': 'Royal Knight',
    'location': 'Ocala, FL',
    'price': '\$45,000',
    'breed': 'Thoroughbred',
    'height': '16.2hh',
    'age': '7 yrs',
    'imageUrl':
        'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?auto=format&fit=crop&q=80&w=200',
    'availability': 'Available Now',
  },
];

class BarnManagerHorseListScreen extends StatelessWidget {
  const BarnManagerHorseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Availability'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trainerHorses.length,
        itemBuilder: (context, index) {
          final horse = trainerHorses[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Miniature Horse Card Look
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(horse['imageUrl']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(horse['name'], style: AppTextStyles.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            '${horse['breed']} • ${horse['age']}',
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.grey100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.date_range,
                                  size: 14,
                                  color: AppColors.deepNavy,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  horse['availability'],
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              _EditAvailabilityPage(horseName: horse['name']),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                    label: const Text('Update Availability'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.deepNavy),
                      foregroundColor: AppColors.deepNavy,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Full-page Edit Availability screen with real date pickers
class _EditAvailabilityPage extends StatefulWidget {
  final String horseName;

  const _EditAvailabilityPage({required this.horseName});

  @override
  State<_EditAvailabilityPage> createState() => _EditAvailabilityPageState();
}

class _EditAvailabilityPageState extends State<_EditAvailabilityPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _markUnavailable = false;
  final _locationController = TextEditingController();

  Future<void> _pickStartDate() async {
    final dt = await AppDatePicker.pickDateTime(
      context,
      initialDate: _startDate,
    );
    if (dt != null) {
      setState(() => _startDate = dt);
    }
  }

  Future<void> _pickEndDate() async {
    final dt = await AppDatePicker.pickDateTime(
      context,
      initialDate: _endDate ?? _startDate,
    );
    if (dt != null) {
      setState(() => _endDate = dt);
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Availability — ${widget.horseName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Set Availability', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Select date range and location for ${widget.horseName}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 24),

            // Start Date
            Text('Start Date & Time', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickStartDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: AppColors.deepNavy,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _startDate != null
                          ? AppDateFormatter.format(_startDate!)
                          : 'Select start date & time',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: _startDate != null
                            ? AppColors.deepNavy
                            : AppColors.grey400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // End Date
            Text('End Date & Time', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickEndDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: AppColors.deepNavy,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _endDate != null
                          ? AppDateFormatter.format(_endDate!)
                          : 'Select end date & time',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: _endDate != null
                            ? AppColors.deepNavy
                            : AppColors.grey400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Location Field
            Text('Show Venue / Location', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'e.g. Ocala World Equestrian Center',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mark Unavailable Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mark as Unavailable',
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Horse won\'t appear in search',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _markUnavailable,
                    onChanged: (val) {
                      setState(() => _markUnavailable = val);
                    },
                    activeColor: AppColors.deepNavy,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            CustomButton(
              text: 'Save Changes',
              onPressed: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Success',
                  'Availability updated for ${widget.horseName}',
                  backgroundColor: AppColors.successGreen,
                  colorText: Colors.white,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
