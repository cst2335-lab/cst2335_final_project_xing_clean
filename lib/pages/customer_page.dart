/// Customer Page Widget - English/French Language Support
/// Project Page for Customer management: Add, view, update, and delete customers.
library;

import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../database/customer_database.dart';
import '../models/customer.dart';

/// Main Customer Page with English/French language switching
///
/// Provides complete customer management functionality with
/// bilingual support
class CustomerPage extends StatefulWidget {
  /// Creates a new CustomerPage widget
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

/// State class for CustomerPage with multi-language support
///
/// Manages language preference between English and French
class _CustomerPageState extends State<CustomerPage> {
  /// Current language setting - true for French, false for English
  bool _isFrench = false;

  /// List of customers loaded from database
  List<Customer> _customers = [];

  /// Currently selected customer for details view
  Customer? _selectedCustomer;

  /// Loading state indicator
  bool _isLoading = true;

  /// Form controllers for user input
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  /// Database instance for data persistence
  CustomerDatabase? _database;

  /// Encrypted preferences for form data storage
  EncryptedSharedPreferences? _encryptedPrefs;

  /// Form mode: true for edit, false for add
  bool _isEditMode = false;

  /// Customer being edited (null for new customer)
  Customer? _editingCustomer;

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

      print('🔧 Step 2: Creating customer database connection...');
      _database = await $FloorCustomerDatabase
          .databaseBuilder('customers_database.db')
          .build();

      print('🔧 Step 3: Loading form data from preferences...');
      await _loadFormData();

      print('🔧 Step 4: Loading customers from database...');
      await _loadCustomers();

      print('✅ Customer database initialization completed successfully');
    } catch (e, stackTrace) {
      print('❌ Error during customer initialization: $e');
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
  /// Requirement 6: EncryptedSharedPreferences usage
  Future<void> _loadFormData() async {
    try {
      final firstName = await _encryptedPrefs?.getString('last_customer_first_name');
      final lastName = await _encryptedPrefs?.getString('last_customer_last_name');
      final address = await _encryptedPrefs?.getString('last_customer_address');
      final dateOfBirth = await _encryptedPrefs?.getString('last_customer_dob');

      if (mounted) {
        setState(() {
          _firstNameController.text = firstName ?? '';
          _lastNameController.text = lastName ?? '';
          _addressController.text = address ?? '';
          _dateOfBirthController.text = dateOfBirth ?? '';
        });
      }
    } catch (e) {
      print('⚠️ Warning: Could not load customer form data: $e');
    }
  }

  /// Load all customers from database
  ///
  /// Fetches complete list of customers and updates UI state
  /// Handles database errors gracefully with user feedback
  Future<void> _loadCustomers() async {
    try {
      if (_database != null) {
        final records = await _database!.customerDao.findAllCustomers();
        if (mounted) {
          setState(() {
            _customers = records;
          });
        }
        print('✅ Loaded ${records.length} customers from database');
      }
    } catch (e) {
      print('❌ Error loading customers: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText('Failed to load customers', 'Échec du chargement des clients')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Add new customer to database
  ///
  /// Validates form data, creates new Customer instance,
  /// saves to database and updates UI with success feedback
  Future<void> _addCustomer() async {
    // Validate form input
    if (!_validateForm()) {
      return;
    }

    try {
      // Check for duplicates
      final isDuplicate = await _database!.isDuplicateCustomer(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _addressController.text.trim(),
      );

      if (isDuplicate) {
        _showValidationError(_getText(
            'A customer with this name and address already exists',
            'Un client avec ce nom et cette adresse existe déjà'
        ));
        return;
      }

      // Create new customer
      final newCustomer = Customer.create(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        address: _addressController.text.trim(),
        dateOfBirth: _dateOfBirthController.text,
      );

      // Save to database
      await _database!.customerDao.insertCustomer(newCustomer);

      // Save form data to preferences
      await _saveFormData();

      // Reload records and clear form
      await _loadCustomers();
      _clearForm();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText(
                'Customer added successfully!',
                'Client ajouté avec succès!'
            )),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error adding customer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText(
                'Error adding customer',
                'Erreur lors de l\'ajout du client'
            )),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Update existing customer in database
  ///
  /// Validates form data, updates Customer instance,
  /// saves to database and updates UI with success feedback
  Future<void> _updateCustomer() async {
    if (_editingCustomer == null || !_validateForm()) {
      return;
    }

    try {
      // Store the editing customer ID before operations
      final editingCustomerId = _editingCustomer!.id;

      // Create updated customer
      final updatedCustomer = _editingCustomer!.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        address: _addressController.text.trim(),
        dateOfBirth: _dateOfBirthController.text,
      );

      // Update in database
      await _database!.customerDao.updateCustomer(updatedCustomer);

      // Reload customers list
      await _loadCustomers();

      // Update selected customer if it's the one being edited
      if (_selectedCustomer?.id == editingCustomerId) {
        setState(() {
          _selectedCustomer = updatedCustomer;
        });
      }

      // Exit edit mode
      _exitEditMode();

      // Show success message only if widget is still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText(
                'Customer updated successfully!',
                'Client mis à jour avec succès!'
            )),
            backgroundColor: Colors.green, // Changed to green for success
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stack) {
      print('❌ Error updating customer: $e');
      print('📌 Stack trace: $stack');

      // Show error message only if widget is still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText(
                'Error updating customer',
                'Erreur lors de la mise à jour du client'
            )),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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
      await _encryptedPrefs?.setString('last_customer_first_name', _firstNameController.text);
      await _encryptedPrefs?.setString('last_customer_last_name', _lastNameController.text);
      await _encryptedPrefs?.setString('last_customer_address', _addressController.text);
      await _encryptedPrefs?.setString('last_customer_dob', _dateOfBirthController.text);
      print('✅ Customer form data saved to encrypted preferences');
    } catch (e) {
      print('⚠️ Warning: Could not save customer form data: $e');
    }
  }

  /// Validate form input fields
  ///
  /// Returns: true if all fields are valid, false otherwise
  /// Shows appropriate error messages for invalid input
  bool _validateForm() {
    if (_firstNameController.text.trim().isEmpty) {
      _showValidationError(_getText('First name is required', 'Le prénom est requis'));
      return false;
    }

    if (_lastNameController.text.trim().isEmpty) {
      _showValidationError(_getText('Last name is required', 'Le nom de famille est requis'));
      return false;
    }

    if (_addressController.text.trim().isEmpty) {
      _showValidationError(_getText('Address is required', 'L\'adresse est requise'));
      return false;
    }

    if (_dateOfBirthController.text.isEmpty) {
      _showValidationError(_getText('Date of birth is required', 'La date de naissance est requise'));
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
  /// Resets form to empty state for new customer entry
  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _addressController.clear();
    _dateOfBirthController.clear();
    setState(() {
      _isEditMode = false;
      _editingCustomer = null;
    });
  }

  /// Enter edit mode for selected customer
  ///
  /// [customer] Customer to edit
  /// Populates form with customer data for editing
  void _enterEditMode(Customer customer) {
    setState(() {
      _isEditMode = true;
      _editingCustomer = customer;
      _firstNameController.text = customer.firstName;
      _lastNameController.text = customer.lastName;
      _addressController.text = customer.address;
      _dateOfBirthController.text = customer.dateOfBirth;
    });
  }

  /// Exit edit mode and clear form
  ///
  /// Returns form to add mode
  void _exitEditMode() {
    _clearForm();
  }

  /// Delete customer from database
  ///
  /// [customer] Customer to delete
  /// Shows confirmation dialog before deletion
  Future<void> _deleteCustomer(Customer customer) async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_getText('Confirm Deletion', 'Confirmer la suppression')),
          content: Text(_getText(
              'Are you sure you want to delete ${customer.fullName}?',
              'Êtes-vous sûr de vouloir supprimer ${customer.fullName}?'
          )),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_getText('Cancel', 'Annuler')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_getText('Delete', 'Supprimer')),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _database!.customerDao.deleteCustomer(customer);
        await _loadCustomers();

        // Clear selection if deleted customer was selected
        if (_selectedCustomer?.id == customer.id) {
          setState(() {
            _selectedCustomer = null;
          });
        }

        // Exit edit mode if deleting currently edited customer
        if (_editingCustomer?.id == customer.id) {
          _exitEditMode();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getText(
                  'Customer deleted successfully',
                  'Client supprimé avec succès'
              )),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        print('❌ Error deleting customer: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getText(
                  'Error deleting customer',
                  'Erreur lors de la suppression du client'
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
                    content: Text('🇫🇷 Passé au français'),
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
          title: Text(_getText('Customer Management Help', 'Aide Gestion des Clients')),
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
                Text('1. ${_getText('Fill in customer details in the form', 'Remplissez les détails du client dans le formulaire')}'),
                const SizedBox(height: 8),
                Text('2. ${_getText('Click "Add Customer" to save new customers', 'Cliquez sur "Ajouter Client" pour enregistrer de nouveaux clients')}'),
                const SizedBox(height: 8),
                Text('3. ${_getText('Tap any customer from the list to view details', 'Appuyez sur n\'importe quel client de la liste pour voir les détails')}'),
                const SizedBox(height: 8),
                Text('4. ${_getText('Use "Edit" button to modify customer information', 'Utilisez le bouton "Modifier" pour modifier les informations client')}'),
                const SizedBox(height: 8),
                Text('5. ${_getText('Use "Delete" button to remove customers', 'Utilisez le bouton "Supprimer" pour retirer les clients')}'),
                const SizedBox(height: 8),
                Text('6. ${_getText('Use "Copy Previous" to copy last customer\'s data', 'Utilisez "Copier Précédent" pour copier les données du dernier client')}'),
                const SizedBox(height: 16),

                // Language differences section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getText('🌍 Language Features:', '🌍 Fonctionnalités linguistiques:'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_getText(
                          '• English: Full interface in English',
                          '• Français: Interface complète en français'
                      )),
                      const SizedBox(height: 4),
                      Text(_getText(
                          '• Use the 🌐 button to switch languages',
                          '• Utilisez le bouton 🌐 pour changer de langue'
                      )),
                    ],
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
  /// Opens native date picker and updates date of birth field
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // ~18 years ago
      firstDate: DateTime(1900), // Reasonable birth date range
      lastDate: DateTime.now(), // Can't be born in the future
    );

    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = picked.toString().split(' ')[0];
      });
    }
  }

  /// Copy data from previous customer
  ///
  /// Loads the most recently added customer's data into the form
  /// User can choose to copy or start fresh
  Future<void> _copyPreviousCustomer() async {
    try {
      final lastCustomer = await _database!.getLatestCustomer();

      if (lastCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText('No previous customer found', 'Aucun client précédent trouvé')),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show confirmation dialog
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(_getText('Copy Previous Customer', 'Copier le Client Précédent')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getText('Copy data from:', 'Copier les données de:')),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${lastCustomer.fullName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${lastCustomer.address}'),
                      Text(_getText('Born: ${lastCustomer.dateOfBirth}', 'Né: ${lastCustomer.dateOfBirth}')),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(_getText('Cancel', 'Annuler')),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(_getText('Copy', 'Copier')),
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        setState(() {
          _firstNameController.text = lastCustomer.firstName;
          _lastNameController.text = lastCustomer.lastName;
          _addressController.text = lastCustomer.address;
          _dateOfBirthController.text = lastCustomer.dateOfBirth;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText('Previous customer data copied', 'Données du client précédent copiées')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error copying previous customer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getText('Error copying previous customer', 'Erreur lors de la copie du client précédent')),
          backgroundColor: Colors.red,
        ),
      );
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
            flex: 1,
            child: _buildListAndForm(),
          ),
          Expanded(
            flex:1,
            child: _buildDetailsPanel(),
          ),
        ],
      );
    } else {
      // Phone layout: Full screen list/form or details
      if (_selectedCustomer != null && !_isEditMode) {
        return _buildDetailsPanel();
      } else {
        return _buildListAndForm();
      }
    }
  }

  /// Build list and form section
  ///
  /// Contains the main customers list and add/edit customer form
  Widget _buildListAndForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Add/Edit Customer Form
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode
                      ? _getText('Edit Customer', 'Modifier Client')
                      : _getText('Add New Customer', 'Ajouter Nouveau Client'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: _getText('First Name', 'Prénom'),
                    hintText: _getText('Enter first name', 'Entrez le prénom'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: _getText('Last Name', 'Nom de famille'),
                    hintText: _getText('Enter last name', 'Entrez le nom de famille'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: _getText('Address', 'Adresse'),
                    hintText: _getText('Enter address', 'Entrez l\'adresse'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.home),
                  ),
                  textCapitalization: TextCapitalization.words,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _dateOfBirthController,
                  decoration: InputDecoration(
                    labelText: _getText('Date of Birth', 'Date de naissance'),
                    hintText: _getText('Select date of birth', 'Sélectionnez la date de naissance'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.cake),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectDate,
                    ),
                  ),
                  readOnly: true,
                  onTap: _selectDate,
                ),
                const SizedBox(height: 16),

                // Action buttons
                if (_isEditMode) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _updateCustomer,
                          icon: const Icon(Icons.save),
                          label: Text(_getText('Update Customer', 'Mettre à jour Client')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _exitEditMode,
                        icon: const Icon(Icons.cancel),
                        label: Text(_getText('Cancel', 'Annuler')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addCustomer,
                          icon: const Icon(Icons.add),
                          label: Text(_getText('Add Customer', 'Ajouter Client')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _copyPreviousCustomer,
                        icon: const Icon(Icons.copy),
                        label: Text(_getText('Copy Previous', 'Copier Précédent')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _clearForm,
                          icon: const Icon(Icons.clear),
                          label: Text(_getText('Clear Form', 'Effacer Formulaire')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Customers List - Dynamic height to prevent overflow in landscape
          SizedBox(
            height: MediaQuery.of(context).size.height > 500
                ? MediaQuery.of(context).size.height - 450
                : 200, // Minimum height for very small screens
            child: _customers.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getText('No customers found', 'Aucun client trouvé'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getText('Add your first customer using the form above', 'Ajoutez votre premier client en utilisant le formulaire ci-dessus'),
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final customer = _customers[index];
                final isSelected = _selectedCustomer?.id == customer.id;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  elevation: isSelected ? 4 : 2,
                  color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                  child: ListTile(
                    title: Text(
                      customer.fullName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customer.address),
                        Text(_getText('Born: ${customer.dateOfBirth}', 'Né: ${customer.dateOfBirth}')),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.blue),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCustomer =
                        _selectedCustomer?.id == customer.id ? null : customer;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build details panel for selected customer
  ///
  /// Shows information about the selected customer
  Widget _buildDetailsPanel() {
    final size = MediaQuery.of(context).size;
    final isPhone = size.width <= 720 || size.width <= size.height;

    if (_selectedCustomer == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getText('Select a customer to view details', 'Sélectionnez un client pour voir les détails'),
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getText('Tap any customer from the list', 'Appuyez sur n\'importe quel client de la liste'),
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
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
                      _selectedCustomer = null;
                    });
                  },
                ),
                Text(
                  _getText('Customer Details', 'Détails du Client'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            )
          else
            Text(
              _getText('Customer Details', 'Détails du Client'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 16),

          // Customer avatar and name
          Center(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  _selectedCustomer!.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Customer info cards
          _buildDetailCard(
            icon: Icons.tag,
            title: _getText('Customer ID', 'ID Client'),
            value: '${_selectedCustomer!.id}',
            color: Colors.blue,
          ),
          const SizedBox(height: 12),

          _buildDetailCard(
            icon: Icons.person,
            title: _getText('First Name', 'Prénom'),
            value: _selectedCustomer!.firstName,
            color: Colors.green,
          ),
          const SizedBox(height: 12),

          _buildDetailCard(
            icon: Icons.person_outline,
            title: _getText('Last Name', 'Nom de famille'),
            value: _selectedCustomer!.lastName,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),

          _buildDetailCard(
            icon: Icons.home,
            title: _getText('Address', 'Adresse'),
            value: _selectedCustomer!.address,
            color: Colors.purple,
          ),
          const SizedBox(height: 12),

          _buildDetailCard(
            icon: Icons.cake,
            title: _getText('Date of Birth', 'Date de naissance'),
            value: _selectedCustomer!.dateOfBirth,
            color: Colors.red,
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _enterEditMode(_selectedCustomer!),
                  icon: const Icon(Icons.edit),
                  label: Text(_getText('Edit Customer', 'Modifier Client')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _deleteCustomer(_selectedCustomer!),
                  icon: const Icon(Icons.delete),
                  label: Text(_getText('Delete Customer', 'Supprimer Client')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build a detail information card
  ///
  /// [icon] Icon to display
  /// [title] Title text
  /// [value] Value text
  /// [color] Theme color
  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
        title: Text(_getText('Customer Management', 'Gestion des Clients')),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isFrench ? Icons.language : Icons.translate),
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
            Text(_getText('Loading customers...', 'Chargement des clients...')),
            const SizedBox(height: 8),
            Text(
              _getText('Please wait while we initialize the database', 'Veuillez patienter pendant que nous initialisons la base de données'),
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : _buildResponsiveLayout(),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }
}