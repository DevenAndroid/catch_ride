import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AddNewListingController extends GetxController {
  // Step 1
  final videoLinkController = TextEditingController();
  var uploadedImages = <String>[].obs;

  // Step 2
  final listingTitleController = TextEditingController();
  final horseNameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final breedController = TextEditingController();
  final colorController = TextEditingController();
  final disciplineController = TextEditingController();
  final descriptionController = TextEditingController();
  final usefNumberController = TextEditingController();

  // Step 3
  var selectedListingTypes = <String>{'Sale', 'Annual Lease'}.obs;

  // Step 4
  var selectedProgramTags = <String>{
    'High Performance Jumper (1.20m +)',
    'Young Developing Hunter',
  }.obs;
  var selectedOpportunityTags = <String>{
    'Investment Type',
    'Owner Flexible',
  }.obs;
  var selectedExperienceTags = <String>{
    'Short/Long Stirrup',
    'Young Developing Hunter',
  }.obs;
  var selectedPersonalityTags = <String>{'Sensitive Ride', 'Forward Ride'}.obs;

  final List<String> programTags = [
    'Big Equitation',
    'High Performance Hunter (3\'6" +)',
    'High Performance Jumper (1.20m +)',
    'Young Developing Hunter',
    'Young Developing Jumper',
    'Schoolmaster',
    'Prospect',
    'Division Pony',
  ];

  final List<String> opportunityTags = [
    'Open to outside miles',
    'Firesale',
    'Investment Type',
    'Owner Flexible',
    'Open to Paid Trials',
    'Backburner',
  ];

  final List<String> experienceTags = [
    'Division Pony',
    'Beginner Friendly',
    'Short/Long Stirrup',
    'Young Developing Hunter',
    'Crossrails',
    '2\'6"',
    '3\'0-3\'3"',
    '3\'6"',
    '3\'6"+',
    '1.0m',
    '1.10m',
    '1.20m',
    '1.30m',
    '1.40m',
    '1.50m',
    'FEI',
  ];

  final List<String> personalityTags = [
    'Jr/Amateur Friendly',
    'Brave / Bold',
    'Sensitive Ride',
    'Forward Ride',
    'Auto Lead Change',
    'Careful',
    'Push Ride',
    'Pro Ride',
  ];

  // Step 5
  var activeStatus = true.obs;
  var availabilityEntries = <AvailabilityEntry>[
    AvailabilityEntry(id: 1),
    AvailabilityEntry(id: 2),
  ].obs;

  void addEntry() {
    int nextId = availabilityEntries.isEmpty
        ? 1
        : availabilityEntries.last.id + 1;
    availabilityEntries.add(AvailabilityEntry(id: nextId));
  }

  void removeEntry(int index) {
    if (availabilityEntries.length > index) {
      availabilityEntries[index].dispose();
      availabilityEntries.removeAt(index);
    }
  }

  void toggleListingType(String type) {
    if (selectedListingTypes.contains(type)) {
      selectedListingTypes.remove(type);
    } else {
      selectedListingTypes.add(type);
    }
    selectedListingTypes.refresh();
  }

  void toggleTag(RxSet<String> selectedTags, String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
    selectedTags.refresh();
  }

  @override
  void onClose() {
    videoLinkController.dispose();
    listingTitleController.dispose();
    horseNameController.dispose();
    ageController.dispose();
    heightController.dispose();
    breedController.dispose();
    colorController.dispose();
    disciplineController.dispose();
    descriptionController.dispose();
    usefNumberController.dispose();
    for (var entry in availabilityEntries) {
      entry.dispose();
    }
    super.onClose();
  }
}

class AvailabilityEntry {
  final int id;
  final cityStateController = TextEditingController();
  final showVenueController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  AvailabilityEntry({required this.id});

  void dispose() {
    cityStateController.dispose();
    showVenueController.dispose();
    startDateController.dispose();
    endDateController.dispose();
  }
}
