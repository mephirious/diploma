class OwnerFacility {
  final String id;
  final String name;
  final String location;
  final String sport;
  final String status;
  final int completionPercent;
  final double occupancy;
  final String imageUrl;

  const OwnerFacility({
    required this.id,
    required this.name,
    required this.location,
    required this.sport,
    required this.status,
    required this.completionPercent,
    required this.occupancy,
    required this.imageUrl,
  });
}

class OwnerBookingItem {
  final String id;
  final String facilityName;
  final String customerName;
  final String date;
  final String slot;
  final int attendees;
  final String status;

  const OwnerBookingItem({
    required this.id,
    required this.facilityName,
    required this.customerName,
    required this.date,
    required this.slot,
    required this.attendees,
    required this.status,
  });
}

class OwnerPayoutItem {
  final String title;
  final String date;
  final String amount;
  final String status;

  const OwnerPayoutItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
  });
}

class OwnerMockData {
  static const List<OwnerFacility> facilities = [
    OwnerFacility(
      id: 'of-1',
      name: 'Arena Pro Football',
      location: 'Almaty, Abay Ave 48',
      sport: 'Football',
      status: 'active',
      completionPercent: 100,
      occupancy: 0.87,
      imageUrl:
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=900',
    ),
    OwnerFacility(
      id: 'of-2',
      name: 'Skyline Court Center',
      location: 'Almaty, Dostyk Ave 132',
      sport: 'Basketball',
      status: 'draft',
      completionPercent: 72,
      occupancy: 0.52,
      imageUrl:
          'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=900',
    ),
    OwnerFacility(
      id: 'of-3',
      name: 'Aqua Sprint Pool',
      location: 'Almaty, Rozybakiev 247',
      sport: 'Swimming',
      status: 'suspended',
      completionPercent: 100,
      occupancy: 0.36,
      imageUrl:
          'https://images.unsplash.com/photo-1519315901367-f34ff9154487?w=900',
    ),
  ];

  static const List<OwnerBookingItem> incomingBookings = [
    OwnerBookingItem(
      id: 'ib-1',
      facilityName: 'Arena Pro Football',
      customerName: 'Sanzhar Team',
      date: 'Today',
      slot: '18:00 - 20:00',
      attendees: 10,
      status: 'pending',
    ),
    OwnerBookingItem(
      id: 'ib-2',
      facilityName: 'Skyline Court Center',
      customerName: 'Aigerim K.',
      date: 'Tomorrow',
      slot: '08:00 - 09:00',
      attendees: 4,
      status: 'pending',
    ),
  ];

  static const List<OwnerBookingItem> upcomingSessions = [
    OwnerBookingItem(
      id: 'ub-1',
      facilityName: 'Arena Pro Football',
      customerName: 'Monday 6PM Yoga',
      date: 'Mon, Mar 23',
      slot: '18:00 - 19:00',
      attendees: 8,
      status: 'confirmed',
    ),
    OwnerBookingItem(
      id: 'ub-2',
      facilityName: 'Arena Pro Football',
      customerName: 'Pickup Match',
      date: 'Tue, Mar 24',
      slot: '20:00 - 22:00',
      attendees: 14,
      status: 'confirmed',
    ),
  ];

  static const List<OwnerBookingItem> pastSessions = [
    OwnerBookingItem(
      id: 'pb-1',
      facilityName: 'Arena Pro Football',
      customerName: 'Corporate League',
      date: 'Fri, Mar 13',
      slot: '19:00 - 21:00',
      attendees: 12,
      status: 'completed',
    ),
    OwnerBookingItem(
      id: 'pb-2',
      facilityName: 'Skyline Court Center',
      customerName: 'Open Court',
      date: 'Thu, Mar 12',
      slot: '17:00 - 18:00',
      attendees: 6,
      status: 'completed',
    ),
  ];

  static const List<OwnerBookingItem> cancellations = [
    OwnerBookingItem(
      id: 'cb-1',
      facilityName: 'Aqua Sprint Pool',
      customerName: 'Nursultan A.',
      date: 'Yesterday',
      slot: '07:00 - 08:00',
      attendees: 2,
      status: 'cancelled',
    ),
  ];

  static const List<OwnerPayoutItem> payouts = [
    OwnerPayoutItem(
      title: 'Weekly payout',
      date: 'Mar 16, 2026',
      amount: '248,500 ₸',
      status: 'paid',
    ),
    OwnerPayoutItem(
      title: 'Weekly payout',
      date: 'Mar 23, 2026',
      amount: '271,200 ₸',
      status: 'scheduled',
    ),
  ];

  static const Map<String, List<double>> heatmap = {
    'Mon': [0.2, 0.35, 0.5, 0.82, 0.9, 0.7],
    'Tue': [0.24, 0.4, 0.58, 0.78, 0.86, 0.74],
    'Wed': [0.18, 0.3, 0.52, 0.8, 0.88, 0.68],
    'Thu': [0.2, 0.44, 0.64, 0.84, 0.9, 0.75],
    'Fri': [0.26, 0.5, 0.73, 0.9, 0.95, 0.88],
    'Sat': [0.32, 0.58, 0.82, 0.93, 0.97, 0.92],
    'Sun': [0.22, 0.46, 0.65, 0.85, 0.9, 0.8],
  };
}
