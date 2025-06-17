import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
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

  @override
  void initState() {
    super.initState();
    loadInventory();
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

  void updateItem(InventoryItem updatedItem) {
    setState(() {
      int index = inventory.indexWhere((item) => item.name == updatedItem.name);
      if (index != -1) {
        inventory[index] = updatedItem;
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
        title: Text('Inventory List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
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
                          updateItem: updateItem,
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
  final Function(InventoryItem)? updateItem;
  final InventoryItem? itemToEdit;

  AddItemScreen({required this.addItem, this.updateItem, this.itemToEdit});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      nameController.text = widget.itemToEdit!.name;
      quantityController.text = widget.itemToEdit!.quantity.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemToEdit == null ? 'Add Item' : 'Edit Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String name = nameController.text;
                int quantity = int.tryParse(quantityController.text) ?? 0;
                if (name.isNotEmpty && quantity > 0) {
                  InventoryItem newItem = InventoryItem(name: name, quantity: quantity);
                  if (widget.itemToEdit == null) {
                    widget.addItem(newItem);
                  } else {
                    widget.updateItem!(newItem);
                  }
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid name and quantity.')),
                  );
                }
              },
              child: Text(widget.itemToEdit == null ? 'Add Item' : 'Update Item'),
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
