import 'dart:io';

import 'package:catch_ride/constant/app_urls.dart';
import 'package:flutter/foundation.dart';

/// Builds invite URLs for sharing and deferred install attribution.
class ReferralLinkHelper {
  static String get inviteWebBase => AppUrls.inviteWebUrl;

  static const String androidPackageId = 'com.app.catchride';

  /// Custom scheme — not auto-linked in SMS/WhatsApp; used only by the web landing page redirect.
  static String buildInviteAppSchemeUrl(String referralCode) {
    final code = referralCode.trim().toUpperCase();
    return 'catchride://invite?ref=${Uri.encodeQueryComponent(code)}';
  }

  /// HTTPS invite link — clickable in messages, email, etc.
  static String buildInviteWebUrl(String referralCode) {
    final code = referralCode.trim().toUpperCase();
    return '$inviteWebBase?ref=${Uri.encodeQueryComponent(code)}';
  }

  /// Always use HTTPS so the link is tappable in chat apps.
  static String buildPrimaryInviteLink(String referralCode) {
    return buildInviteWebUrl(referralCode);
  }

  /// Play Store URL with Install Referrer for Android deferred attribution.
  static String buildPlayStoreUrl(String referralCode, {String? basePlayStoreUrl}) {
    final code = referralCode.trim().toUpperCase();
    final referrer = Uri.encodeComponent('ref=$code');
    final base = basePlayStoreUrl?.trim().isNotEmpty == true
        ? basePlayStoreUrl!.trim()
        : 'https://play.google.com/store/apps/details?id=$androidPackageId';
    final uri = Uri.parse(base);
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      'referrer': referrer,
    }).toString();
  }

  static String buildShareMessage({
    required String referralCode,
    String? playStoreUrl,
    String? appStoreUrl,
  }) {
    final code = referralCode.trim().toUpperCase();
    final inviteLink = buildInviteWebUrl(code);

    final buffer = StringBuffer()
      ..writeln('Join me on Catch Ride — the premier network for equestrian professionals.')
      ..writeln()
      ..writeln(inviteLink)
      ..writeln()
      ..writeln('Invite code: $code');

    if (!kIsWeb) {
      if (Platform.isAndroid) {
        buffer
          ..writeln()
          ..writeln('Get the app: ${buildPlayStoreUrl(code, basePlayStoreUrl: playStoreUrl)}');
      } else if (Platform.isIOS && appStoreUrl != null && appStoreUrl.trim().isNotEmpty) {
        buffer
          ..writeln()
          ..writeln('Get the app: ${appStoreUrl.trim()}');
      }
    }

    return buffer.toString().trim();
  }
}
