import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  String name;
  String category;
  final Timestamp timestamp; // Add timestamp field

  Item({
    required this.name,
    required this.category,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'category': category, 'timestamp': timestamp};
  }

  factory Item.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Item(
      name: data['name'],
      category: data['category'],
      timestamp: data['timestamp'],
    );
  }
}
