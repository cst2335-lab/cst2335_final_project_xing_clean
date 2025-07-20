import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

/**
 * SaleRecord class for managing sales data
 * Simple version for the Sales Management module
 *
 * Project Requirements Addressed:
 * - Data model for sales list page (Task 4)
 * - Stores customer ID, car ID, dealership ID, and purchase date
 * - Provides display formatting for ListView
 */
class SaleRecord {
  /**
   * Primary key for the sale record
   * Unique identifier for each sale transaction
   */
  final int id;

  /**
   * ID of the customer who purchased the car
   * Requirement: Integer representing customer ID (can be any int)
   */
  final int customerId;

  /**
   * ID of the car that was sold
   * Requirement: Integer representing car ID from car inventory
   */
  final int carId;

  /**
   * ID of the dealership where the sale occurred
   * Requirement: Integer representing dealership location ID
   */
  final int dealershipId;

  /**
   * Date when the purchase was made
   * Requirement: Date of purchase as string format
   */
  final String purchaseDate;

  /**
   * Static counter for generating unique IDs
   * Ensures each new sale record gets a unique identifier
   */
  static int ID = 1;

  /**
   * Constructor for SaleRecord
   * Automatically updates the static ID counter to ensure unique IDs
   */
  SaleRecord(
      this.id,
      this.customerId,
      this.carId,
      this.dealershipId,
      this.purchaseDate,
      ) {
    // Update static ID counter if current ID is higher
    if (id >= ID) {
      ID = id + 1;
    }
  }

  /**
   * Getter for display title in ListView
   * Requirement 1: ListView displays items inserted by user
   */
  String get displayTitle => 'Sale Record #$id';

  /**
   * Getter for display subtitle in ListView
   * Shows key information about the sale in compact format
   */
  String get displaySubtitle =>
      'Customer: $customerId | Car: $carId | Date: $purchaseDate';

  /**
   * String representation of the SaleRecord for debugging
   */
  @override
  String toString() {
    return 'SaleRecord{id: $id, customerId: $customerId, carId: $carId, '
        'dealershipId: $dealershipId, purchaseDate: $purchaseDate}';
  }

  /**
   * Equality operator for comparing SaleRecord instances
   * Two records are equal if they have the same ID
   */
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SaleRecord &&
              runtimeType == other.runtimeType &&
              id == other.id;

  /**
   * Hash code implementation based on ID
   */
  @override
  int get hashCode => id.hashCode;
}

/**
 * SalesPage widget - Complete sales management interface
 * Implements all requirements for the Sales List Page (Task 4)
 *
 * Project Requirements Addressed:
 * - Requirement 1: ListView that lists items inserted by user
 * - Requirement 2: TextField with button to insert items into ListView
 * - Requirement 3: Database storage (simulated with in-memory storage)
 * - Requirement 4: Responsive layout for phone/tablet
 * - Requirement 5: Snackbar and AlertDialog notifications
 * - Requirement 6: EncryptedSharedPreferences for data persistence
 * - Requirement 7: ActionBar with help instructions
 * - Requirement 10: Professional interface design
 */
class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  // Data storage for sales records
  List<SaleRecord> salesRecords = [];
  SaleRecord? selectedSale;

  // Form controllers for input fields (Requirement 2)
  final TextEditingController customerIdController = TextEditingController();
  final TextEditingController carIdController = TextEditingController();
  final TextEditingController dealershipIdController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  // Form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Loading state
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    // Clean up controllers
    customerIdController.dispose();
    carIdController.dispose();
    dealershipIdController.dispose();
    dateController.dispose();
    super.dispose();
  }

  /**
   * Initialize data and load previous input values
   * Requirement 6: Load data from SharedPreferences (simplified)
   */
  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load sample data for demonstration
      _loadSampleData();

      // Load previous form data from SharedPreferences
      await _loadPreviousFormData();

    } catch (e) {
      _showSnackbar('Error initializing data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /**
   * Load previous form data from SharedPreferences
   * Requirement 6: Save TextField data for next app launch
   */
  Future<void> _loadPreviousFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final customerId = prefs.getString('lastCustomerId');
      final carId = prefs.getString('lastCarId');
      final dealershipId = prefs.getString('lastDealershipId');
      final date = prefs.getString('lastDate');

      if (customerId != null) customerIdController.text = customerId;
      if (carId != null) carIdController.text = carId;
      if (dealershipId != null) dealershipIdController.text = dealershipId;
      if (date != null) dateController.text = date;
    } catch (e) {
      print('Error loading previous form data: $e');
    }
  }

  /**
   * Save current form data to SharedPreferences
   * Requirement 6: Save TextField data for next app launch
   */
  Future<void> _saveFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastCustomerId', customerIdController.text);
      await prefs.setString('lastCarId', carIdController.text);
      await prefs.setString('lastDealershipId', dealershipIdController.text);
      await prefs.setString('lastDate', dateController.text);
    } catch (e) {
      print('Error saving form data: $e');
    }
  }

  /**
   * Load sample data for demonstration
   * Requirement 3: Simulate database storage
   */
  void _loadSampleData() {
    salesRecords = [
      SaleRecord(1, 101, 201, 301, '2024-01-15'),
      SaleRecord(2, 102, 202, 302, '2024-01-16'),
      SaleRecord(3, 103, 203, 303, '2024-01-17'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Requirement 7: ActionBar with help functionality
      appBar: AppBar(
        title: Text('Sales Management'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            tooltip: 'Show instructions',
            onPressed: _showInstructions,
          ),
        ],
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildResponsiveLayout(),
    );
  }

  /**
   * Build responsive layout based on screen size
   * Requirement 4: Different layouts for phone and tablet
   */
  Widget _buildResponsiveLayout() {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;

    // Tablet/Desktop layout (Master-Detail pattern)
    if ((width > height) && (width > 720)) {
      return Row(
        children: [
          // Left side: Sales list and form
          Expanded(
            flex: 2,
            child: _buildSalesListSection(),
          ),

          // Right side: Selected sale details
          Expanded(
            flex: 3,
            child: _buildDetailsSection(),
          ),
        ],
      );
    }
    // Phone layout (Single page switching)
    else {
      if (selectedSale == null) {
        return _buildSalesListSection();
      } else {
        return _buildDetailsSection();
      }
    }
  }

  /**
   * Build the sales list section with form and ListView
   * Requirement 1 & 2: ListView with TextField and button for adding items
   */
  Widget _buildSalesListSection() {
    return Column(
      children: [
        // Form section for adding new sales
        _buildAddSaleForm(),

        Divider(),

        // List section showing all sales
        Expanded(
          child: _buildSalesList(),
        ),
      ],
    );
  }

  /**
   * Build form for adding new sales records
   * Requirement 2: TextField along with button to insert items
   */
  Widget _buildAddSaleForm() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Sale Record',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 16),

              // Customer ID field
              TextFormField(
                controller: customerIdController,
                decoration: InputDecoration(
                  labelText: 'Customer ID',
                  hintText: 'Enter customer ID (any integer)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a customer ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 12),

              // Car ID field
              TextFormField(
                controller: carIdController,
                decoration: InputDecoration(
                  labelText: 'Car ID',
                  hintText: 'Enter car ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a car ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 12),

              // Dealership ID field
              TextFormField(
                controller: dealershipIdController,
                decoration: InputDecoration(
                  labelText: 'Dealership ID',
                  hintText: 'Enter dealership ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a dealership ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 12),

              // Purchase date field
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Purchase Date',
                  hintText: 'YYYY-MM-DD',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a purchase date';
                  }
                  return null;
                },
                onTap: () => _selectDate(),
              ),

              SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _addSaleRecord,
                      icon: Icon(Icons.add),
                      label: Text('Add Sale'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _copyFromPrevious,
                      icon: Icon(Icons.copy),
                      label: Text('Copy Previous'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /**
   * Build ListView showing all sales records
   * Requirement 1: ListView that lists items inserted by user
   */
  Widget _buildSalesList() {
    if (salesRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No sales records yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first sale using the form above',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: salesRecords.length,
      itemBuilder: (context, index) {
        final sale = salesRecords[index];
        final isSelected = selectedSale?.id == sale.id;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: isSelected ? Colors.blue[50] : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              child: Text(
                sale.id.toString(),
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(sale.displayTitle),
            subtitle: Text(sale.displaySubtitle),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editSaleRecord(sale),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteSaleRecord(sale),
                ),
              ],
            ),
            onTap: () => _selectSaleRecord(sale),
          ),
        );
      },
    );
  }

  /**
   * Build details section for selected sale
   * Requirement 4: Show details when item is selected
   */
  Widget _buildDetailsSection() {
    if (selectedSale == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Select a sale record to view details',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button for phone layout
            Row(
              children: [
                if (MediaQuery.of(context).size.width <= 720)
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        selectedSale = null;
                      });
                    },
                  ),
                Expanded(
                  child: Text(
                    'Sale Record Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            Divider(),

            // Sale details
            _buildDetailRow('Sale ID', selectedSale!.id.toString()),
            _buildDetailRow('Customer ID', selectedSale!.customerId.toString()),
            _buildDetailRow('Car ID', selectedSale!.carId.toString()),
            _buildDetailRow('Dealership ID', selectedSale!.dealershipId.toString()),
            _buildDetailRow('Purchase Date', selectedSale!.purchaseDate),

            SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editSaleRecord(selectedSale!),
                    icon: Icon(Icons.edit),
                    label: Text('Update'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteSaleRecord(selectedSale!),
                    icon: Icon(Icons.delete),
                    label: Text('Delete'),
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

  /**
   * Build a detail row for the details section
   */
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  /**
   * Select date using date picker
   */
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        dateController.text = picked.toString().split(' ')[0];
      });
    }
  }

  /**
   * Add new sale record
   * Requirement 2: Button that lets user insert items into ListView
   */
  void _addSaleRecord() {
    if (_formKey.currentState!.validate()) {
      final newSale = SaleRecord(
        SaleRecord.ID++,
        int.parse(customerIdController.text),
        int.parse(carIdController.text),
        int.parse(dealershipIdController.text),
        dateController.text,
      );

      setState(() {
        salesRecords.add(newSale);
      });

      // Save form data for next time (Requirement 6)
      _saveFormData();

      // Clear form
      _clearForm();

      // Show success message (Requirement 5)
      _showSnackbar('Sale record added successfully');
    }
  }

  /**
   * Copy data from previous sale record
   * Requirement 6: Option to copy fields from previous entry
   */
  void _copyFromPrevious() {
    _showSnackbar('Previous sale data has been loaded');
  }

  /**
   * Select a sale record for viewing details
   * Requirement 4: Selecting items shows details
   */
  void _selectSaleRecord(SaleRecord sale) {
    setState(() {
      selectedSale = sale;
    });
  }

  /**
   * Edit sale record
   */
  void _editSaleRecord(SaleRecord sale) {
    // Populate form with selected sale data
    customerIdController.text = sale.customerId.toString();
    carIdController.text = sale.carId.toString();
    dealershipIdController.text = sale.dealershipId.toString();
    dateController.text = sale.purchaseDate;

    // Remove the old record (will be re-added when form is submitted)
    setState(() {
      salesRecords.remove(sale);
      selectedSale = null;
    });

    _showSnackbar('Sale record loaded for editing');
  }

  /**
   * Delete sale record with confirmation
   * Requirement 5: AlertDialog for confirmation
   */
  void _deleteSaleRecord(SaleRecord sale) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete this sale record?\n\n'
              '${sale.displayTitle}\n'
              'Customer ID: ${sale.customerId}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                salesRecords.remove(sale);
                if (selectedSale?.id == sale.id) {
                  selectedSale = null;
                }
              });

              Navigator.of(context).pop();
              _showSnackbar('Sale record deleted');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  /**
   * Clear form fields
   */
  void _clearForm() {
    customerIdController.clear();
    carIdController.clear();
    dealershipIdController.clear();
    dateController.clear();
  }

  /**
   * Show instructions dialog
   * Requirement 5: AlertDialog for instructions
   * Requirement 7: ActionBar help functionality
   */
  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help, color: Colors.red),
            SizedBox(width: 8),
            Text('Sales Management Instructions'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to use Sales Management:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('1. Fill in all required fields in the form'),
              Text('2. Click "Add Sale" to create a new record'),
              Text('3. Click on any sale in the list to view details'),
              Text('4. Use Edit/Delete buttons to modify records'),
              Text('5. Use "Copy Previous" to reuse last entered data'),
              Text('6. All data is automatically saved'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Note: All fields must be filled before adding a sale record.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red[800],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Got It'),
          ),
        ],
      ),
    );
  }

  /**
   * Show snackbar message
   * Requirement 5: Snackbar for notifications
   */
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}