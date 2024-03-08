import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  String name;
  String category;

  Item({required this.name, required this.category});

  Map<String, dynamic> toMap() {
    return {'name': name, 'category': category};
  }

  factory Item.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Item(name: data['name'], category: data['category']);
  }
}
