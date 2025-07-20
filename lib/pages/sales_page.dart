// lib/pages/sales_page.dart
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../models/sale_record.dart';
import '../database/app_database.dart';

/// Sales Page Widget - Main sales management interface
///
/// Project Requirements Addressed:
/// * ListView that lists items inserted by user
/// * TextField + Button to insert items into ListView
/// * Database storage using Floor SQLite for persistence
/// * Selecting items shows details (responsive layout)
/// * Snackbar and AlertDialog notifications
/// * EncryptedSharedPreferences for TextField data
/// * ActionBar with help instructions
/// * Professional interface layout
///
/// Responsive Design:
/// * Phone: Full-screen list, then full-screen details
/// * Tablet/Desktop: List on left, details on right
class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  // Database and data management
  AppDatabase? _database;
  List<SaleRecord> _saleRecords = [];
  SaleRecord? _selectedRecord;

  // Form controllers for adding new records
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _carIdController = TextEditingController();
  final TextEditingController _dealershipIdController = TextEditingController();
  final TextEditingController _purchaseDateController = TextEditingController();

  // Encrypted shared preferences for data persistence
  late EncryptedSharedPreferences _encryptedPrefs;

  // UI state management
  bool _isLoading = true;
  String _errorMessage = '';

  /// Initialize state and load data when widget is created
  /// Sets up database connection and loads existing records
  @override
  void initState() {
    super.initState();
    _initializeEncryptedPreferences();
    _initializeDatabase();
    _loadSavedFormData();
  }

  /// Clean up resources when widget is disposed
  /// Properly dispose of text controllers and close database
  @override
  void dispose() {
    _customerIdController.dispose();
    _carIdController.dispose();
    _dealershipIdController.dispose();
    _purchaseDateController.dispose();
    _database?.closeDatabase();
    super.dispose();
  }

  /// Initialize encrypted shared preferences for secure data storage
  /// Requirement 6: EncryptedSharedPreferences to save TextField data
  void _initializeEncryptedPreferences() {
    _encryptedPrefs = EncryptedSharedPreferences();
  }

  /// Initialize Floor database connection
  /// Requirement 3: Database storage for ListView items
  Future<void> _initializeDatabase() async {
    try {
      _database = await AppDatabase.createDatabase();
      await _loadSaleRecordsFromDatabase();

      setState(() {
        _isLoading = false;
      });

      // Show success message
      _showSnackbar('Database initialized successfully');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize database: $e';
      });
    }
  }

  /// Load all sale records from database
  /// Requirement 1: ListView displays items inserted by user
  Future<void> _loadSaleRecordsFromDatabase() async {
    if (_database == null) return;

    try {
      final records = await _database!.saleRecordDao.findAllSaleRecords();
      setState(() {
        _saleRecords = records;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load records: $e';
      });
      _showSnackbar('Error loading sales records');
    }
  }

  /// Load previously saved form data from encrypted preferences
  /// Requirement 6: Use EncryptedSharedPreferences to save TextField content
  Future<void> _loadSavedFormData() async {
    try {
      final savedCustomerId = await _encryptedPrefs.getString('last_customer_id');
      final savedCarId = await _encryptedPrefs.getString('last_car_id');
      final savedDealershipId = await _encryptedPrefs.getString('last_dealership_id');
      final savedPurchaseDate = await _encryptedPrefs.getString('last_purchase_date');

      setState(() {
        _customerIdController.text = savedCustomerId ?? '';
        _carIdController.text = savedCarId ?? '';
        _dealershipIdController.text = savedDealershipId ?? '';
        _purchaseDateController.text = savedPurchaseDate ?? _getCurrentDate();
      });
    } catch (e) {
      // If no saved data or error, set default date
      _purchaseDateController.text = _getCurrentDate();
    }
  }

  /// Save current form data to encrypted preferences
  /// Requirement 6: Save TextField data for next application launch
  Future<void> _saveFormDataToPreferences() async {
    try {
      await _encryptedPrefs.setString('last_customer_id', _customerIdController.text);
      await _encryptedPrefs.setString('last_car_id', _carIdController.text);
      await _encryptedPrefs.setString('last_dealership_id', _dealershipIdController.text);
      await _encryptedPrefs.setString('last_purchase_date', _purchaseDateController.text);
    } catch (e) {
      print('Error saving form data: $e');
    }
  }

  /// Get current date in YYYY-MM-DD format
  /// Helper method for default date values
  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Add new sale record to database
  /// Requirement 2: TextField + Button to insert items into ListView
  Future<void> _addSaleRecord() async {
    // Validate form inputs
    if (!_validateFormInputs()) {
      return;
    }

    try {
      // Create new sale record
      final newRecord = SaleRecord.create(
        customerId: int.parse(_customerIdController.text),
        carId: int.parse(_carIdController.text),
        dealershipId: int.parse(_dealershipIdController.text),
        purchaseDate: _purchaseDateController.text,
      );

      // Save to database
      await _database!.saleRecordDao.insertSaleRecord(newRecord);

      // Save form data to preferences
      await _saveFormDataToPreferences();

      // Reload data from database
      await _loadSaleRecordsFromDatabase();

      // Clear form (except date)
      _clearForm();

      // Show success message
      _showSnackbar('Sale record added successfully');

    } catch (e) {
      _showSnackbar('Error adding sale record: $e');
    }
  }

  /// Validate form inputs before saving
  /// Ensures all required fields have valid values
  bool _validateFormInputs() {
    // Check if any field is empty
    if (_customerIdController.text.isEmpty ||
        _carIdController.text.isEmpty ||
        _dealershipIdController.text.isEmpty ||
        _purchaseDateController.text.isEmpty) {
      _showAlertDialog(
        'Validation Error',
        'All fields are required. Please fill in all fields before adding a sale record.',
      );
      return false;
    }

    // Validate customer ID
    final customerId = int.tryParse(_customerIdController.text);
    if (customerId == null || customerId <= 0) {
      _showAlertDialog(
        'Invalid Customer ID',
        'Customer ID must be a positive integer.',
      );
      return false;
    }

    // Validate car ID
    final carId = int.tryParse(_carIdController.text);
    if (carId == null || carId <= 0) {
      _showAlertDialog(
        'Invalid Car ID',
        'Car ID must be a positive integer.',
      );
      return false;
    }

    // Validate dealership ID
    final dealershipId = int.tryParse(_dealershipIdController.text);
    if (dealershipId == null || dealershipId <= 0) {
      _showAlertDialog(
        'Invalid Dealership ID',
        'Dealership ID must be a positive integer.',
      );
      return false;
    }

    // Validate date format (basic check)
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(_purchaseDateController.text)) {
      _showAlertDialog(
        'Invalid Date Format',
        'Purchase date must be in YYYY-MM-DD format.',
      );
      return false;
    }

    return true;
  }

  /// Clear form fields after successful submission
  /// Keeps date field for convenience
  void _clearForm() {
    _customerIdController.clear();
    _carIdController.clear();
    _dealershipIdController.clear();
    // Keep the date for convenience
  }

  /// Delete selected sale record from database
  /// Shows confirmation dialog before deletion
  Future<void> _deleteSaleRecord(SaleRecord record) async {
    // Show confirmation dialog
    final shouldDelete = await _showConfirmationDialog(
      'Delete Sale Record',
      'Are you sure you want to delete this sale record? This action cannot be undone.',
    );

    if (shouldDelete) {
      try {
        await _database!.saleRecordDao.deleteSaleRecord(record);
        await _loadSaleRecordsFromDatabase();

        // Clear selection if deleted record was selected
        if (_selectedRecord?.id == record.id) {
          setState(() {
            _selectedRecord = null;
          });
        }

        _showSnackbar('Sale record deleted successfully');
      } catch (e) {
        _showSnackbar('Error deleting sale record: $e');
      }
    }
  }

  /// Select a sale record to show details
  /// Requirement 4: Selecting items shows details
  void _selectSaleRecord(SaleRecord record) {
    setState(() {
      _selectedRecord = record;
    });
  }

  /// Clear current selection
  /// Used for navigation back to list on phone
  void _clearSelection() {
    setState(() {
      _selectedRecord = null;
    });
  }

  /// Show snackbar notification
  /// Requirement 5: Each activity must have at least 1 Snackbar
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show alert dialog notification
  /// Requirement 5: Each activity must have at least 1 AlertDialog
  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Show confirmation dialog with Yes/No options
  /// Used for delete confirmations
  Future<bool> _showConfirmationDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// Show help instructions dialog
  /// Requirement 7: ActionBar with ActionItems showing usage instructions
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('How to Use Sales Page'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Adding Sales Records:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('1. Fill in Customer ID, Car ID, and Dealership ID'),
                Text('2. Enter purchase date in YYYY-MM-DD format'),
                Text('3. Tap "Add Sale Record" button'),
                SizedBox(height: 16),
                Text(
                  'Viewing Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('• Tap any sale record to view details'),
                Text('• On tablets: details appear on the right'),
                Text('• On phones: details appear full screen'),
                SizedBox(height: 16),
                Text(
                  'Managing Records:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('• Tap delete button (🗑️) to remove records'),
                Text('• All data is automatically saved to database'),
                Text('• Form data is remembered between app launches'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Got it!'),
            ),
          ],
        );
      },
    );
  }

  /// Build form for adding new sale records
  /// Requirement 2: TextField + Button for user input
  Widget _buildAddRecordForm() {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Sale Record',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _customerIdController,
              decoration: InputDecoration(
                labelText: 'Customer ID',
                hintText: 'Enter customer ID (integer)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _carIdController,
              decoration: InputDecoration(
                labelText: 'Car ID',
                hintText: 'Enter car ID (integer)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _dealershipIdController,
              decoration: InputDecoration(
                labelText: 'Dealership ID',
                hintText: 'Enter dealership ID (integer)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _purchaseDateController,
              decoration: InputDecoration(
                labelText: 'Purchase Date',
                hintText: 'YYYY-MM-DD format',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  _purchaseDateController.text =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                }
              },
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addSaleRecord,
                child: Text('Add Sale Record'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build list view of sale records
  /// Requirement 1: ListView that lists items inserted by user
  Widget _buildSaleRecordsList() {
    if (_saleRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No sale records found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first sale record using the form above',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _saleRecords.length,
      itemBuilder: (context, index) {
        final record = _saleRecords[index];
        final isSelected = _selectedRecord?.id == record.id;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${record.id ?? 'N'}'),
              backgroundColor: isSelected ? Colors.blue : Colors.grey,
              foregroundColor: Colors.white,
            ),
            title: Text(record.displayTitle),
            subtitle: Text(record.displaySubtitle),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteSaleRecord(record),
              tooltip: 'Delete this sale record',
            ),
            onTap: () => _selectSaleRecord(record),
          ),
        );
      },
    );
  }

  /// Build detail view for selected sale record
  /// Requirement 4: Show details when item is selected
  Widget _buildSaleRecordDetails() {
    if (_selectedRecord == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Select a sale record to view details',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sale Record Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                // Show back button on phone layout
                if (MediaQuery.of(context).size.width <= 720)
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: _clearSelection,
                    tooltip: 'Back to list',
                  ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              _selectedRecord!.detailInfo,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _deleteSaleRecord(_selectedRecord!),
                    child: Text('Delete Record'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build responsive layout based on screen size
  /// Requirement 4: Phone uses whole screen, Tablet shows details beside ListView
  Widget _buildResponsiveLayout() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 720 && screenWidth > screenHeight;

    if (isTablet) {
      // Tablet layout: List on left, details on right
      return Row(
        children: [
          // Left side: Form and List
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildAddRecordForm(),
                Expanded(child: _buildSaleRecordsList()),
              ],
            ),
          ),
          // Right side: Details
          Expanded(
            flex: 2,
            child: _buildSaleRecordDetails(),
          ),
        ],
      );
    } else {
      // Phone layout: Full screen
      if (_selectedRecord != null) {
        // Show details full screen
        return _buildSaleRecordDetails();
      } else {
        // Show form and list
        return Column(
          children: [
            _buildAddRecordForm(),
            Expanded(child: _buildSaleRecordsList()),
          ],
        );
      }
    }
  }

  /// Build main widget
  /// Requirement 10: Professional interface layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Requirement 7: ActionBar with ActionItems showing help
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Show usage instructions',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadSaleRecordsFromDatabase,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading sales data...'),
          ],
        ),
      )
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error: $_errorMessage',
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = '';
                  _isLoading = true;
                });
                _initializeDatabase();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      )
          : _buildResponsiveLayout(),
    );
  }
}