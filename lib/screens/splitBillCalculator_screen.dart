import 'package:flutter/material.dart';

class SplitBillCalculatorPage extends StatefulWidget {
  const SplitBillCalculatorPage({super.key});

  @override
  State<SplitBillCalculatorPage> createState() =>
      _SplitBillCalculatorPageState();
}

class _SplitBillCalculatorPageState extends State<SplitBillCalculatorPage> {
  TextEditingController _itemNameController = TextEditingController();
  TextEditingController _itemCostController = TextEditingController();
  TextEditingController _numOfPeopleController = TextEditingController();
  double _totalBillAmount = 0.0;
  String _splitStatement = '';

  void _addItem() {
    setState(() {
      _totalBillAmount += double.parse(_itemCostController.text);
      _itemCostController.clear();
      _itemNameController.clear();
      _splitStatement = '';
    });
  }

  void _calculateSplitAmount() {
    double totalBill = _totalBillAmount;
    int numOfPeople = int.parse(_numOfPeopleController.text);
    double splitAmount = totalBill / numOfPeople;
    setState(() {
      _splitStatement = 'Each person owes \$${splitAmount.toStringAsFixed(2)}';
    });
  }

  void _reset() {
    setState(() {
      _totalBillAmount = 0.0;
      _itemCostController.clear();
      _itemNameController.clear();
      _numOfPeopleController.clear();
      _splitStatement = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Add Items',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _itemNameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _itemCostController,
              decoration: InputDecoration(labelText: 'Item Cost (\$)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 10.0),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _addItem,
                child: Text(
                  'Add Item',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Total Bill Amount: \$${_totalBillAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _numOfPeopleController,
              decoration: InputDecoration(labelText: 'Number of People'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10.0),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _calculateSplitAmount,
                child: Text(
                  'Calculate Split',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _reset,
                child: Text(
                  'Reset',
                  style: TextStyle(fontSize: 18.0, color: Colors.red),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            _splitStatement.isNotEmpty
                ? Text(
                    _splitStatement,
                    style: TextStyle(fontSize: 18.0),
                  )
                : Container(),
            Spacer(),
            Text(
              'This is a simple split bill calculator for shopping bills.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
