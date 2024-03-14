import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/bill.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final TextEditingController waterController = TextEditingController();
  final TextEditingController electricityController = TextEditingController();
  final TextEditingController wifiController = TextEditingController();
  final TextEditingController rentController = TextEditingController();

  double totalBill = 0.0;
  double splitAmount = 0.0;
  double rentBill = 0.0;
  bool isLoading = false;

  late DateTime selectedMonth = DateTime.now();
  late Stream<QuerySnapshot> billsStream;

  @override
  void initState() {
    super.initState();
    selectedMonth = _generateInitialMonth();
    _fetchRentBill();
    billsStream = _getBillsStream(selectedMonth);
  }

  DateTime _generateInitialMonth() {
    final currentMonth =
        DateTime.now().subtract(Duration(days: DateTime.now().day - 1));
    return DateTime(currentMonth.year, currentMonth.month);
  }

  Stream<QuerySnapshot> _getBillsStream(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    return FirebaseFirestore.instance
        .collection('bills')
        .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
        .where('timestamp', isLessThanOrEqualTo: endOfMonth)
        .snapshots();
  }

  Future<void> _fetchRentBill() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No User logged in');
      return;
    }

    String userId = user.uid;
    print(userId);

    try {
      final userRentDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userRentDocument.exists) {
        final rentValue = userRentDocument.data()?['rent']?.toDouble() ?? 0.0;
        setState(() {
          rentBill = rentValue;
          rentController.text =
              rentValue.toStringAsFixed(2); // Update the controller here
        });
      }
    } catch (e) {
      // Handle error
      print("Error fetching rent bill: $e");
    }
  }

  void _saveBill() async {
    final waterBill = double.parse(waterController.text);
    final electricityBill = double.parse(electricityController.text);
    final wifiBill = double.parse(wifiController.text);

    setState(() {
      totalBill = waterBill + electricityBill + wifiBill + rentBill;
      splitAmount = totalBill / 3; // Adjust based on your splitting logic.
    });

    final newBill = Bill(
      water: waterBill,
      electricity: electricityBill,
      wifi: wifiBill,
      rent: rentBill,
      total: totalBill,
      timestamp: DateTime.now(), // Ensure your Bill model accepts a Timestamp.
    );

    await FirebaseFirestore.instance.collection('bills').add(newBill.toMap());

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Bill saved successfully')));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        // Wrap the column in a SingleChildScrollView
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter Bill Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Select Month: '),
                  DropdownButton<DateTime>(
                    value: selectedMonth,
                    onChanged: (DateTime? newValue) {
                      setState(() {
                        selectedMonth = newValue!;
                        billsStream = _getBillsStream(selectedMonth);
                      });
                    },
                    items: List<DropdownMenuItem<DateTime>>.generate(
                      12,
                      (int index) {
                        final currentMonth = DateTime.now()
                            .subtract(Duration(days: DateTime.now().day - 1));
                        final month = DateTime(
                            currentMonth.year, currentMonth.month - index);
                        return DropdownMenuItem<DateTime>(
                          value: month,
                          child: Text('${month.year}/${month.month}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: waterController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Water Bill (RM)',
                  border: OutlineInputBorder(),
                  hintText: '0.00',
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: electricityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Electricity Bill (RM)',
                  border: OutlineInputBorder(),
                  hintText: '0.00',
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: wifiController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Wifi Bill (RM)',
                  border: OutlineInputBorder(),
                  hintText: '0.00',
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Enter Bill Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              // Other widgets...
              SizedBox(height: 20),
              TextFormField(
                controller: rentController, // Use the controller here
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Rent Bill (RM)',
                  border: OutlineInputBorder(),
                ),
              ),
              // Other widgets...
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveBill,
                child: Text('Save Bill'),
              ),
              SizedBox(height: 20),
              if (totalBill > 0)
                Column(
                  children: [
                    Text(
                      'Total Bill: \$${totalBill.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Each Person Pays: \$${splitAmount.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              SizedBox(height: 20),
              Text(
                'Bill Statements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: billsStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final bills = snapshot.data!.docs;
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: bills.length,
                    itemBuilder: (context, index) {
                      final bill = bills[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bill ${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Divider(color: Colors.grey),
                            Text('Water: RM${bill['water']}'),
                            Divider(color: Colors.grey),
                            Text('Electricity: RM${bill['electricity']}'),
                            Divider(color: Colors.grey),
                            Text('Wifi: RM${bill['wifi']}'),
                            Divider(color: Colors.grey),
                            Text('Rent: RM${bill['rent']}'),
                            Divider(color: Colors.grey),
                            Text(
                              'Total: RM${bill['total']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
