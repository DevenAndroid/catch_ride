import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
class GoogleApiController extends GetxController{



  final RxList<Map<String, String>> googleSuggestions = <Map<String, String>>[].obs;
  final RxInt refreshInt = 0.obs;


  Future<void> searchGooglePlaces(String query) async {
    if (query.trim().isEmpty) {
      googleSuggestions.clear();
      return;
    }

    try {
      final url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$googleApiKey";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List predictions = data['predictions'] ?? [];
        final List<Map<String, String>> suggestions = predictions.map((p) {
          return {
            'name': p['description']?.toString() ?? '',
            'place_id': p['place_id']?.toString() ?? '',
          };
        }).toList();

        googleSuggestions.assignAll(suggestions);
      }
      refreshInt.value=DateTime.now().millisecondsSinceEpoch;
    } catch (e) {
      debugPrint('Error searching Google Places: $e');
    }
  }

  Future<void> openSMS(String phoneNo) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNo,
      queryParameters: {
        'body': 'Hi, I need help.', // optional
      },
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(
          smsUri,
          mode: LaunchMode.externalApplication, // IMPORTANT
        );
      } else {
        throw 'SMS not supported';
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not open messaging app');
    }
  }
}