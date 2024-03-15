import 'package:flutter/material.dart';

class BillDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> billData;
  final String billType; // To distinguish between "Personal" and "General"

  BillDetailsWidget({Key? key, required this.billData, required this.billType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double water = double.tryParse(billData['water'].toString()) ?? 0.0;
    double electricity =
        double.tryParse(billData['electricity'].toString()) ?? 0.0;
    double wifi = double.tryParse(billData['wifi'].toString()) ?? 0.0;
    double rent = double.tryParse(billData['rent']?.toString() ?? '0.0') ??
        0.0; // Rent might not be present for general bills
    double total = double.tryParse(billData['total'].toString()) ?? 0.0;

    Color cardColor = billType == "Personal"
        ? Colors.lightBlue[100]!
        : Colors.green[100]!; // Highlight colors

    return Card(
      elevation: 4.0,
      color: cardColor, // Apply the color here
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$billType Bill',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  ?.copyWith(color: Colors.deepPurple),
            ),
            const Divider(),
            _buildBillRow("Water", water),
            _buildBillRow("Electricity", electricity),
            _buildBillRow("Wifi", wifi),
            if (billType == "Personal") _buildBillRow("Rent", rent),
            _buildBillRow("Total", total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBillRow(String name, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            "RM ${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
