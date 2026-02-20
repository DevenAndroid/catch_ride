// vendor_booking_models.dart
// Shared booking models, enums, and mock data for all vendor booking screens

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Service Config — single source of truth for service metadata
// ─────────────────────────────────────────────────────────────────────────────

enum VendorServiceType {
  groom,
  clipping,
  braiding,
  bodywork,
  farrier,
  shipping,
}

class VendorServiceConfig {
  final VendorServiceType type;
  final String label;
  final String verbLabel; // e.g. "Grooming", "Clipping"
  final IconData icon;
  final String rateUnit; // e.g. "per day", "per horse", "per trip"
  final List<String> serviceOptions; // dropdown options for request form

  const VendorServiceConfig({
    required this.type,
    required this.label,
    required this.verbLabel,
    required this.icon,
    required this.rateUnit,
    required this.serviceOptions,
  });

  static const groom = VendorServiceConfig(
    type: VendorServiceType.groom,
    label: 'Groom',
    verbLabel: 'Grooming',
    icon: Icons.cleaning_services_rounded,
    rateUnit: 'per day',
    serviceOptions: [
      'Full Day',
      'Half Day',
      'Show Prep Only',
      'Braiding + Groom',
    ],
  );

  static const clipping = VendorServiceConfig(
    type: VendorServiceType.clipping,
    label: 'Clipper',
    verbLabel: 'Clipping',
    icon: Icons.content_cut_rounded,
    rateUnit: 'per horse',
    serviceOptions: [
      'Full Body Clip',
      'Trace Clip',
      'Hunter Clip',
      'Face & Bridle Path',
    ],
  );

  static const braiding = VendorServiceConfig(
    type: VendorServiceType.braiding,
    label: 'Braider',
    verbLabel: 'Braiding',
    icon: Icons.auto_awesome_rounded,
    rateUnit: 'per horse',
    serviceOptions: [
      'Running Braids',
      'Button Braids',
      'French Braids',
      'Tail Wrap',
    ],
  );

  static const bodywork = VendorServiceConfig(
    type: VendorServiceType.bodywork,
    label: 'Bodyworker',
    verbLabel: 'Bodywork',
    icon: Icons.spa_rounded,
    rateUnit: 'per session',
    serviceOptions: [
      'Massage',
      'Chiropractic',
      'Acupuncture',
      'Stretching Session',
    ],
  );

  static const farrier = VendorServiceConfig(
    type: VendorServiceType.farrier,
    label: 'Farrier',
    verbLabel: 'Farrier Services',
    icon: Icons.handyman_rounded,
    rateUnit: 'per horse',
    serviceOptions: [
      'Full Reset',
      'Trim Only',
      'Front Shoes Only',
      'Corrective Shoeing',
    ],
  );

  static const shipping = VendorServiceConfig(
    type: VendorServiceType.shipping,
    label: 'Shipper',
    verbLabel: 'Horse Shipping',
    icon: Icons.local_shipping_rounded,
    rateUnit: 'per trip',
    serviceOptions: [
      'One Way',
      'Round Trip',
      'Show Circuit',
      'Emergency Transport',
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Booking Status
// ─────────────────────────────────────────────────────────────────────────────

enum BookingStatus { pending, confirmed, completed, declined, cancelled }

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'New Request';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.declined:
        return 'Declined';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return const Color(0xFFC9A84C); // mutedGold
      case BookingStatus.confirmed:
        return const Color(0xFF4CAF50); // successGreen
      case BookingStatus.completed:
        return const Color(0xFF1A2B4B); // deepNavy
      case BookingStatus.declined:
        return const Color(0xFFE53935); // softRed
      case BookingStatus.cancelled:
        return const Color(0xFF9E9E9E); // grey
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  VendorBooking Model
// ─────────────────────────────────────────────────────────────────────────────

class VendorBooking {
  final String id;
  final String clientName;
  final String clientRole; // 'Trainer' | 'Barn Manager'
  final String horseName;
  final int horseCount;
  final String serviceDetail; // e.g. "Full Body Clip"
  final DateTime date;
  final String? endDate; // for multi-day (shipping/groom)
  final String location;
  final String showName;
  final String rate;
  final BookingStatus status;
  final String? notes;
  final VendorServiceType serviceType;

  const VendorBooking({
    required this.id,
    required this.clientName,
    required this.clientRole,
    required this.horseName,
    required this.horseCount,
    required this.serviceDetail,
    required this.date,
    this.endDate,
    required this.location,
    required this.showName,
    required this.rate,
    required this.status,
    this.notes,
    required this.serviceType,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Mock data (replace with API)
// ─────────────────────────────────────────────────────────────────────────────

final mockVendorBookings = [
  VendorBooking(
    id: 'VB001',
    clientName: 'Sarah Williams',
    clientRole: 'Trainer',
    horseName: 'Midnight Star',
    horseCount: 2,
    serviceDetail: 'Full Day',
    date: DateTime(2026, 3, 5, 8, 0),
    location: 'Wellington Equestrian Center',
    showName: 'WEF Week 8',
    rate: '\$200',
    status: BookingStatus.pending,
    notes: 'Please arrive by 7:30 AM. Access through Gate 3.',
    serviceType: VendorServiceType.groom,
  ),
  VendorBooking(
    id: 'VB002',
    clientName: 'Emily Johnson',
    clientRole: 'Barn Manager',
    horseName: 'Royal Knight',
    horseCount: 3,
    serviceDetail: 'Running Braids',
    date: DateTime(2026, 3, 7, 5, 30),
    location: 'WEF Grounds – Barn 14',
    showName: 'WEF Week 8',
    rate: '\$65',
    status: BookingStatus.pending,
    serviceType: VendorServiceType.braiding,
  ),
  VendorBooking(
    id: 'VB003',
    clientName: 'Michael Davis',
    clientRole: 'Trainer',
    horseName: 'Thunder',
    horseCount: 1,
    serviceDetail: 'Full Body Clip',
    date: DateTime(2026, 3, 2, 10, 0),
    location: 'Palm Beach Stables',
    showName: 'Pre-show prep',
    rate: '\$150',
    status: BookingStatus.confirmed,
    serviceType: VendorServiceType.clipping,
  ),
  VendorBooking(
    id: 'VB004',
    clientName: 'Lisa Chen',
    clientRole: 'Trainer',
    horseName: 'Goldie',
    horseCount: 1,
    serviceDetail: 'Massage',
    date: DateTime(2026, 2, 28, 7, 0),
    location: 'Global Dressage Festival',
    showName: 'GDF 2026',
    rate: '\$180',
    status: BookingStatus.completed,
    serviceType: VendorServiceType.bodywork,
  ),
  VendorBooking(
    id: 'VB005',
    clientName: 'Rachel Brooks',
    clientRole: 'Barn Manager',
    horseName: 'Storm',
    horseCount: 2,
    serviceDetail: 'Full Reset',
    date: DateTime(2026, 3, 10, 9, 0),
    location: 'Ocala Horse Properties',
    showName: 'HITS Ocala',
    rate: '\$120',
    status: BookingStatus.confirmed,
    serviceType: VendorServiceType.farrier,
  ),
  VendorBooking(
    id: 'VB006',
    clientName: 'Tom Nelson',
    clientRole: 'Trainer',
    horseName: 'Blaze',
    horseCount: 4,
    serviceDetail: 'Round Trip',
    date: DateTime(2026, 3, 12, 6, 0),
    endDate: 'Mar 15',
    location: 'Wellington → Ocala',
    showName: 'HITS Circuit',
    rate: '\$1,200',
    status: BookingStatus.pending,
    notes: 'Hay and buckets for 4 horses needed en route.',
    serviceType: VendorServiceType.shipping,
  ),
];
