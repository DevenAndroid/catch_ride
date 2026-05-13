import 'package:catch_ride/services/api_service.dart';
import 'package:flutter/foundation.dart';

import 'vendor_service_payload.dart';

/// Writes [profileData] and [applicationData] to `ServiceProfile` / `ServiceApplication`
/// for one entry in [VendorModel.assignedServices] (map must include `_id`; see [vendorServiceDocumentId]).
/// `vendorMongoId` is the [VendorModel] document id; `serviceId` in the path is that entry’s `_id`.
Future<bool> syncVendorServiceDocuments({
  required ApiService api,
  required String vendorMongoId,
  required dynamic assignedServiceRow,
  required Map<String, dynamic> profileData,
  required Map<String, dynamic> applicationData,
}) async {
  final serviceId = vendorServiceDocumentId(assignedServiceRow);
  if (serviceId == null || vendorMongoId.isEmpty) {
    debugPrint(
      '[VendorService sync] Missing vendorServiceId or vendorId; skipping native service sync.',
    );
    return false;
  }

  final profileRes = await api.postRequest(
    '/vendors/$vendorMongoId/services/$serviceId/profile',
    {'profileData': profileData},
  );
  final profileBody = profileRes.body;
  final profileOk = profileRes.statusCode == 200 &&
      profileBody is Map &&
      profileBody['success'] == true;

  if (!profileOk) {
    debugPrint('[VendorService sync] Profile POST failed: $profileBody');
  }

  final appRes = await api.postRequest(
    '/vendors/$vendorMongoId/services/$serviceId/application',
    {'applicationData': applicationData},
  );
  final appBody = appRes.body;
  final appOk = appRes.statusCode == 200 &&
      appBody is Map &&
      appBody['success'] == true;

  if (!appOk) {
    debugPrint('[VendorService sync] Application POST failed: $appBody');
  }

  return profileOk && appOk;
}
