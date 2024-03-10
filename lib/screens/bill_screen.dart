import 'package:flutter/material.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryCard('Water'),
            _buildCategoryCard('Electricity'),
            _buildCategoryCard('Rent'),
            _buildCategoryCard('WiFi'),
            _buildSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter amount',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            _buildSummaryItem('Water', 100.0),
            _buildSummaryItem('Electricity', 150.0),
            _buildSummaryItem('Rent', 1200.0),
            _buildSummaryItem('WiFi', 50.0),
            Divider(),
            _buildTotalAmount(1500.0), // Total amount
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String category, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(category),
        Text('\$$amount'),
      ],
    );
  }

  Widget _buildTotalAmount(double totalAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '\$$totalAmount',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
