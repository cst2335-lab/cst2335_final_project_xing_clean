/// Sales Page Widget - English/French Language Support
///
/// Project Requirements Addressed:
/// * Requirement 8: Multi-language support with English and French
/// * Clean and simple interface design
/// * Clear language switching demonstration
library;

import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../database/app_database.dart';
import '../models/sale_record.dart';

/// Main Sales Page with English/French language switching
///
/// Provides a clean interface for sales record management with
/// bilingual support for better requirement demonstration
class SalesPage extends StatefulWidget {
  /// Creates a new SalesPage widget
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

/// State class for SalesPage with English/French switching
///
/// Manages language preference between English and French
/// for clear multilingual demonstration
class _SalesPageState extends State<SalesPage> {
  /// Current language setting - true for French, false for English
  bool _isFrench = false;

  /// List of sale records loaded from database
  List<SaleRecord> _salesRecords = [];

  /// Currently selected sale record for details view
  SaleRecord? _selectedSaleRecord;

  /// Loading state indicator
  bool _isLoading = true;

  /// Form controllers for user input
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _carIdController = TextEditingController();
  final TextEditingController _dealershipIdController = TextEditingController();
  final TextEditingController _purchaseDateController = TextEditingController();

  /// Database instance for data persistence
  AppDatabase? _database;

  /// Encrypted preferences for form data storage
  EncryptedSharedPreferences? _encryptedPrefs;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// Initialize database and load saved form data
  ///
  /// Sets up database connection and retrieves previously saved form values
  /// from encrypted shared preferences for user convenience
  Future<void> _initializeData() async {
    try {
      print('🔧 Step 1: Initializing EncryptedSharedPreferences...');
      _encryptedPrefs = EncryptedSharedPreferences();

      print('🔧 Step 2: Creating database connection...');
      _database = await $FloorAppDatabase
          .databaseBuilder('sales_database.db')
          .build();

      print('🔧 Step 3: Loading form data from preferences...');
      await _loadFormData();

      print('🔧 Step 4: Loading sales records from database...');
      await _loadSalesRecords();

      print('✅ Database initialization completed successfully');
    } catch (e, stackTrace) {
      print('❌ Error during initialization: $e');
      print('📍 Stack trace: $stackTrace');

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText('Database initialization failed', 'Échec de l\'initialisation de la base de données')),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: _getText('Retry', 'Réessayer'),
              textColor: Colors.white,
              onPressed: _initializeData,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Get localized text based on current language setting
  ///
  /// [english] Text to show for English
  /// [french] Text to show for French
  /// Returns: Appropriate text based on _isFrench flag
  String _getText(String english, String french) {
    return _isFrench ? french : english;
  }

  /// Load form data from encrypted shared preferences
  ///
  /// Retrieves previously saved form field values to provide
  /// better user experience across app sessions
  Future<void> _loadFormData() async {
    try {
      final customerId = await _encryptedPrefs?.getString('last_customer_id');
      final carId = await _encryptedPrefs?.getString('last_car_id');
      final dealershipId = await _encryptedPrefs?.getString('last_dealership_id');

      if (mounted) {
        setState(() {
          _customerIdController.text = customerId ?? '';
          _carIdController.text = carId ?? '';
          _dealershipIdController.text = dealershipId ?? '';
        });
      }
    } catch (e) {
      print('⚠️ Warning: Could not load form data: $e');
    }
  }

  /// Load all sales records from database
  ///
  /// Fetches complete list of sales records and updates UI state
  /// Handles database errors gracefully with user feedback
  Future<void> _loadSalesRecords() async {
    try {
      if (_database != null) {
        final records = await _database!.saleRecordDao.findAllSaleRecords();
        if (mounted) {
          setState(() {
            _salesRecords = records;
          });
        }
        print('✅ Loaded ${records.length} sales records from database');
      }
    } catch (e) {
      print('❌ Error loading sales records: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText('Failed to load sales records', 'Échec du chargement des enregistrements de vente')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Add new sale record to database
  ///
  /// Validates form data, creates new SaleRecord instance,
  /// saves to database and updates UI with success feedback
  Future<void> _addSaleRecord() async {
    // Validate form input
    if (!_validateForm()) {
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
      await _saveFormData();

      // Reload records and clear form
      await _loadSalesRecords();
      _clearForm();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText(
                'Sale record added successfully!',
                'Enregistrement de vente ajouté avec succès!'
            )),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error adding sale record: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText(
                'Error adding sale record',
                'Erreur lors de l\'ajout de l\'enregistrement'
            )),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Save current form data to encrypted preferences
  ///
  /// Stores form field values for retrieval in future sessions
  /// Requirement 6: EncryptedSharedPreferences usage
  Future<void> _saveFormData() async {
    try {
      await _encryptedPrefs?.setString('last_customer_id', _customerIdController.text);
      await _encryptedPrefs?.setString('last_car_id', _carIdController.text);
      await _encryptedPrefs?.setString('last_dealership_id', _dealershipIdController.text);
      print('✅ Form data saved to encrypted preferences');
    } catch (e) {
      print('⚠️ Warning: Could not save form data: $e');
    }
  }

  /// Validate form input fields
  ///
  /// Returns: true if all fields are valid, false otherwise
  /// Shows appropriate error messages for invalid input
  bool _validateForm() {
    if (_customerIdController.text.isEmpty) {
      _showValidationError(_getText('Customer ID is required', 'L\'ID client est requis'));
      return false;
    }

    if (_carIdController.text.isEmpty) {
      _showValidationError(_getText('Car ID is required', 'L\'ID de la voiture est requis'));
      return false;
    }

    if (_dealershipIdController.text.isEmpty) {
      _showValidationError(_getText('Dealership ID is required', 'L\'ID du concessionnaire est requis'));
      return false;
    }

    if (_purchaseDateController.text.isEmpty) {
      _showValidationError(_getText('Purchase date is required', 'La date d\'achat est requise'));
      return false;
    }

    // Validate numeric fields
    if (int.tryParse(_customerIdController.text) == null) {
      _showValidationError(_getText('Invalid Customer ID format', 'Format d\'ID client invalide'));
      return false;
    }

    if (int.tryParse(_carIdController.text) == null) {
      _showValidationError(_getText('Invalid Car ID format', 'Format d\'ID de voiture invalide'));
      return false;
    }

    if (int.tryParse(_dealershipIdController.text) == null) {
      _showValidationError(_getText('Invalid Dealership ID format', 'Format d\'ID de concessionnaire invalide'));
      return false;
    }

    return true;
  }

  /// Show validation error message
  ///
  /// [message] Error message to display to user
  /// Requirement 5: AlertDialog for notifications
  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_getText('Validation Error', 'Erreur de validation')),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_getText('OK', 'OK')),
            ),
          ],
        );
      },
    );
  }

  /// Clear all form fields
  ///
  /// Resets form to empty state for new record entry
  void _clearForm() {
    _customerIdController.clear();
    _carIdController.clear();
    _dealershipIdController.clear();
    _purchaseDateController.clear();
  }

  /// Delete sale record from database
  ///
  /// [record] SaleRecord to delete
  /// Shows confirmation dialog before deletion
  Future<void> _deleteSaleRecord(SaleRecord record) async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_getText('Confirm Deletion', 'Confirmer la suppression')),
          content: Text(_getText(
              'Are you sure you want to delete this sale record?',
              'Êtes-vous sûr de vouloir supprimer cet enregistrement de vente?'
          )),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_getText('Cancel', 'Annuler')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_getText('Delete', 'Supprimer')),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _database!.saleRecordDao.deleteSaleRecord(record);
        await _loadSalesRecords();

        // Clear selection if deleted record was selected
        if (_selectedSaleRecord?.id == record.id) {
          setState(() {
            _selectedSaleRecord = null;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getText(
                  'Sale record deleted successfully',
                  'Enregistrement de vente supprimé avec succès'
              )),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        print('❌ Error deleting sale record: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getText(
                  'Error deleting sale record',
                  'Erreur lors de la suppression de l\'enregistrement'
              )),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Switch between English and French
  ///
  /// Updates language preference and rebuilds UI with new text
  /// Provides clear demonstration of Requirement 8 compliance
  void _switchLanguage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_getText('Choose Language', 'Choisir la langue')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_getText(
                  'Select your preferred language:',
                  'Sélectionnez votre langue préférée:'
              )),
              const SizedBox(height: 16),
              // Show current language
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getText('Current: English 🇬🇧', 'Actuel: Français 🇫🇷'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isFrench = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🇬🇧 Switched to English'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('🇬🇧 English'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isFrench = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🇫🇷 Basculé vers le français'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('🇫🇷 Français'),
            ),
          ],
        );
      },
    );
  }

  /// Show help dialog with application usage instructions
  ///
  /// Requirement 7: ActionBar with ActionItems showing usage instructions
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_getText('Sales Management Help', 'Aide à la gestion des ventes')),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getText('How to use this interface:', 'Comment utiliser cette interface:'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Text('1. ${_getText('Fill in the form fields', 'Remplissez les champs du formulaire')}'),
                const SizedBox(height: 8),
                Text('2. ${_getText('Enter the purchase date', 'Entrez la date d\'achat')}'),
                const SizedBox(height: 8),
                Text('3. ${_getText('Click "Add Sale Record"', 'Cliquez sur "Ajouter un enregistrement"')}'),
                const SizedBox(height: 8),
                Text('4. ${_getText('Tap any record to view details', 'Appuyez sur un enregistrement pour voir les détails')}'),
                const SizedBox(height: 8),
                Text('5. ${_getText('Use delete button to remove records', 'Utilisez le bouton supprimer pour enlever des enregistrements')}'),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getText(
                        '🌐 Language Feature: This app supports English and French. Use the 🌐 button to switch languages.',
                        '🌐 Fonction de langue: Cette application prend en charge l\'anglais et le français. Utilisez le bouton 🌐 pour changer de langue.'
                    ),
                    style: TextStyle(
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_getText('Got it!', 'Compris!')),
            ),
          ],
        );
      },
    );
  }

  /// Select date using date picker
  ///
  /// Opens native date picker and updates purchase date field
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _purchaseDateController.text = picked.toString().split(' ')[0];
      });
    }
  }

  /// Build responsive layout based on screen size
  ///
  /// Returns appropriate widget based on device orientation and size
  /// Requirement 4: Master-detail pattern for tablet vs phone layouts
  Widget _buildResponsiveLayout() {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 720 && size.width > size.height;

    if (isTablet) {
      // Tablet layout: List and form on left, details on right
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildListAndForm(),
          ),
          Expanded(
            flex: 1,
            child: _buildDetailsPanel(),
          ),
        ],
      );
    } else {
      // Phone layout: Full screen list/form or details
      if (_selectedSaleRecord != null) {
        return _buildDetailsPanel();
      } else {
        return _buildListAndForm();
      }
    }
  }

  /// Build list and form section
  ///
  /// Contains the main sales records list and add record form
  Widget _buildListAndForm() {
    return Column(
      children: [
        // Add Record Form
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getText('Add New Sale Record', 'Ajouter un nouvel enregistrement de vente'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _customerIdController,
                decoration: InputDecoration(
                  labelText: _getText('Customer ID', 'ID Client'),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _carIdController,
                decoration: InputDecoration(
                  labelText: _getText('Car ID', 'ID Voiture'),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dealershipIdController,
                decoration: InputDecoration(
                  labelText: _getText('Dealership ID', 'ID Concessionnaire'),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _purchaseDateController,
                decoration: InputDecoration(
                  labelText: _getText('Purchase Date', 'Date d\'achat'),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ),
                readOnly: true,
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addSaleRecord,
                      child: Text(_getText('Add Sale Record', 'Ajouter un enregistrement')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _clearForm,
                    child: Text(_getText('Clear', 'Effacer')),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Records List
        Expanded(
          child: _salesRecords.isEmpty
              ? Center(
            child: Text(
              _getText('No sale records found', 'Aucun enregistrement de vente trouvé'),
              style: const TextStyle(fontSize: 16),
            ),
          )
              : ListView.builder(
            itemCount: _salesRecords.length,
            itemBuilder: (context, index) {
              final record = _salesRecords[index];
              return ListTile(
                title: Text(_getText(
                    'Customer ${record.customerId} - Car ${record.carId}',
                    'Client ${record.customerId} - Voiture ${record.carId}'
                )),
                subtitle: Text(_getText(
                    'Dealership: ${record.dealershipId}, Date: ${record.purchaseDate}',
                    'Concessionnaire: ${record.dealershipId}, Date: ${record.purchaseDate}'
                )),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteSaleRecord(record),
                ),
                onTap: () {
                  setState(() {
                    _selectedSaleRecord = record;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build details panel for selected record
  ///
  /// Shows information about the selected sale record
  Widget _buildDetailsPanel() {
    final size = MediaQuery.of(context).size;
    final isPhone = size.width <= 720 || size.width <= size.height;

    if (_selectedSaleRecord == null) {
      return Center(
        child: Text(
          _getText('Select a sale record to view details', 'Sélectionnez un enregistrement pour voir les détails'),
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPhone)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedSaleRecord = null;
                    });
                  },
                ),
                Text(
                  _getText('Sale Record Details', 'Détails de l\'enregistrement'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            )
          else
            Text(
              _getText('Sale Record Details', 'Détails de l\'enregistrement'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 16),
          Text('${_getText('Record ID', 'ID Enregistrement')}: ${_selectedSaleRecord!.id}'),
          const SizedBox(height: 8),
          Text('${_getText('Customer ID', 'ID Client')}: ${_selectedSaleRecord!.customerId}'),
          const SizedBox(height: 8),
          Text('${_getText('Car ID', 'ID Voiture')}: ${_selectedSaleRecord!.carId}'),
          const SizedBox(height: 8),
          Text('${_getText('Dealership ID', 'ID Concessionnaire')}: ${_selectedSaleRecord!.dealershipId}'),
          const SizedBox(height: 8),
          Text('${_getText('Purchase Date', 'Date d\'achat')}: ${_selectedSaleRecord!.purchaseDate}'),
          const Spacer(),
          ElevatedButton(
            onPressed: () => _deleteSaleRecord(_selectedSaleRecord!),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              _getText('Delete Record', 'Supprimer l\'enregistrement'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getText('Sales Management', 'Gestion des ventes')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _switchLanguage,
            tooltip: _getText('Switch Language', 'Changer de langue'),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: _getText('Help', 'Aide'),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_getText('Loading sales data...', 'Chargement des données de vente...')),
          ],
        ),
      )
          : _buildResponsiveLayout(),
    );
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _carIdController.dispose();
    _dealershipIdController.dispose();
    _purchaseDateController.dispose();
    super.dispose();
  }
}