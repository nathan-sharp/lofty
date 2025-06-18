import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';

// NJSharp Full Palette
const Color njPrimary = Color(0xFFA6C4DC);      // Powder Blue
const Color njSecondary = Color(0xFFBDBAC3);    // French Grey
const Color njTertiary = Color(0xFF48495D);     // Charcoal
const Color njError = Color(0xFFFF453A);        // Red
const Color njBackground = Color(0xFFE8CDAF);   // French Grey
const Color njSurface = Color(0xFFE8CDAF);      // White surface
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  String? _csvPath;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadCsvPath();
  }

  void _setSystemUIOverlayStyle(Brightness brightness) {
    SystemChrome.setSystemUIOverlayStyle(
      brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeString = prefs.getString('themeMode');
    setState(() {
      if (themeString == 'light') {
        _themeMode = ThemeMode.light;
      } else if (themeString == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
    });
    final brightness = _themeMode == ThemeMode.dark
        ? Brightness.dark
        : _themeMode == ThemeMode.light
            ? Brightness.light
            : WidgetsBinding.instance.window.platformBrightness;
    _setSystemUIOverlayStyle(brightness);
  }

  void _setTheme(ThemeMode mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = mode;
    });
    if (mode == ThemeMode.light) {
      prefs.setString('themeMode', 'light');
      _setSystemUIOverlayStyle(Brightness.light);
    } else if (mode == ThemeMode.dark) {
      prefs.setString('themeMode', 'dark');
      _setSystemUIOverlayStyle(Brightness.dark);
    } else {
      prefs.setString('themeMode', 'system');
      final platformBrightness = WidgetsBinding.instance.window.platformBrightness;
      _setSystemUIOverlayStyle(platformBrightness);
    }
  }

  void _loadCsvPath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? path = prefs.getString('csvPath');
    if (path == null) {
      // Set default path
      Directory dir = await getApplicationDocumentsDirectory();
      path = '${dir.path}/inventory.csv';
      prefs.setString('csvPath', path);
    }
    setState(() {
      _csvPath = path;
    });
  }

  void _setCsvPath(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('csvPath', path);
    setState(() {
      _csvPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final platformBrightness = WidgetsBinding.instance.window.platformBrightness;
    if (_themeMode == ThemeMode.system) {
      _setSystemUIOverlayStyle(platformBrightness);
    }
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
          surface: njSurface,
          onSurface: njOnSurface,
        ),
        scaffoldBackgroundColor: njBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: njOnPrimary,
          iconTheme: IconThemeData(color: njOnPrimary),
          titleTextStyle: TextStyle(
            color: njOnPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          // Remove systemOverlayStyle here, handled globally above
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
          surface: njDarkSurface,
          onSurface: njDarkOnSurface,
        ),
        scaffoldBackgroundColor: njDarkBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: njOnPrimary,
          iconTheme: IconThemeData(color: njOnPrimary),
          titleTextStyle: TextStyle(
            color: njOnPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          // Remove systemOverlayStyle here, handled globally above
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
      themeMode: _themeMode,
      home: InventoryListScreen(
        onThemeChanged: _setTheme,
        currentThemeMode: _themeMode,
        csvPath: _csvPath,
        onCsvPathChanged: _setCsvPath,
      ),
    );
  }
}

class InventoryListScreen extends StatefulWidget {
  final void Function(ThemeMode)? onThemeChanged;
  final ThemeMode? currentThemeMode;
  final String? csvPath;
  final void Function(String)? onCsvPathChanged;

  const InventoryListScreen({super.key, 
    this.onThemeChanged,
    this.currentThemeMode,
    this.csvPath,
    this.onCsvPathChanged,
  });

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
    searchFocusNode = FocusNode();
    _loadInventory();
  }

  @override
  void didUpdateWidget(covariant InventoryListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.csvPath != oldWidget.csvPath) {
      _loadInventory();
    }
  }

  @override
  void dispose() {
    searchFocusNode?.dispose();
    super.dispose();
  }

  Future<void> _loadInventory() async {
    if (widget.csvPath == null) return;
    File file = File(widget.csvPath!);
    if (!await file.exists()) {
      await file.writeAsString(const ListToCsvConverter().convert([]));
    }
    final csvString = await file.readAsString();
    final rows = const CsvToListConverter().convert(csvString);
    setState(() {
      inventory = rows
          .where((row) => row.length >= 2)
          .map((row) => InventoryItem(name: row[0].toString(), quantity: int.tryParse(row[1].toString()) ?? 0))
          .toList();
      filteredInventory = List.from(inventory);
    });
  }

  Future<void> _saveInventory() async {
    if (widget.csvPath == null) return;
    File file = File(widget.csvPath!);
    List<List<dynamic>> rows = inventory.map((item) => [item.name, item.quantity]).toList();
    await file.writeAsString(const ListToCsvConverter().convert(rows));
  }

  void addItem(InventoryItem item) {
    setState(() {
      inventory.add(item);
      filteredInventory = List.from(inventory);
    });
    _saveInventory();
  }

  void updateItem(InventoryItem updatedItem, {String? oldName}) {
    setState(() {
      String nameToFind = oldName ?? updatedItem.name;
      int index = inventory.indexWhere((item) => item.name == nameToFind);
      if (index != -1) {
        if (oldName != null && oldName != updatedItem.name) {
          inventory.removeAt(index);
          inventory.add(updatedItem);
        } else {
          inventory[index] = updatedItem;
        }
        filteredInventory = List.from(inventory);
      }
    });
    _saveInventory();
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
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onThemeChanged: widget.onThemeChanged,
                    currentThemeMode: widget.currentThemeMode,
                    csvPath: widget.csvPath,
                    onCsvPathChanged: widget.onCsvPathChanged,
                    onReloadInventory: _loadInventory,
                  ),
                ),
              );
            },
          ),
        ],
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
                autofocus: false,
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

  const AddItemScreen({super.key, required this.addItem, this.updateItem, this.itemToEdit});

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
            SizedBox(height: 24),
            if (!isEditing)
              Column(
                children: [
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 24),
                ],
              ),
            if (isEditing) ...[
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Amount to Add/Remove'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24),
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

class SettingsScreen extends StatefulWidget {
  final void Function(ThemeMode)? onThemeChanged;
  final ThemeMode? currentThemeMode;
  final String? csvPath;
  final void Function(String)? onCsvPathChanged;
  final Future<void> Function()? onReloadInventory;

  const SettingsScreen({super.key, 
    this.onThemeChanged,
    this.currentThemeMode,
    this.csvPath,
    this.onCsvPathChanged,
    this.onReloadInventory,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _selectedTheme;
  String? _csvPath;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentThemeMode ?? ThemeMode.system;
    _csvPath = widget.csvPath;
  }

  void _changeTheme(ThemeMode? mode) {
    if (mode != null) {
      setState(() {
        _selectedTheme = mode;
      });
      if (widget.onThemeChanged != null) {
        widget.onThemeChanged!(mode);
      }
    }
  }

  Future<void> _pickCsvFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select Inventory CSV File',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null && result.files.single.path != null) {
      String path = result.files.single.path!;
      if (widget.onCsvPathChanged != null) {
        widget.onCsvPathChanged!(path);
      }
      setState(() {
        _csvPath = path;
      });
      if (widget.onReloadInventory != null) {
        await widget.onReloadInventory!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About'),
            subtitle: Text('Lofty Inventory App\nVersion 1.0.0'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Theme'),
            subtitle: Text('Choose app appearance'),
          ),
          RadioListTile<ThemeMode>(
            title: Text('Device Theme'),
            value: ThemeMode.system,
            groupValue: _selectedTheme,
            onChanged: _changeTheme,
          ),
          RadioListTile<ThemeMode>(
            title: Text('Light'),
            value: ThemeMode.light,
            groupValue: _selectedTheme,
            onChanged: _changeTheme,
          ),
          RadioListTile<ThemeMode>(
            title: Text('Dark'),
            value: ThemeMode.dark,
            groupValue: _selectedTheme,
            onChanged: _changeTheme,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.folder),
            title: Text('Inventory File Location'),
            subtitle: Text(_csvPath ?? 'Not set'),
            trailing: ElevatedButton(
              onPressed: _pickCsvFile,
              child: Text('Change'),
            ),
          ),
        ],
      ),
    );
  }
}
