import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LinkHandler extends GetxService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  Future<LinkHandler> init() async {
    // Check initial link if app was opened via a link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    // Listen for links while the app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('Error listening to links: $err');
    });

    return this;
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Handling deep link: $uri');
    
    // Structure: https://catchrideapp.com/open?screen=...&id=...
    final screen = uri.queryParameters['screen'];
    final id = uri.queryParameters['id'];

    if (screen != null) {
      switch (screen) {
        case 'application_status':
          // Get.to(() => const ApplicationStatusView());
          debugPrint('Navigating to Application Status');
          break;
        case 'home':
          // Get.offAllNamed('/home');
          debugPrint('Navigating to Home');
          break;
        case 'booking':
          // Get.toNamed('/booking_details', arguments: id);
          debugPrint('Navigating to Booking ID: $id');
          break;
        case 'login':
          // Get.offAllNamed('/login');
          debugPrint('Navigating to Login');
          break;
        case 'support':
          // Get.toNamed('/contact_support');
          debugPrint('Navigating to Support');
          break;
        case 'view_ticket':
        case 'reply_ticket':
          // Get.toNamed('/ticket_details', arguments: id);
          debugPrint('Navigating to Ticket ID: $id');
          break;
        default:
          debugPrint('Unknown screen in deep link: $screen');
          // Fallback to home
          // Get.offAllNamed('/home');
      }
    }
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }
}
