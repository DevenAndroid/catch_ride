enum BookingType { lease, trial, service }

enum BookingStatus { pending, accepted, completed, cancelled }

class BookingModel {
  final String id;
  final BookingType type;
  final String title; // "Full Lease" or "Shoeing"
  final String subtitle; // "Thunderbolt (Warmblood)" or "Elite Farriers LLC"
  final DateTime startDate;
  final DateTime endDate;
  final BookingStatus status;
  final double price;
  final String location;
  final String? notes;
  final String imageUrl;

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
  BookingModel(
    id: '1024',
    type: BookingType.lease,
    title: 'Full Lease Request',
    subtitle: 'Thunderbolt (Warmblood)',
    startDate: DateTime.now().add(const Duration(days: 2)),
    endDate: DateTime.now().add(const Duration(days: 365)),
    status: BookingStatus.pending,
    price: 15000.0,
    location: 'Wellington Stables, FL',
    notes:
        'Looking for a 1-year lease for a junior rider. Will stay at your barn.',
    imageUrl:
        'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?auto=format&fit=crop&q=80&w=200',
  ),
  BookingModel(
    id: '1025',
    type: BookingType.service,
    title: 'Farrier Service',
    subtitle: 'Elite Farriers LLC',
    startDate: DateTime.now().add(const Duration(days: 5)),
    endDate: DateTime.now().add(const Duration(days: 5)),
    status: BookingStatus.accepted,
    price: 250.0,
    location: 'Barn 4, Aisle B',
    notes: 'Full set of shoes for 2 horses.',
    imageUrl:
        'https://images.unsplash.com/photo-1598974357801-cbca100e65d3?auto=format&fit=crop&q=80&w=200',
  ),
  BookingModel(
    id: '1026',
    type: BookingType.trial,
    title: 'Horse Trial',
    subtitle: 'Midnight Star',
    startDate: DateTime.now().subtract(const Duration(days: 2)),
    endDate: DateTime.now().add(const Duration(days: 1)),
    status: BookingStatus.accepted,
    price: 500.0,
    location: 'Show Grounds, Ring 3',
    notes: '3-day trial during the WEF festival.',
    imageUrl:
        'https://images.unsplash.com/photo-1534008897995-27a23e859048?auto=format&fit=crop&q=80&w=200',
  ),
  BookingModel(
    id: '1027',
    type: BookingType.service,
    title: 'Full Body Clipping',
    subtitle: 'Grooming Pro Services',
    startDate: DateTime.now().subtract(const Duration(days: 10)),
    endDate: DateTime.now().subtract(const Duration(days: 10)),
    status: BookingStatus.completed,
    price: 180.0,
    location: 'Home Barn',
    imageUrl:
        'https://images.unsplash.com/photo-1612140669140-5d65f5042398?auto=format&fit=crop&q=80&w=200',
  ),
];
