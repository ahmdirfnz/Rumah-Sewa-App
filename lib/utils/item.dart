class Item {
  late String name;
  late String category;
  late DateTime timestamp;
  late bool status;

  Item(
      {required this.name,
      required this.category,
      required this.timestamp,
      required this.status});

  // Convert Item to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'timestamp': timestamp,
      'status': status
    };
  }

  // Create Item from a Map
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
        name: map['name'],
        category: map['category'],
        timestamp: map['timestamp'].toDate(),
        status: map['status']);
  }
}
