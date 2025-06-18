import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// NJSharp Full Palette
const Color njPrimary = Color(0xFFA6C4DC);      // Powder Blue
const Color njSecondary = Color(0xFFBDBAC3);    // French Grey
const Color njTertiary = Color(0xFF48495D);     // Charcoal
const Color njError = Color(0xFFFF453A);        // Red
const Color njBackground = Color(0xFFA6C4DC);   // Powder Blue
const Color njSurface = Color(0xFFFFFFFF);      // White surface
const Color njOnPrimary = Color(0xFFFFFFFF);    // On blue
const Color njOnSecondary = Color(0xFF000000);  // On green
const Color njOnTertiary = Color(0xFF000000);   // On orange
const Color njOnError = Color(0xFFFFFFFF);      // On red
const Color njOnBackground = Color(0xFF1C1C1E); // On light background
const Color njOnSurface = Color(0xFF1C1C1E);    // On white

const Color njDarkBackground = Color(0xFF232436); // Dark background
const Color njDarkSurface = Color(0xFF232436);    // Dark surface
const Color njDarkOnBackground = Color(0xFF333353);
const Color njDarkOnSurface = Color(0xFFF2F2F7);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory App',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: njPrimary,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: njPrimary,
          onPrimary: njOnPrimary,
          secondary: njSecondary,
          onSecondary: njOnSecondary,
          error: njError,
          onError: njOnError,
          background: njBackground,
          onBackground: njOnBackground,
          surface: njSurface,
          onSurface: njOnSurface,
        ),
        scaffoldBackgroundColor: njBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: njPrimary,
          foregroundColor: njOnPrimary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: njPrimary,
            foregroundColor: njOnPrimary,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: njSurface,
          border: OutlineInputBorder(),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: njError,
          contentTextStyle: TextStyle(color: njOnError),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: njPrimary,
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: njPrimary,
          onPrimary: njOnPrimary,
          secondary: njSecondary,
          onSecondary: njOnSecondary,
          error: njError,
          onError: njOnError,
          background: njDarkBackground,
          onBackground: njDarkOnBackground,
          surface: njDarkSurface,
          onSurface: njDarkOnSurface,
        ),
        scaffoldBackgroundColor: njDarkBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: njPrimary,
          foregroundColor: njOnPrimary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: njPrimary,
            foregroundColor: njOnPrimary,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: njDarkSurface,
          border: OutlineInputBorder(),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: njError,
          contentTextStyle: TextStyle(color: njOnError),
        ),
      ),
      themeMode: ThemeMode.system,
      home: InventoryListScreen(),
    );
  }
}

class InventoryListScreen extends StatefulWidget {
  @override
  _InventoryListScreenState createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  List<InventoryItem> inventory = [];
  List<InventoryItem> filteredInventory = [];
  TextEditingController searchController = TextEditingController();
  FocusNode? searchFocusNode;

  @override
  void initState() {
    super.initState();
    loadInventory();
    searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    searchFocusNode?.dispose();
    super.dispose();
  }

  loadInventory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? inventoryList = prefs.getStringList('inventory');
    if (inventoryList != null) {
      setState(() {
        inventory = inventoryList.map((item) => InventoryItem.fromJson(json.decode(item))).toList();
        filteredInventory = List.from(inventory);
      });
    } else {
      filteredInventory = List.from(inventory);
    }
  }

  saveInventory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> inventoryList = inventory.map((item) => json.encode(item.toJson())).toList();
    prefs.setStringList('inventory', inventoryList);
  }

  void addItem(InventoryItem item) {
    setState(() {
      inventory.add(item);
      filteredInventory = List.from(inventory);
      saveInventory();
    });
  }

  void updateItem(InventoryItem updatedItem, {String? oldName}) {
    setState(() {
      String nameToFind = oldName ?? updatedItem.name;
      int index = inventory.indexWhere((item) => item.name == nameToFind);
      if (index != -1) {
        // If the name changed, remove the old item first
        if (oldName != null && oldName != updatedItem.name) {
          inventory.removeAt(index);
          inventory.add(updatedItem);
        } else {
          inventory[index] = updatedItem;
        }
        filteredInventory = List.from(inventory);
        saveInventory();
      }
    });
  }

  void filterInventory(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredInventory = List.from(inventory);
      } else {
        filteredInventory = inventory
            .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lofty | Inventory'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                autofocus: false, // Ensure this is set to false
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: filterInventory,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredInventory.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredInventory[index].name),
                    subtitle: Text('Quantity: ${filteredInventory[index].quantity}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddItemScreen(
                            addItem: addItem,
                            updateItem: (item, {String? oldName}) => updateItem(item, oldName: oldName),
                            itemToEdit: filteredInventory[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddItemScreen(
                addItem: addItem,
                updateItem: updateItem,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddItemScreen extends StatefulWidget {
  final Function(InventoryItem) addItem;
  final Function(InventoryItem, {String? oldName})? updateItem;
  final InventoryItem? itemToEdit;

  AddItemScreen({required this.addItem, this.updateItem, this.itemToEdit});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  late String originalName;

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      nameController.text = widget.itemToEdit!.name;
      quantityController.text = '';
      originalName = widget.itemToEdit!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemToEdit != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Item' : 'Add Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            SizedBox(height: 24), // Added spacing
            if (!isEditing)
              Column(
                children: [
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 24), // Added spacing
                ],
              ),
            if (isEditing) ...[
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Amount to Add/Remove'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24), // Added spacing
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        int change = int.tryParse(quantityController.text) ?? 0;
                        String newName = nameController.text.trim();
                        if (newName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Enter a valid name.')),
                          );
                          return;
                        }
                        if (change > 0) {
                          int newQuantity = widget.itemToEdit!.quantity + change;
                          widget.updateItem!(
                            InventoryItem(
                              name: newName,
                              quantity: newQuantity,
                            ),
                            oldName: originalName,
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Enter a valid amount to add.')),
                          );
                        }
                      },
                      child: Text('Add'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        int change = int.tryParse(quantityController.text) ?? 0;
                        String newName = nameController.text.trim();
                        int currentStock = widget.itemToEdit!.quantity;
                        if (newName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Enter a valid name.')),
                          );
                          return;
                        }
                        if (change > 0) {
                          if (change > currentStock) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Cannot remove more than is in stock.')),
                            );
                            return;
                          }
                          int newQuantity = currentStock - change;
                          widget.updateItem!(
                            InventoryItem(
                              name: newName,
                              quantity: newQuantity,
                            ),
                            oldName: originalName,
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Enter a valid amount to remove.')),
                          );
                        }
                      },
                      child: Text('Remove'),
                    ),
                  ),
                ],
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    String newName = nameController.text.trim();
                    if (newName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Enter a valid name.')),
                      );
                      return;
                    }
                    // Save name change only, keep quantity the same
                    widget.updateItem!(
                      InventoryItem(
                        name: newName,
                        quantity: widget.itemToEdit!.quantity,
                      ),
                      oldName: originalName,
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Save'),
                ),
              ),
            ],
            if (!isEditing)
              ElevatedButton(
                onPressed: () {
                  String name = nameController.text.trim();
                  int quantity = int.tryParse(quantityController.text) ?? 0;
                  if (name.isNotEmpty && quantity > 0) {
                    widget.addItem(InventoryItem(name: name, quantity: quantity));
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid name and quantity.')),
                    );
                  }
                },
                child: Text('Add Item'),
              ),
          ],
        ),
      ),
    );
  }
}

class InventoryItem {
  String name;
  int quantity;

  InventoryItem({required this.name, required this.quantity});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      name: json['name'],
      quantity: json['quantity'],
    );
  }
}
