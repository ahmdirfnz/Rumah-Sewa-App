import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  double water;
  double electricity;
  double wifi;
  double rent; // New property for rent bill
  double total;
  DateTime timestamp;

  Bill({
    required this.water,
    required this.electricity,
    required this.wifi,
    required this.rent,
    required this.total,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'water': water,
      'electricity': electricity,
      'wifi': wifi,
      'rent': rent, // Add rent to the map
      'total': total,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      water: map['water'],
      electricity: map['electricity'],
      wifi: map['wifi'],
      rent: map['rent'], // Read rent from the map
      total: map['total'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
