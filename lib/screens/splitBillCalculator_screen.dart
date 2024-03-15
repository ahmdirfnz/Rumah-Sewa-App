import 'package:flutter/material.dart';
import 'package:rumah_sewa_app/widget/billSplitterDisplayCard.dart';
import 'package:url_launcher/url_launcher.dart';

class SplitBillCalculatorPage extends StatefulWidget {
  const SplitBillCalculatorPage({super.key});

  @override
  State<SplitBillCalculatorPage> createState() =>
      _SplitBillCalculatorPageState();
}

class _SplitBillCalculatorPageState extends State<SplitBillCalculatorPage> {
  TextEditingController _itemCostController = TextEditingController();
  double _totalBillAmount = 0.0;
  Map<String, double> _splitAmounts = {"Irfan": 0.0, "Alep": 0.0, "Ustaz": 0.0};

  void _addItem() {
    setState(() {
      _totalBillAmount += double.parse(
          _itemCostController.text.isEmpty ? "0" : _itemCostController.text);
      _itemCostController.clear();
      _calculateSplitAmount();
    });
  }

  void _calculateSplitAmount() {
    double splitAmount = _totalBillAmount / _splitAmounts.length;
    _splitAmounts =
        _splitAmounts.map((key, value) => MapEntry(key, splitAmount));
  }

  void _reset() {
    setState(() {
      _totalBillAmount = 0.0;
      _itemCostController.clear();
      _splitAmounts = {"Irfan": 0.0, "Alep": 0.0, "Ustaz": 0.0};
    });
  }

  Widget _buildUserCard(String name, double amount) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text('\RM${amount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        tileColor: Colors.grey[200],
      ),
    );
  }

  void handleAddAmount(String userName) {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Add Amount",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(hintText: "0.00"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Add"),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  double amountToAdd = double.tryParse(_controller.text) ?? 0.0;
                  setState(() {
                    _splitAmounts[userName] =
                        (_splitAmounts[userName] ?? 0) + amountToAdd;
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _shareToWhatsApp() async {
    String message = "Split Bill Receipt:\n\n";
    message += "Total Bill: RM${_totalBillAmount.toStringAsFixed(2)}\n\n";
    _splitAmounts.forEach((name, amount) {
      message += "$name: RM${amount.toStringAsFixed(2)}\n";
    });

    message += "\nThank you...";

// Using https://wa.me/?text= which is a universal link that should work across all devices.
    final Uri uri = Uri.parse("https://wa.me/?text=${Uri.encodeFull(message)}");

    if (await canLaunchUrl(uri)) {
      // await launchUrl(uri, mode: LaunchMode.externalApplication);
      await launchUrl(uri);
    } else {
      print('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Add Items',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: _itemCostController,
                decoration: InputDecoration(labelText: 'Item Cost (RM)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 10.0),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _addItem,
                  child: Text('Add Item', style: TextStyle(fontSize: 18.0)),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Total Bill Amount: RM${_totalBillAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 20.0),
              ..._splitAmounts.entries.map((entry) => UserBillCard(
                    userName: entry.key,
                    amount: entry.value,
                    onAddAmount: () => handleAddAmount(entry.key),
                  )),
              SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: _shareToWhatsApp,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green, // Text color
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize
                          .min, // This ensures the Row only takes up as much width as its children need
                      children: [
                        Text("Share to "),
                        Image.asset('assets/icons/whatsapp.png',
                            width: 24), // WhatsApp icon
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _reset,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red, // Button text color
                  ),
                  child: Text('Reset', style: TextStyle(fontSize: 18.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
