enum BookingType {
  vendorService, // Type 1: Outgoing from Trainer to Vendor
  horseTrialIncoming, // Type 2: Incoming to Trainer (Own Horse)
  horseTrialOutgoing, // Type 3: Outgoing from Trainer (Other Horse)
  weeklyLeaseIncoming, // Variant of Type 2
  weeklyLeaseOutgoing, // Variant of Type 3
}

enum BookingStatus {
  requested, // Pending
  accepted,
  declined,
  cancelled,
  completed,
}

class BookingModel {
  final String id;
  final BookingType type;
  final String title; // "Full Body Clipping" or "Thunderbolt"
  final String subtitle; // "Elite Farriers" or "Trainer Mike"
  final DateTime startDate;
  final DateTime endDate;
  final BookingStatus status;
  final double price;
  final String location;
  final String? notes;
  final String imageUrl;

  // Helper properties
  bool get isIncoming =>
      type == BookingType.horseTrialIncoming ||
      type == BookingType.weeklyLeaseIncoming;

  BookingModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.price,
    required this.location,
    this.notes,
    required this.imageUrl,
  });
}

// Mock Data List
final List<BookingModel> mockBookings = [
  // Type 1: Vendor Service (Requested by You)
  BookingModel(
    id: '1001',
    type: BookingType.vendorService,
    title: 'Braiding Service (3 Horses)',
    subtitle: 'Wellington Braiders',
    startDate: DateTime.now().add(const Duration(days: 3)),
    endDate: DateTime.now().add(const Duration(days: 3)),
    status: BookingStatus.accepted,
    price: 450.0,
    location: 'Wellington Stables, Barn 4',
    notes: 'Please arrive by 6am.',
    imageUrl:
        'https://images.unsplash.com/photo-1598974357801-cbca100e65d3?auto=format&fit=crop&q=80&w=200',
  ),

  // Type 2: Horse Trial Incoming (Requested OF you)
  BookingModel(
    id: '1002',
    type: BookingType.horseTrialIncoming,
    title: 'Thunderbolt',
    subtitle: 'Requested by: Sarah Miller (Trainer)',
    startDate: DateTime.now().add(const Duration(days: 10)),
    endDate: DateTime.now().add(const Duration(days: 13)),
    status: BookingStatus.requested,
    price: 0.0, // Trial might be free or fee
    location: 'Wellington Showgrounds',
    notes: 'Junior rider trial for equitation.',
    imageUrl:
        'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?auto=format&fit=crop&q=80&w=200',
  ),

  // Type 3: Weekly Lease Outgoing (You requested other horse)
  BookingModel(
    id: '1003',
    type: BookingType.weeklyLeaseOutgoing,
    title: 'Midnight Star',
    subtitle: 'Owner: High Point Farm',
    startDate: DateTime.now().add(const Duration(days: 20)),
    endDate: DateTime.now().add(const Duration(days: 27)),
    status: BookingStatus.requested,
    price: 3500.0,
    location: 'Ocala, FL',
    notes: 'Need for Week 4 WEF.',
    imageUrl:
        'https://images.unsplash.com/photo-1534008897995-27a23e859048?auto=format&fit=crop&q=80&w=200',
  ),

  // Past Booking
  BookingModel(
    id: '1004',
    type: BookingType.vendorService,
    title: 'Transport to Ocala',
    subtitle: 'Equine Express',
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    endDate: DateTime.now().subtract(const Duration(days: 30)),
    status: BookingStatus.completed,
    price: 800.0,
    location: 'Wellington -> Ocala',
    imageUrl:
        'https://images.unsplash.com/photo-1612140669140-5d65f5042398?auto=format&fit=crop&q=80&w=200',
  ),
];
