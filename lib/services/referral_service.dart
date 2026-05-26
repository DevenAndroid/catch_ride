import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Persists a pending referrer code from invite links / app links until signup completes.
class ReferralService extends GetxService {
  static const String storageKey = 'pending_referral_code';

  final _box = GetStorage();
  final RxString pendingCode = ''.obs;

  static ReferralService get to {
    if (!Get.isRegistered<ReferralService>()) {
      Get.put(ReferralService());
    }
    return Get.find<ReferralService>();
  }

  Future<ReferralService> init() async {
    pendingCode.value = _readStored();
    return this;
  }

  String? get pendingReferralCode {
    final code = pendingCode.value.trim();
    return code.isEmpty ? null : code;
  }

  /// Normalizes and saves if valid (6–12 char alphanumeric).
  bool saveReferralCode(String? raw) {
    final normalized = normalizeReferralCode(raw);
    if (normalized == null) return false;
    _box.write(storageKey, normalized);
    pendingCode.value = normalized;
    return true;
  }

  void clearReferralCode() {
    _box.remove(storageKey);
    pendingCode.value = '';
  }

  static String? normalizeReferralCode(String? raw) {
    if (raw == null) return null;
    final code = raw.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();
    if (code.isEmpty) return null;
    if (!RegExp(r'^[A-Z0-9]{6,12}$').hasMatch(code)) return null;
    return code;
  }

  /// Extracts referral code from deep link / universal link URIs.
  static String? extractCodeFromUri(Uri uri) {
    final fromQuery = uri.queryParameters['ref'] ??
        uri.queryParameters['referralCode'] ??
        uri.queryParameters['referalCode'];
    final normalizedQuery = normalizeReferralCode(fromQuery);
    if (normalizedQuery != null) return normalizedQuery;

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isNotEmpty) {
      final last = segments.last;
      if (last.toLowerCase() == 'invite' && segments.length >= 2) {
        return normalizeReferralCode(segments[segments.length - 2]);
      }
      if (last.toLowerCase() != 'invite' && last.toLowerCase() != 'open') {
        return normalizeReferralCode(last);
      }
    }
    return null;
  }

  String _readStored() => (_box.read<String>(storageKey) ?? '').trim().toUpperCase();
}
