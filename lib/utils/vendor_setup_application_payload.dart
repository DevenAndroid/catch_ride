import 'package:catch_ride/controllers/vendor/common_application_controller.dart';

/// Shared maps for POST /vendors/setup-service payloads aligned with [VendorModel] preform keys.
Map<String, dynamic> vendorHomeBaseFromCommon(CommonApplicationController c) {
  return {
    'country': c.countryController.text,
    'state': c.selectedState.value?['name'],
    'city': c.selectedCity.value?['name'],
  };
}

List<Map<String, String>> vendorProfessionalReferencesFromCommon(CommonApplicationController c) {
  return [
    {
      'name': c.ref1FullNameController.text,
      'business': c.ref1BusinessNameController.text,
      'relationship': c.ref1RelationshipController.text,
      'phone': c.ref1PhoneController.text,
    },
    {
      'name': c.ref2FullNameController.text,
      'business': c.ref2BusinessNameController.text,
      'relationship': c.ref2RelationshipController.text,
      'phone': c.ref2PhoneController.text,
    },
  ];
}
