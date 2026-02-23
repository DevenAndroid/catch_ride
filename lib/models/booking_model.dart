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
    title: 'Moonshadow',
    subtitle: 'Trainer : Emily Johnson',
    startDate: DateTime.now().add(const Duration(days: 3)),
    endDate: DateTime.now().add(const Duration(days: 8)),
    status: BookingStatus.accepted,
    price: 450.0,
    location: 'Cypress, CA, United States',
    notes: 'Please arrive by 6am.',
    imageUrl:
        'https://images.unsplash.com/photo-1598974357801-cbca100e65d3?auto=format&fit=crop&q=80&w=200',
  ),

  // Type 2: Horse Trial Incoming (Requested OF you)
  BookingModel(
    id: '1002',
    type: BookingType.horseTrialIncoming,
    title: 'Starfire',
    subtitle: 'Trainer : Mark Lee',
    startDate: DateTime.now().add(const Duration(days: 15)),
    endDate: DateTime.now().add(const Duration(days: 21)),
    status: BookingStatus.accepted,
    price: 0.0, // Trial might be free or fee
    location: 'Tampa, FL, United States',
    notes: 'Junior rider trial for equitation.',
    imageUrl:
        'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?auto=format&fit=crop&q=80&w=200',
  ),

  // Type 3: Weekly Lease Outgoing (You requested other horse)
  BookingModel(
    id: '1003',
    type: BookingType.weeklyLeaseOutgoing,
    title: 'Whirlwind',
    subtitle: 'Trainer : Sarah Brown',
    startDate: DateTime.now().add(const Duration(days: 50)),
    endDate: DateTime.now().add(const Duration(days: 55)),
    status: BookingStatus.accepted,
    price: 3500.0,
    location: 'Dallas, TX, United States',
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
    location: 'Ocala, FL, United States',
    imageUrl:
        'https://images.unsplash.com/photo-1612140669140-5d65f5042398?auto=format&fit=crop&q=80&w=200',
  ),

  // New Requested Bookings
  BookingModel(
    id: '1005',
    type: BookingType.horseTrialIncoming,
    title: 'Stormchaser',
    subtitle: 'Trainer : Alex Rider',
    startDate: DateTime.now().add(const Duration(days: 4)),
    endDate: DateTime.now().add(const Duration(days: 10)),
    status: BookingStatus.requested,
    price: 0.0,
    location: 'Palm Beach, FL, United States',
    imageUrl:
        'https://images.unsplash.com/photo-1598974357801-cbca100e65d3?auto=format&fit=crop&q=80&w=200',
  ),

  BookingModel(
    id: '1006',
    type: BookingType.weeklyLeaseOutgoing,
    title: 'Silver Lining',
    subtitle: 'Trainer : Chloe Davis',
    startDate: DateTime.now().add(const Duration(days: 14)),
    endDate: DateTime.now().add(const Duration(days: 20)),
    status: BookingStatus.requested,
    price: 2500.0,
    location: 'Lexington, KY, United States',
    imageUrl:
        'https://images.unsplash.com/photo-1553284965-0b0eb9e7f724?auto=format&fit=crop&q=80&w=200',
  ),
];
