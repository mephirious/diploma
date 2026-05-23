class ReservationModel {
  final String id;
  final String venueId;
  final String venueName;
  final String venueImage;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int duration;
  final double totalPrice;
  final String status;
  final DateTime bookingDate;

  ReservationModel({
    required this.id,
    required this.venueId,
    required this.venueName,
    required this.venueImage,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.totalPrice,
    required this.status,
    required this.bookingDate,
  });

  ReservationModel copyWith({
    String? id,
    String? venueId,
    String? venueName,
    String? venueImage,
    DateTime? date,
    String? startTime,
    String? endTime,
    int? duration,
    double? totalPrice,
    String? status,
    DateTime? bookingDate,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      venueName: venueName ?? this.venueName,
      venueImage: venueImage ?? this.venueImage,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
    );
  }

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'],
      venueId: json['venueId'],
      venueName: json['venueName'],
      venueImage: json['venueImage'],
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      duration: json['duration'],
      totalPrice: json['totalPrice'].toDouble(),
      status: json['status'],
      bookingDate: DateTime.parse(json['bookingDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venueId': venueId,
      'venueName': venueName,
      'venueImage': venueImage,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      'totalPrice': totalPrice,
      'status': status,
      'bookingDate': bookingDate.toIso8601String(),
    };
  }
}

