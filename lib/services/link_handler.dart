import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:catch_ride/controllers/auth_controller.dart';
import 'package:catch_ride/services/referral_service.dart';
import 'package:catch_ride/view/create_account_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LinkHandler extends GetxService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  Future<LinkHandler> init() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('Error listening to links: $err');
    });

    return this;
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Handling deep link: $uri');

    // Invite path on any host (ngrok dev or production)
    final isInvitePath = uri.path == '/invite' ||
        uri.path.startsWith('/invite/') ||
        uri.host == 'invite' ||
        (uri.scheme == 'catchride' && uri.host == 'invite');

    final referralCode = ReferralService.extractCodeFromUri(uri);
    if (referralCode != null || isInvitePath) {
      if (referralCode != null) {
        ReferralService.to.saveReferralCode(referralCode);
      }
      _navigateToSignupIfNeeded();
      return;
    }

    final screen = uri.queryParameters['screen'];
    final id = uri.queryParameters['id'];

    if (screen != null) {
      switch (screen) {
        case 'register':
        case 'signup':
          _navigateToSignupIfNeeded();
          break;
        case 'application_status':
          debugPrint('Navigating to Application Status');
          break;
        case 'home':
          debugPrint('Navigating to Home');
          break;
        case 'booking':
          debugPrint('Navigating to Booking ID: $id');
          break;
        case 'login':
          debugPrint('Navigating to Login');
          break;
        case 'support':
          debugPrint('Navigating to Support');
          break;
        case 'view_ticket':
        case 'reply_ticket':
          debugPrint('Navigating to Ticket ID: $id');
          break;
        default:
          debugPrint('Unknown screen in deep link: $screen');
      }
    }
  }

  void _navigateToSignupIfNeeded() {
    if (!Get.isRegistered<AuthController>()) return;
    final auth = Get.find<AuthController>();
    if (auth.isLoggedIn.value) return;
    Future.microtask(() => Get.to(() => const CreateAccountView()));
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }
}
