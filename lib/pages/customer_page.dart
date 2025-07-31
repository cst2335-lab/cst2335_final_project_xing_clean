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


