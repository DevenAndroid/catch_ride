import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:catch_ride/utils/app_colors.dart';
import 'package:catch_ride/utils/app_text_styles.dart';
import 'package:catch_ride/utils/date_picker_helper.dart';
import 'package:catch_ride/widgets/custom_button.dart';
import 'package:catch_ride/widgets/custom_text_field.dart';
import 'package:catch_ride/view/trainer/explore/horse_detail_screen.dart';

// Mock Horse Data for Trainer
final List<Map<String, dynamic>> trainerHorses = [
  {
    'name': 'Midnight Star',
    'location': 'Wellington International',
    'price': '65000',
    'listingType': 'Sale',
    'breed': 'Warmblood',
    'height': '17.1hh',
    'age': '9',
    'imageUrl':
        'https://images.unsplash.com/photo-1534008897995-27a23e859048?auto=format&fit=crop&q=80&w=400',
    'availability': '01 Mar 2026 - 15 Mar 2026',
    'status': 'Available',
  },
  {
    'name': 'Royal Knight',
    'location': 'Ocala World Equestrian Center',
    'price': '45000',
    'listingType': 'Lease',
    'breed': 'Thoroughbred',
    'height': '16.2hh',
    'age': '7',
    'imageUrl':
        'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?auto=format&fit=crop&q=80&w=400',
    'availability': '05 Feb 2026 - 10 Feb 2026',
    'status': 'In Trial',
  },
];

class BarnManagerHorseListScreen extends StatelessWidget {
  const BarnManagerHorseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer\'s Horses'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildInfoBanner(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trainerHorses.length,
              itemBuilder: (context, index) {
                final horse = trainerHorses[index];
                return _buildHorseCard(context, horse);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      color: AppColors.grey50,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.grey600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You are viewing horses associated with your Trainer. You can update details and availability.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorseCard(BuildContext context, Map<String, dynamic> horse) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => HorseDetailScreen(
            name: horse['name'],
            location: horse['location'],
            price: horse['price'],
            listingType: horse['listingType'],
            breed: horse['breed'],
            height: horse['height'],
            age: horse['age'],
            imageUrl: horse['imageUrl'],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Media Section (Point 5 requirement)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  Image.network(
                    horse['imageUrl'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildStatusBadge(horse['status']),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.photo_library,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '1/4 Photos',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(horse['name'], style: AppTextStyles.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoTag(
                    Icons.location_on_outlined,
                    'Next Show Venue: ${horse['location']}',
                  ),
                  const SizedBox(height: 4),
                  _buildInfoTag(
                    Icons.calendar_month_outlined,
                    'Date Window: ${horse['availability']}',
                  ),

                  const Divider(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(
                              () => _EditAvailabilityPage(
                                horseName: horse['name'],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepNavy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Update Show'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'Available'
        ? AppColors.successGreen
        : AppColors.mutedGold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey500),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey700),
        ),
      ],
    );
  }
}

class EditHorseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> horse;
  const EditHorseDetailsScreen({super.key, required this.horse});

  @override
  State<EditHorseDetailsScreen> createState() => _EditHorseDetailsScreenState();
}

class _EditHorseDetailsScreenState extends State<EditHorseDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.horse['name']);
    _ageController = TextEditingController(text: widget.horse['age']);
    _priceController = TextEditingController(text: widget.horse['price']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Horse Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Media', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildMediaThumbnail(widget.horse['imageUrl']),
                  _buildAddMediaButton(),
                ],
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(label: 'Horse Name', controller: _nameController),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Age',
              controller: _ageController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Price (\$)',
              controller: _priceController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: 'Save Details',
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Success',
                  'Horse details updated',
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

  Widget _buildMediaThumbnail(String url) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildAddMediaButton() {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300, style: BorderStyle.solid),
      ),
      child: const Icon(Icons.add_a_photo_outlined, color: AppColors.grey500),
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
    if (dt != null) setState(() => _startDate = dt);
  }

  Future<void> _pickEndDate() async {
    final dt = await AppDatePicker.pickDateTime(
      context,
      initialDate: _endDate ?? _startDate,
    );
    if (dt != null) setState(() => _endDate = dt);
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
            Text('Set Show Location', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 24),
            Text('Next Show Venue', style: AppTextStyles.labelLarge),
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
            Text('Date Window', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _dateButton('Start', _startDate, _pickStartDate),
                ),
                const SizedBox(width: 12),
                Expanded(child: _dateButton('End', _endDate, _pickEndDate)),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Mark as Unavailable'),
              subtitle: const Text('Horse won\'t appear in search'),
              value: _markUnavailable,
              onChanged: (v) => setState(() => _markUnavailable = v),
              activeColor: AppColors.deepNavy,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'Save Availability',
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Success',
                  'Availability updated',
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

  Widget _dateButton(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.bodySmall),
            const SizedBox(height: 4),
            Text(
              date != null ? AppDateFormatter.format(date) : 'Select',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
