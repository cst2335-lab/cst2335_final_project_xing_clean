/// Reservation Page Widget - English/French Language Support
///
/// Project Requirements Addressed:
/// * Requirement 8: Multi-language support with English and French
/// * Clean and simple interface design for flight reservations
/// * Clear language switching demonstration
/// * Full CRUD operations including edit functionality
library;

import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../database/app_database.dart';
import '../models/reservation.dart';

/// Main Reservation Page with English/French language switching
///
/// Provides a clean interface for flight reservation management with
/// bilingual support for better requirement demonstration
class ReservationPage extends StatefulWidget {
  /// Creates a new ReservationPage widget
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

/// State class for ReservationPage with English/French switching
///
/// Manages language preference between English and French
/// for clear multilingual demonstration
class _ReservationPageState extends State<ReservationPage> {
  /// Current language setting - true for French, false for English
  bool _isFrench = false;

  /// List of reservations loaded from database
  List<Reservation> _reservations = [];

  /// Currently selected reservation for details view
  Reservation? _selectedReservation;

  /// Edit mode flag - true when editing existing reservation
  bool _isEditMode = false;

  /// Loading state indicator
  bool _isLoading = true;

  /// Form controllers for user input
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _flightIdController = TextEditingController();
  final TextEditingController _flightDateController = TextEditingController();
  final TextEditingController _reservationNameController = TextEditingController();

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
          .databaseBuilder('reservations_database.db')
          .build();

      print('🔧 Step 3: Loading form data from preferences...');
      await _loadFormData();

      print('🔧 Step 4: Loading reservations from database...');
      await _loadReservations();

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
      // Only load saved data if not in edit mode
      if (!_isEditMode) {
        final customerId = await _encryptedPrefs?.getString('last_customer_id');
        final flightId = await _encryptedPrefs?.getString('last_flight_id');
        final flightDate = await _encryptedPrefs?.getString('last_flight_date');
        final reservationName = await _encryptedPrefs?.getString('last_reservation_name');

        if (mounted) {
          setState(() {
            _customerIdController.text = customerId ?? '';
            _flightIdController.text = flightId ?? '';
            _flightDateController.text = flightDate ?? '';
            _reservationNameController.text = reservationName ?? '';
          });
        }
      }
    } catch (e) {
      print('⚠️ Warning: Could not load form data: $e');
    }
  }

  /// Load all reservations from database
  ///
  /// Fetches complete list of reservations and updates UI state
  /// Handles database errors gracefully with user feedback
  Future<void> _loadReservations() async {
    try {
      if (_database != null) {
        final records = await _database!.reservationDao.findAllReservations();
        if (mounted) {
          setState(() {
            _reservations = records;
          });
        }
        print('✅ Loaded ${records.length} reservations from database');
      }
    } catch (e) {
      print('❌ Error loading reservations: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText('Failed to load reservations', 'Échec du chargement des réservations')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Add new reservation to database
  ///
  /// Validates form data, creates new Reservation instance,
  /// saves to database and updates UI with success feedback
  Future<void> _addReservation() async {
    // Validate form input
    if (!_validateForm()) {
      return;
    }

    try {
      // Create new reservation
      final newReservation = Reservation.create(
        customerId: int.parse(_customerIdController.text),
        flightId: int.parse(_flightIdController.text),
        flightDate: _flightDateController.text,
        reservationName: _reservationNameController.text.trim(),
      );

      // Save to database
      await _database!.reservationDao.insertReservation(newReservation);

      // Save form data to preferences
      await _saveFormData();

      // Reload records and clear form
      await _loadReservations();
      _clearForm();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText(
                'Reservation added successfully!',
                'Réservation ajoutée avec succès!'
            )),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error adding reservation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText(
                'Error adding reservation',
                'Erreur lors de l\'ajout de la réservation'
            )),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Update existing reservation in database
  ///
  /// Validates form data, updates reservation with new values,
  /// saves to database and updates UI with success feedback
  Future<void> _updateReservation() async {
    // Validate form input
    if (!_validateForm() || _selectedReservation == null) {
      return;
    }

    try {
      // Create updated reservation with same ID
      final updatedReservation = Reservation(
        id: _selectedReservation!.id,
        customerId: int.parse(_customerIdController.text),
        flightId: int.parse(_flightIdController.text),
        flightDate: _flightDateController.text,
        reservationName: _reservationNameController.text.trim(),
      );

      // Update in database
      await _database!.reservationDao.updateReservation(updatedReservation);

      // Save form data to preferences
      await _saveFormData();

      // Reload records
      await _loadReservations();

      // Update selected reservation and exit edit mode
      setState(() {
        _selectedReservation = updatedReservation;
        _isEditMode = false;
      });

      // Clear form
      _clearForm();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText(
                'Reservation updated successfully!',
                'Réservation mise à jour avec succès!'
            )),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      print('❌ Error updating reservation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText(
                'Error updating reservation',
                'Erreur lors de la mise à jour de la réservation'
            )),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Enter edit mode for selected reservation
  ///
  /// Populates form fields with selected reservation data
  void _startEditReservation() {
    if (_selectedReservation == null) return;

    setState(() {
      _isEditMode = true;
      _customerIdController.text = _selectedReservation!.customerId.toString();
      _flightIdController.text = _selectedReservation!.flightId.toString();
      _flightDateController.text = _selectedReservation!.flightDate;
      _reservationNameController.text = _selectedReservation!.reservationName;
    });
  }

  /// Cancel edit mode and clear form
  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      _clearForm();
    });
  }

  /// Save current form data to encrypted preferences
  ///
  /// Stores form field values for retrieval in future sessions
  /// Requirement 6: EncryptedSharedPreferences usage
  Future<void> _saveFormData() async {
    try {
      await _encryptedPrefs?.setString('last_customer_id', _customerIdController.text);
      await _encryptedPrefs?.setString('last_flight_id', _flightIdController.text);
      await _encryptedPrefs?.setString('last_flight_date', _flightDateController.text);
      await _encryptedPrefs?.setString('last_reservation_name', _reservationNameController.text);
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

    if (_flightIdController.text.isEmpty) {
      _showValidationError(_getText('Flight ID is required', 'L\'ID du vol est requis'));
      return false;
    }

    if (_flightDateController.text.isEmpty) {
      _showValidationError(_getText('Flight date is required', 'La date du vol est requise'));
      return false;
    }

    if (_reservationNameController.text.trim().isEmpty) {
      _showValidationError(_getText('Reservation name is required', 'Le nom de la réservation est requis'));
      return false;
    }

    // Validate numeric fields
    if (int.tryParse(_customerIdController.text) == null) {
      _showValidationError(_getText('Invalid Customer ID format', 'Format d\'ID client invalide'));
      return false;
    }

    if (int.tryParse(_flightIdController.text) == null) {
      _showValidationError(_getText('Invalid Flight ID format', 'Format d\'ID de vol invalide'));
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
  /// Resets form to empty state for new reservation entry
  void _clearForm() {
    _customerIdController.clear();
    _flightIdController.clear();
    _flightDateController.clear();
    _reservationNameController.clear();
  }

  /// Delete reservation from database
  ///
  /// [reservation] Reservation to delete
  /// Shows confirmation dialog before deletion
  Future<void> _deleteReservation(Reservation reservation) async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_getText('Confirm Deletion', 'Confirmer la suppression')),
          content: Text(_getText(
              'Are you sure you want to delete this reservation?',
              'Êtes-vous sûr de vouloir supprimer cette réservation?'
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
        await _database!.reservationDao.deleteReservation(reservation);
        await _loadReservations();

        // Clear selection if deleted record was selected
        if (_selectedReservation?.id == reservation.id) {
          setState(() {
            _selectedReservation = null;
            _isEditMode = false;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getText(
                  'Reservation deleted successfully',
                  'Réservation supprimée avec succès'
              )),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        print('❌ Error deleting reservation: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getText(
                  'Error deleting reservation',
                  'Erreur lors de la suppression de la réservation'
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
          title: Text(_getText('Reservation Management Help', 'Aide à la gestion des réservations')),
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
                Text('1. ${_getText('Fill in the Customer ID field', 'Remplissez le champ ID Client')}'),
                const SizedBox(height: 8),
                Text('2. ${_getText('Enter the Flight ID for the desired flight', 'Entrez l\'ID du vol souhaité')}'),
                const SizedBox(height: 8),
                Text('3. ${_getText('Select the flight date', 'Sélectionnez la date du vol')}'),
                const SizedBox(height: 8),
                Text('4. ${_getText('Add a reservation name (e.g., "Summer Vacation")', 'Ajoutez un nom de réservation (ex: "Vacances d\'été")')}'),
                const SizedBox(height: 8),
                Text('5. ${_getText('Click "Add Reservation" to save', 'Cliquez sur "Ajouter une réservation" pour sauvegarder')}'),
                const SizedBox(height: 8),
                Text('6. ${_getText('Tap any reservation to view details', 'Appuyez sur une réservation pour voir les détails')}'),
                const SizedBox(height: 8),
                Text('7. ${_getText('Use edit button to modify reservations', 'Utilisez le bouton modifier pour éditer les réservations')}'),
                const SizedBox(height: 8),
                Text('8. ${_getText('Use delete button to remove reservations', 'Utilisez le bouton supprimer pour enlever des réservations')}'),
                const SizedBox(height: 16),

                // Business Rules Section
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
                        _getText('📋 Flight Booking Rules:', '📋 Règles de Réservation de Vol:'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_getText(
                          '• Each flight happens only once per day',
                          '• Chaque vol n\'a lieu qu\'une fois par jour'
                      )),
                      const SizedBox(height: 4),
                      Text(_getText(
                          '• Flights repeat daily - no need to worry about specific weekdays',
                          '• Les vols se répètent quotidiennement - pas besoin de s\'inquiéter des jours spécifiques'
                      )),
                      const SizedBox(height: 4),
                      Text(_getText(
                          '• Multiple flights between same cities have different Flight IDs',
                          '• Plusieurs vols entre les mêmes villes ont des ID de vol différents'
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

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
  /// Opens native date picker and updates flight date field
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Can't book flights in the past
      lastDate: DateTime.now().add(const Duration(days: 365)), // Up to 1 year ahead
    );

    if (picked != null) {
      setState(() {
        _flightDateController.text = picked.toString().split(' ')[0];
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
      if (_selectedReservation != null && !_isEditMode) {
        return _buildDetailsPanel();
      } else {
        return _buildListAndForm();
      }
    }
  }

  /// Build list and form section
  ///
  /// Contains the main reservations list and add reservation form
  Widget _buildListAndForm() {
    return Column(
      children: [
        // Add/Edit Reservation Form
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditMode
                          ? _getText('Edit Reservation', 'Modifier la réservation')
                          : _getText('Add New Reservation', 'Ajouter une nouvelle réservation'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_isEditMode)
                    TextButton(
                      onPressed: _cancelEdit,
                      child: Text(_getText('Cancel', 'Annuler')),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _customerIdController,
                decoration: InputDecoration(
                  labelText: _getText('Customer ID', 'ID Client'),
                  hintText: _getText('Enter customer ID', 'Entrez l\'ID du client'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _flightIdController,
                decoration: InputDecoration(
                  labelText: _getText('Flight ID', 'ID du Vol'),
                  hintText: _getText('Enter flight ID', 'Entrez l\'ID du vol'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.flight),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _flightDateController,
                decoration: InputDecoration(
                  labelText: _getText('Flight Date', 'Date du Vol'),
                  hintText: _getText('Select flight date', 'Sélectionnez la date du vol'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: _selectDate,
                  ),
                ),
                readOnly: true,
                onTap: _selectDate,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reservationNameController,
                decoration: InputDecoration(
                  labelText: _getText('Reservation Name', 'Nom de la Réservation'),
                  hintText: _getText('e.g., "Summer Vacation"', 'ex: "Vacances d\'été"'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.bookmark),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isEditMode ? _updateReservation : _addReservation,
                      icon: Icon(_isEditMode ? Icons.update : Icons.add),
                      label: Text(_isEditMode
                          ? _getText('Update Reservation', 'Mettre à jour')
                          : _getText('Add Reservation', 'Ajouter une Réservation')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEditMode ? Colors.orange : Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _clearForm,
                    icon: const Icon(Icons.clear),
                    label: Text(_getText('Clear', 'Effacer')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Reservations List
        Expanded(
          child: _reservations.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flight_takeoff,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _getText('No reservations found', 'Aucune réservation trouvée'),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  _getText('Add your first reservation using the form above', 'Ajoutez votre première réservation avec le formulaire ci-dessus'),
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: _reservations.length,
            itemBuilder: (context, index) {
              final reservation = _reservations[index];
              final isSelected = _selectedReservation?.id == reservation.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                elevation: isSelected ? 4 : 2,
                color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? Colors.blue : Colors.orange,
                    child: const Icon(
                      Icons.flight_takeoff,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    reservation.reservationName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getText(
                          'Customer ${reservation.customerId} • Flight ${reservation.flightId}',
                          'Client ${reservation.customerId} • Vol ${reservation.flightId}'
                      )),
                      Text(_getText(
                          'Date: ${reservation.flightDate}',
                          'Date: ${reservation.flightDate}'
                      )),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.blue),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          setState(() {
                            _selectedReservation = reservation;
                          });
                          _startEditReservation();
                        },
                        tooltip: _getText('Edit reservation', 'Modifier la réservation'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteReservation(reservation),
                        tooltip: _getText('Delete reservation', 'Supprimer la réservation'),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _selectedReservation =
                      _selectedReservation?.id == reservation.id ? null : reservation;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build details panel for selected reservation
  ///
  /// Shows information about the selected reservation
  Widget _buildDetailsPanel() {
    final size = MediaQuery.of(context).size;
    final isPhone = size.width <= 720 || size.width <= size.height;

    if (_selectedReservation == null) {
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
              _getText('Select a reservation to view details', 'Sélectionnez une réservation pour voir les détails'),
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getText('Tap any reservation from the list', 'Appuyez sur une réservation de la liste'),
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
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
                      _selectedReservation = null;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    _getText('Reservation Details', 'Détails de la Réservation'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          else
            Text(
              _getText('Reservation Details', 'Détails de la Réservation'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 16),

          // Reservation info cards
          _buildDetailCard(
            icon: Icons.bookmark,
            title: _getText('Reservation Name', 'Nom de la Réservation'),
            value: _selectedReservation!.reservationName,
            color: Colors.purple,
          ),
          const SizedBox(height: 12),

          _buildDetailCard(
            icon: Icons.tag,
            title: _getText('Reservation ID', 'ID Réservation'),
            value: '${_selectedReservation!.id}',
            color: Colors.blue,
          ),
          const SizedBox(height: 12),

          _buildDetailCard(
            icon: Icons.person,
            title: _getText('Customer ID', 'ID Client'),
            value: '${_selectedReservation!.customerId}',
            color: Colors.green,
          ),
          const SizedBox(height: 12),

          _buildDetailCard(
            icon: Icons.flight,
            title: _getText('Flight ID', 'ID du Vol'),
            value: '${_selectedReservation!.flightId}',
            color: Colors.orange,
          ),
          const SizedBox(height: 12),

          _buildDetailCard(
            icon: Icons.calendar_today,
            title: _getText('Flight Date', 'Date du Vol'),
            value: _selectedReservation!.flightDate,
            color: Colors.red,
          ),

          const Spacer(),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _startEditReservation,
                  icon: const Icon(Icons.edit),
                  label: Text(_getText('Edit Reservation', 'Modifier la Réservation')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _deleteReservation(_selectedReservation!),
                  icon: const Icon(Icons.delete),
                  label: Text(_getText('Delete', 'Supprimer')),
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
        title: Text(_getText('Reservation Management', 'Gestion des Réservations')),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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
            Text(_getText('Loading reservations...', 'Chargement des réservations...')),
            const SizedBox(height: 8),
            Text(
              _getText('Please wait while we initialize the database', 'Veuillez patienter pendant l\'initialisation de la base de données'),
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
    _customerIdController.dispose();
    _flightIdController.dispose();
    _flightDateController.dispose();
    _reservationNameController.dispose();
    super.dispose();
  }
}