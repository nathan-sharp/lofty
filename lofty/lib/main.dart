import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(LoftInventoryApp());
}

class LoftInventoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: SplashScreen(),
    );
  }
}

// Splash screen that shows "NJSharp" centered at the bottom
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 1 second before navigating to the main app
    Timer(Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoftInventoryHomeWrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Centered text at the bottom of the screen
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Text(
                'NJSharp',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Wrapper for the home screen to manage theme toggling
class LoftInventoryHomeWrapper extends StatefulWidget {
  @override
  _LoftInventoryHomeWrapperState createState() => _LoftInventoryHomeWrapperState();
}

class _LoftInventoryHomeWrapperState extends State<LoftInventoryHomeWrapper> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: LoftInventoryHome(toggleTheme: _toggleTheme, themeMode: _themeMode),
    );
  }
}

// Main app content after the splash screen
class LoftInventoryHome extends StatefulWidget {
  final Function toggleTheme;
  final ThemeMode themeMode;

  LoftInventoryHome({required this.toggleTheme, required this.themeMode});

  @override
  _LoftInventoryHomeState createState() => _LoftInventoryHomeState();
}

class _LoftInventoryHomeState extends State<LoftInventoryHome> {
  List<LoftItem> items = [];
  int _selectedIndex = 0;

  // Controllers for the Add Item form
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();

  void _addItem(LoftItem item) {
    setState(() {
      items.add(item);
    });
  }

  // Method to build the screen based on selected index
  Widget _buildBody() {
    if (_selectedIndex == 0) {
      // Item List Screen
      return items.isEmpty
          ? Center(child: Text('No items yet. Add some!'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index].name),
                  subtitle: Text('Location: ${items[index].location}'),
                );
              },
            );
    } else if (_selectedIndex == 1) {
      // Add Item Screen
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newItem = LoftItem(
                  name: _nameController.text,
                  description: _descriptionController.text,
                  category: _categoryController.text,
                  location: _locationController.text,
                );
                _addItem(newItem);

                // Clear the text fields
                _nameController.clear();
                _descriptionController.clear();
                _categoryController.clear();
                _locationController.clear();

                // Switch to the item list after adding an item
                setState(() {
                  _selectedIndex = 0;
                });
              },
              child: Text('Add Item'),
            ),
          ],
        ),
      );
    } else {
      // Search Screen
      return SearchItemsScreen(items: items);
    }
  }

  // Method to handle bottom navigation tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loft Inventory'),
        actions: [
          IconButton(
            icon: Icon(widget.themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              widget.toggleTheme();
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Item',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}

class SearchItemsScreen extends StatefulWidget {
  final List<LoftItem> items;

  SearchItemsScreen({required this.items});

  @override
  _SearchItemsScreenState createState() => _SearchItemsScreenState();
}

class _SearchItemsScreenState extends State<SearchItemsScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
            decoration: InputDecoration(labelText: 'Search by Name'),
          ),
        ),
        Expanded(
          child: filteredItems.isEmpty
              ? Center(child: Text('No items found.'))
              : ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(filteredItems[index].name),
                      subtitle: Text('Location: ${filteredItems[index].location}'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class LoftItem {
  String name;
  String description;
  String category;
  String location;

  LoftItem({
    required this.name,
    required this.description,
    required this.category,
    required this.location,
  });
}
