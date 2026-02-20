import 'package:flutter/material.dart';

class AvailabilityShippingScreen extends StatelessWidget {
  const AvailabilityShippingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shipping Availability')),
      body: const Center(child: Text('Shipping Availability/Rates go here')),
    );
  }
}
