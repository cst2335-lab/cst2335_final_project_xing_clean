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

  }
}


