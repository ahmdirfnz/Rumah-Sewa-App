import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rumah_sewa_app/widget/billDetailsCard.dart';

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
  String userRole = 'user';
  bool isLoading = true;

  late DateTime selectedMonth = DateTime.now();
  List<DateTime> months = List.generate(12, (index) {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month - index);
  }).reversed.toList(); // Generates a list of the last 12 months
  // late Stream<QuerySnapshot> billsStream;
  late Stream<DocumentSnapshot> personalBillStream;
  late Stream<DocumentSnapshot> generalBillStream;

  @override
  void initState() {
    super.initState();
    selectedMonth = _generateInitialMonth();
    _fetchRentBill();
    _updateBillStreams(selectedMonth);
    _determineUserRole();
    // billsStream = _getBillsStream(selectedMonth);
  }

  Future<void> _determineUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final role = docSnapshot.data()?['role'] ?? 'user';
      setState(() {
        userRole = role;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false); // Handle not logged in state
    }
  }

  void _updateBillStreams(DateTime month) {
    String monthYear = _formatMonthYear(month);
    personalBillStream = _getPersonalBillStream(monthYear);
    generalBillStream = _getGeneralBillStream(monthYear);
  }

  String _formatMonthYear(DateTime date) {
    return "${date.month}-${date.year}";
  }

  String _formatMonthForDisplay(DateTime date) {
    return "${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  DateTime _generateInitialMonth() {
    final currentMonth =
        DateTime.now().subtract(Duration(days: DateTime.now().day - 1));
    return DateTime(currentMonth.year, currentMonth.month);
  }

  Future<void> _savePersonalBill(
      DateTime selectedMonth, Bill bill, String userId) async {
    // Convert selectedMonth to a month-year string format if needed
    String monthYear = "${selectedMonth.month}-${selectedMonth.year}";

    // Convert DateTime to Timestamp if saving to Firestore
    Timestamp billTimestamp = Timestamp.fromDate(bill.timestamp);

    // Construct your bill data map, ensuring dates are properly converted
    Map<String, dynamic> billData = {
      'water': bill.water,
      'electricity': bill.electricity,
      'wifi': bill.wifi,
      'rent': bill.rent,
      'total': bill.total,
      'timestamp': billTimestamp,
    };

    await FirebaseFirestore.instance
        .collection('personalBills')
        .doc(userId)
        .collection('bills')
        .doc(monthYear)
        .set(billData);
  }

  Future<void> _saveGeneralBill(DateTime date, Bill bill) async {
    String monthYear = "${date.month}-${date.year}";
    await FirebaseFirestore.instance
        .collection('generalBills')
        .doc(monthYear)
        .set({
      'water': bill.water,
      'electricity': bill.electricity,
      'wifi': bill.wifi,
      'total': bill.total,
      'timestamp': bill.timestamp,
    });
  }

  Stream<DocumentSnapshot> _getPersonalBillStream(String monthYear) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      return Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('personalBills')
        .doc(user.uid)
        .collection('bills')
        .doc(monthYear)
        .snapshots();
  }

  Stream<DocumentSnapshot> _getGeneralBillStream(String monthYear) {
    return FirebaseFirestore.instance
        .collection('generalBills')
        .doc(monthYear)
        .snapshots();
  }

  void _updateUserBillsWithGeneralBill(Bill generalBill) async {
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    for (var doc in usersSnapshot.docs) {
      // Assuming each user document has a 'rent' field with the rent amount
      final userRent = double.tryParse(doc.data()['rent'].toString()) ?? 0.0;

      final sharedBill =
          (generalBill.water + generalBill.electricity + generalBill.wifi) / 3;
      final individualTotal =
          sharedBill + userRent; // Using the user-specific rent value

      final personalBill = Bill(
        water: generalBill.water / 3,
        electricity: generalBill.electricity / 3,
        wifi: generalBill.wifi / 3,
        rent: userRent, // Now using the fetched userRent value
        total: individualTotal,
        timestamp:
            DateTime.now(), // Ensure this is converted correctly for Firestore
      );

      await _savePersonalBill(selectedMonth, personalBill, doc.id);
    }
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User bills updated successfully.')));
  }

  void _handleAdminBillSubmission() async {
    // Assuming rentBill holds the latest rent value fetched from Firestore
    final rent = rentBill; // Use the rent value fetched from Firestore

    final water = double.tryParse(waterController.text) ?? 0.0;
    final electricity = double.tryParse(electricityController.text) ?? 0.0;
    final wifi = double.tryParse(wifiController.text) ?? 0.0;

    // Calculate the shared part of the bill (excluding rent, divided by 3)
    final sharedBill = (water + electricity + wifi) / 3;

    final generalBill = Bill(
      water: water,
      electricity: electricity,
      wifi: wifi,
      rent: 0, // Rent is not part of the general bill
      total: water + electricity + wifi, // General bill total (without rent)
      timestamp: DateTime.now(),
    );

    try {
      await _saveGeneralBill(selectedMonth, generalBill);

      // Assuming _updateUserBillsWithGeneralBill will use the sharedBill and add individual rent
      _updateUserBillsWithGeneralBill(generalBill);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('General bill saved.')));
    } catch (e) {
      print("Failed to save general bill: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save general bill.')));
    }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Select Month: '),
                  DropdownButton<DateTime>(
                    value: selectedMonth,
                    onChanged: (DateTime? newValue) {
                      setState(() {
                        selectedMonth = newValue!;
                        _updateBillStreams(selectedMonth);
                      });
                    },
                    items: months
                        .map<DropdownMenuItem<DateTime>>((DateTime value) {
                      return DropdownMenuItem<DateTime>(
                        value: value,
                        child: Text(_formatMonthForDisplay(value)),
                      );
                    }).toList(),
                  ),
                ],
              ),
              if (userRole == 'admin') _buildAdminBillEntryForm(),
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
              StreamBuilder<DocumentSnapshot>(
                stream: generalBillStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  var data =
                      snapshot.data?.data() as Map<String, dynamic>? ?? {};
                  return BillDetailsWidget(billData: data, billType: "General");
                },
              ),
              SizedBox(height: 10),
              StreamBuilder<DocumentSnapshot>(
                stream: personalBillStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  var data =
                      snapshot.data?.data() as Map<String, dynamic>? ?? {};
                  return BillDetailsWidget(
                      billData: data, billType: "Personal");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminBillEntryForm() {
    return Column(
      children: [
        Text(
          'Enter Bill Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
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
        // Other widgets...
        // TextFormField(
        //   controller: rentController, // Use the controller here
        //   readOnly: true,
        //   decoration: InputDecoration(
        //     labelText: 'Rent Bill (RM)',
        //     border: OutlineInputBorder(),
        //   ),
        // ),
        // Other widgets...
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _handleAdminBillSubmission,
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
      ],
    );
  }
}
