import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rumah_sewa_app/screens/bill_screen.dart';
import 'package:rumah_sewa_app/screens/personalTodoList_screen.dart';
import '../utils/item.dart';

User? loggedinUser;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;

  late String _accountName = "";
  late String _accountEmail = "";
  late String _accountPictureURL = "";

  Future<void> getCurrentUser() async {
    try {
      // await _auth.relo
      final user = _auth.currentUser;
      user?.reload();
      if (user != null) {
        setState(() {
          loggedinUser = user;
          _accountName =
              user.displayName ?? 'test'; // Using displayName if available
          _accountEmail = user.email ?? '';
          _accountPictureURL = user.photoURL ?? 'test';
          print(_accountName);
          print(_accountEmail);
          print(_accountPictureURL);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void initState() {
    super.initState();
    getCurrentUser();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    BillScreen(),
    TodoList(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  _auth.signOut();
                  Navigator.pushNamed(context, 'welcome_screen');
                },
                icon: Icon(Icons.logout_rounded))
          ],
          title: const Text(
            'Rumah Sewa Management App',
            style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.lightBlueAccent,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  _accountName,
                ),
                accountEmail: Row(
                  children: [
                    Text(
                      _accountEmail,
                    ),
                  ],
                ),
                currentAccountPicture: CircleAvatar(
                    backgroundImage: NetworkImage("${_accountPictureURL}")),
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
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController _itemNameController = TextEditingController();

  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future<void> addItemToFirestore(String category, Item item) async {
    try {
      await FirebaseFirestore.instance.collection('items').add(item.toMap());
    } catch (e) {
      print('Error adding item: $e');
    }
  }

  Stream<List<Item>> fetchItemsFromFirestore(String category) {
    try {
      return FirebaseFirestore.instance.collection('items').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Item(
                  name: doc['name'],
                  category: doc['category'],
                  timestamp: doc['timestamp']))
              .toList());
    } catch (e) {
      print('Error fetching items: $e');
      return Stream.empty();
    }
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
          StreamBuilder<List<Item>>(
            stream: fetchItemsFromFirestore(category),
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
                      return CheckboxListTile(
                        // tileColor: Colors.red,
                        title: Text(snapshot.data![index].name),
                        value: false,
                        onChanged: (bool? value) {},
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
                  final timestamp = Timestamp.now();
                  addItemToFirestore(
                      category,
                      Item(
                          name: _itemNameController.text,
                          category: category,
                          timestamp: timestamp));
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
