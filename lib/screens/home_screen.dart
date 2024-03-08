import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/item.dart';

late User loggedinUser;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController _itemNameController = TextEditingController();

  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future<void> addItemToFirestore(String category, Item item) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(loggedinUser.uid)
          .collection(category)
          .add(item.toMap());
    } catch (e) {
      print('Error adding item: $e');
    }
  }

  Future<List<Item>> fetchItemsFromFirestore(String category) async {
    List<Item> items = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(loggedinUser.uid)
          .collection(category)
          .get();
      querySnapshot.docs.forEach((doc) {
        items.add(Item(name: doc['name'], category: doc['category']));
      });
    } catch (e) {
      print('Error fetching items: $e');
    }
    return items;
  }

  //using this function you can use the credentials of the user
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedinUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Home',
      style: optionStyle,
    ),
    Text(
      'Bills',
      style: optionStyle,
    ),
    Text(
      'To do list',
      style: optionStyle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rumah Sewa App'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                'ahmdirfnz',
              ),
              accountEmail: const Row(
                children: [
                  Text(
                    'irfanz@gmail.com',
                  ),
                ],
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    NetworkImage('https://picsum.photos/250?image=9'),
              ),
              decoration: BoxDecoration(color: Colors.green),
              onDetailsPressed: () {
                // ...
              },
            ),
            ListTile(
              title: const Text('Profile'),
              selected: _selectedIndex == 0,
              onTap: () {
                // Update the state of the app
                _onItemTapped(0);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Settings'),
              selected: _selectedIndex == 1,
              onTap: () {
                // Update the state of the app
                _onItemTapped(1);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('About'),
              selected: _selectedIndex == 2,
              onTap: () {
                // Update the state of the app
                _onItemTapped(2);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Bill',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'To do list',
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCategoryCard('Barang Masak'),
          _buildCategoryCard('Barang Rumah'),
          _buildCategoryCard('Barang Nak Kene Beli'),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(category),
            trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _addItemDialog(context, category);
              },
            ),
          ),
          FutureBuilder<List<Item>>(
            future: fetchItemsFromFirestore(category),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data![index].name),
                      );
                    },
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addItemDialog(BuildContext context, String category) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Item'),
          content: TextField(
            controller: _itemNameController,
            decoration: InputDecoration(hintText: 'Enter item name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_itemNameController.text.isNotEmpty) {
                  addItemToFirestore(
                    category,
                    Item(name: _itemNameController.text, category: category),
                  );
                  _itemNameController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
