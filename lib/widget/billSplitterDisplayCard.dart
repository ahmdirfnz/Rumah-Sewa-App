import 'package:flutter/material.dart';

class UserBillCard extends StatelessWidget {
  final String userName;
  final double amount;
  final VoidCallback onAddAmount;

  const UserBillCard({
    Key? key,
    required this.userName,
    required this.amount,
    required this.onAddAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$userName:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  ' RM ${amount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.add_circle_outline),
              color: Colors.green, // Icon color
              onPressed: onAddAmount,
            ),
          ],
        ),
      ),
    );
  }
}
