/// Airplane List Page Widget - Airplane Management Interface with English/French Support
///
/// Project Requirements Addressed:
/// * Requirement 1: ListView displaying user-inserted airplane items
/// * Requirement 2: TextFields with button for insertion
/// * Requirement 3: Database storage using Floor (SQLite)
/// * Requirement 4: Responsive detail view for selected airplanes
/// * Requirement 5: Snackbar and AlertDialog for user feedback
/// * Requirement 6: EncryptedSharedPreferences for form data persistence
/// * Requirement 7: Help dialog with usage instructions
/// * Requirement 8: Multi-language support (English/French)
/// * Requirement 10: Professional interface design
library;

import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../dao/airplane_dao.dart';
import '../database/airplane_database.dart';
import '../models/airplane.dart';

/// Main Airplane Management Page with bilingual support
///
/// Provides a complete interface for managing airplane fleet data including
/// adding, updating, deleting, and viewing airplane specifications
/// in both English and French languages with responsive layout support
class AirplaneListPage extends StatefulWidget {
  /// Creates a new AirplaneListPage widget
  const AirplaneListPage({super.key});

  @override
  State<AirplaneListPage> createState() => _AirplaneListPageState();
}

/// State class for AirplaneListPage
///
/// Manages airplane data, form inputs, and user interactions
/// with database persistence, encrypted preference storage,
/// bilingual interface support, and responsive layout
class _AirplaneListPageState extends State<AirplaneListPage> {
  /// Data Access Object for airplane database operations
  late AirplaneDao dao;

  /// List of all airplanes loaded from database
  List<Airplane> airplanes = [];

  /// Form controllers for airplane specifications
  final _typeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _speedController = TextEditingController();
  final _rangeController = TextEditingController();

  /// Encrypted storage for persisting form data
  EncryptedSharedPreferences? _encryptedPrefs;

  /// Currently selected airplane for editing/deletion
  Airplane? _selectedAirplane;

  /// Language toggle state (false = English, true = French)
  bool _isFrench = false;

  /// Helper method to get text based on current language
  ///
  /// Returns the appropriate text based on the current language setting
  /// [english] English text to display
  /// [french] French text to display
  String _getText(String english, String french) {
    return _isFrench ? french : english;
  }

  /// Initialize state and set up form listeners
  ///
  /// Sets up database connection and adds listeners to form fields
  /// for automatic saving of user input
  @override
  void initState() {
    super.initState();
    _initDB();
    _typeController.addListener(_saveInput);
    _capacityController.addListener(_saveInput);
    _speedController.addListener(_saveInput);
    _rangeController.addListener(_saveInput);
  }

  /// Clean up resources when widget is disposed
  ///
  /// Disposes all text controllers to prevent memory leaks
  @override
  void dispose() {
    _typeController.dispose();
    _capacityController.dispose();
    _speedController.dispose();
    _rangeController.dispose();
    super.dispose();
  }

  /// Initialize database connection and load saved form data
  ///
  /// Sets up Floor database connection, initializes encrypted preferences,
  /// and prompts user whether to reuse previous form input
  /// Requirement 3: Database initialization
  /// Requirement 6: EncryptedSharedPreferences usage
  Future<void> _initDB() async {
    // Initialize encrypted preferences
    _encryptedPrefs = EncryptedSharedPreferences();

    // Load language preference
    final savedLang = await _encryptedPrefs?.getString('language') ?? 'en';
    setState(() {
      _isFrench = savedLang == 'fr';
    });

    // Initialize database
    final db = await $FloorAirplaneDatabase.databaseBuilder('airplanes.db').build();
    dao = db.airplaneDao;

    final useLast = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_getText("Use Previous Data?", "Utiliser les données précédentes?")),
        content: Text(_getText(
            "Do you want to reuse last airplane form input?",
            "Voulez-vous réutiliser la dernière saisie du formulaire d'avion?"
        )),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(_getText("No", "Non"))
          ),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(_getText("Yes", "Oui"))
          ),
        ],
      ),
    );

    if (useLast ?? false) {
      _typeController.text = await _encryptedPrefs?.getString('last_type') ?? '';
      _capacityController.text = await _encryptedPrefs?.getString('last_capacity') ?? '';
      _speedController.text = await _encryptedPrefs?.getString('last_speed') ?? '';
      _rangeController.text = await _encryptedPrefs?.getString('last_range') ?? '';
    } else {
      await _clearInput();
    }

    _loadAirplanes();
  }

  /// Load all airplanes from database
  ///
  /// Fetches complete list of airplanes from database and updates UI
  /// Requirement 1: ListView data loading
  Future<void> _loadAirplanes() async {
    final list = await dao.findAllAirplanes();
    setState(() {
      airplanes = list;
    });
  }

  /// Add new airplane to database
  ///
  /// Validates form input, creates new Airplane instance,
  /// saves to database and updates UI with success feedback
  /// Requirement 2: Insert functionality with button
  /// Requirement 5: Snackbar feedback
  Future<void> _addAirplane() async {
    if (_formNotValid()) return;

    final airplane = Airplane(
      type: _typeController.text,
      passengerCapacity: int.parse(_capacityController.text),
      maxSpeed: int.parse(_speedController.text),
      range: int.parse(_rangeController.text),
    );

    final insertedId = await dao.insertAirplane(airplane);
    airplane.id = insertedId;

    await _saveInput();

    setState(() {
      airplanes.add(airplane);
      _clearForm();
    });

    _showSnackBar(_getText("🛫 Airplane added!", "🛫 Avion ajouté!"));
  }

  /// Update existing airplane in database
  ///
  /// Validates form input, updates selected airplane with new values,
  /// saves to database and refreshes UI
  /// Requirement 4: Detail view with update functionality
  Future<void> _updateAirplane() async {
    if (_formNotValid() || _selectedAirplane == null) return;

    final updated = Airplane(
      id: _selectedAirplane!.id,
      type: _typeController.text,
      passengerCapacity: int.parse(_capacityController.text),
      maxSpeed: int.parse(_speedController.text),
      range: int.parse(_rangeController.text),
    );

    await dao.updateAirplane(updated);
    await _saveInput();

    setState(() {
      final index = airplanes.indexWhere((a) => a.id == updated.id);
      if (index != -1) airplanes[index] = updated;
      _clearForm();
    });

    _showSnackBar(_getText("🛠️ Airplane updated", "🛠️ Avion mis à jour"));
  }

  /// Show confirmation dialog before deleting airplane
  ///
  /// Displays AlertDialog to confirm deletion, then removes airplane
  /// from database and updates UI if confirmed
  /// Requirement 5: AlertDialog for deletion confirmation
  void _confirmDeleteAirplane() {
    if (_selectedAirplane == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_getText("Delete?", "Supprimer?")),
        content: Text(_getText(
            "Delete airplane: ${_selectedAirplane!.type}?",
            "Supprimer l'avion: ${_selectedAirplane!.type}?"
        )),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_getText("Cancel", "Annuler"))
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await dao.deleteAirplane(_selectedAirplane!);
              setState(() {
                airplanes.removeWhere((a) => a.id == _selectedAirplane!.id);
                _clearForm();
              });
              _showSnackBar(_getText("🗑️ Airplane deleted", "🗑️ Avion supprimé"));
            },
            child: Text(
                _getText("Delete", "Supprimer"),
                style: const TextStyle(color: Colors.red)
            ),
          )
        ],
      ),
    );
  }

  /// Validate form input fields
  ///
  /// Checks if all required fields are filled
  /// Shows snackbar with error message if validation fails
  /// Returns: true if form is invalid, false if valid
  bool _formNotValid() {
    if (_typeController.text.isEmpty ||
        _capacityController.text.isEmpty ||
        _speedController.text.isEmpty ||
        _rangeController.text.isEmpty) {
      _showSnackBar(_getText(
          "✏️ Please fill in all fields",
          "✏️ Veuillez remplir tous les champs"
      ));
      return true;
    }
    return false;
  }

  /// Clear all form fields and selection
  ///
  /// Resets form to empty state for new airplane entry
  void _clearForm() {
    _typeController.clear();
    _capacityController.clear();
    _speedController.clear();
    _rangeController.clear();
    _selectedAirplane = null;
  }

  /// Save current form input to encrypted preferences
  ///
  /// Stores form field values for retrieval in future sessions
  /// Requirement 6: EncryptedSharedPreferences usage for form persistence
  Future<void> _saveInput() async {
    await _encryptedPrefs?.setString('last_type', _typeController.text);
    await _encryptedPrefs?.setString('last_capacity', _capacityController.text);
    await _encryptedPrefs?.setString('last_speed', _speedController.text);
    await _encryptedPrefs?.setString('last_range', _rangeController.text);
  }

  /// Clear all saved form input from encrypted preferences
  ///
  /// Removes all stored form data from encrypted storage
  Future<void> _clearInput() async {
    await _encryptedPrefs?.clear();
  }

  /// Display snackbar with message
  ///
  /// Shows brief notification at bottom of screen
  /// [msg] Message to display in snackbar
  /// Requirement 5: Snackbar for user feedback
  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Show help dialog with usage instructions
  ///
  /// Displays detailed instructions for using the airplane management interface
  /// Requirement 7: ActionBar with help instructions
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_getText("🧭 How to use", "🧭 Comment utiliser")),
        content: Text(_getText(
            "1. Fill in airplane details:\n"
                "   • Type: Model name (e.g., Boeing 737)\n"
                "   • Capacity: Number of passengers\n"
                "   • Speed: Maximum speed in km/h\n"
                "   • Range: Flight range in km\n\n"
                "2. Tap 'Add Airplane' to save\n\n"
                "3. Tap any airplane from the list to edit or delete\n\n"
                "4. Your last input is saved automatically",
            "1. Remplissez les détails de l'avion:\n"
                "   • Type: Nom du modèle (ex: Boeing 737)\n"
                "   • Capacité: Nombre de passagers\n"
                "   • Vitesse: Vitesse maximale en km/h\n"
                "   • Portée: Portée de vol en km\n\n"
                "2. Appuyez sur 'Ajouter Avion' pour enregistrer\n\n"
                "3. Appuyez sur n'importe quel avion de la liste pour modifier ou supprimer\n\n"
                "4. Votre dernière saisie est enregistrée automatiquement"
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Show language selection dialog
  ///
  /// Displays dialog for switching between English and French
  /// Requirement 8: Language switching functionality
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_getText('Select Language', 'Choisir la langue')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.check_circle,
                    color: !_isFrench ? Colors.blue : Colors.grey),
                title: const Text('English'),
                onTap: () async {
                  setState(() => _isFrench = false);
                  await _encryptedPrefs?.setString('language', 'en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.check_circle,
                    color: _isFrench ? Colors.blue : Colors.grey),
                title: const Text('Français'),
                onTap: () async {
                  setState(() => _isFrench = true);
                  await _encryptedPrefs?.setString('language', 'fr');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show airplane details dialog for phone layout
  ///
  /// Displays full airplane details in a dialog for phone users
  /// Requirement 4: Full screen detail view for phones
  void _showAirplaneDetailsDialog(Airplane airplane) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  children: [
                    Icon(Icons.airplanemode_active, size: 32, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        airplane.type,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Specifications
                Text(
                  _getText('Specifications', 'Spécifications'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),

                // Details
                _buildDetailRow(
                  Icons.people,
                  _getText('Passenger Capacity', 'Capacité de passagers'),
                  '${airplane.passengerCapacity} ${_getText('passengers', 'passagers')}',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.speed,
                  _getText('Maximum Speed', 'Vitesse maximale'),
                  '${airplane.maxSpeed} km/h',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.flight,
                  _getText('Flight Range', 'Portée de vol'),
                  '${airplane.range} km',
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: Text(_getText('Edit', 'Modifier')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(45),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          setState(() {
                            _selectedAirplane = airplane;
                            _typeController.text = airplane.type;
                            _capacityController.text = airplane.passengerCapacity.toString();
                            _speedController.text = airplane.maxSpeed.toString();
                            _rangeController.text = airplane.range.toString();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: Text(_getText('Delete', 'Supprimer')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(45),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          setState(() {
                            _selectedAirplane = airplane;
                          });
                          _confirmDeleteAirplane();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build airplane details panel for responsive layout
  ///
  /// Creates a detailed view of the selected airplane with edit/delete options
  /// Used in tablet layout to display alongside the list
  /// Requirement 4: Responsive detail view for tablets
  Widget _buildDetailPanel() {
    if (_selectedAirplane == null) {
      return Card(
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.airplanemode_inactive,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _getText(
                    'Select an airplane to view details',
                    'Sélectionnez un avion pour voir les détails'
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.airplanemode_active, size: 32, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedAirplane!.type,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Specifications
            Text(
              _getText('Specifications', 'Spécifications'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),

            // Details grid
            _buildDetailRow(
              Icons.people,
              _getText('Passenger Capacity', 'Capacité de passagers'),
              '${_selectedAirplane!.passengerCapacity} ${_getText('passengers', 'passagers')}',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.speed,
              _getText('Maximum Speed', 'Vitesse maximale'),
              '${_selectedAirplane!.maxSpeed} km/h',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.flight,
              _getText('Flight Range', 'Portée de vol'),
              '${_selectedAirplane!.range} km',
            ),

            const Spacer(),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: Text(_getText('Edit', 'Modifier')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(45),
                    ),
                    onPressed: () {
                      _typeController.text = _selectedAirplane!.type;
                      _capacityController.text = _selectedAirplane!.passengerCapacity.toString();
                      _speedController.text = _selectedAirplane!.maxSpeed.toString();
                      _rangeController.text = _selectedAirplane!.range.toString();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: Text(_getText('Delete', 'Supprimer')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(45),
                    ),
                    onPressed: _confirmDeleteAirplane,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build detail row for specifications display
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blue[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build form section with input fields
  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
            child: TextField(
              controller: _typeController,
              decoration: InputDecoration(
                labelText: _getText('✈️ Type', '✈️ Type'),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _getText('👥 Capacity', '👥 Capacité'),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _speedController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _getText('💨 Speed (km/h)', '💨 Vitesse (km/h)'),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _rangeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _getText('📏 Range (km)', '📏 Portée (km)'),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        _selectedAirplane == null
            ? ElevatedButton.icon(
          icon: const Icon(Icons.flight_takeoff),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(45),
          ),
          onPressed: _addAirplane,
          label: Text(_getText("Add Airplane", "Ajouter Avion")),
        )
            : Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.system_update),
                onPressed: _updateAirplane,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(45),
                ),
                label: Text(_getText("Update", "Mettre à jour")),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever),
                onPressed: _confirmDeleteAirplane,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(45),
                ),
                label: Text(_getText("Delete", "Supprimer")),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build airplane list widget
  Widget _buildAirplaneList() {
    if (airplanes.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.airplanemode_inactive,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getText(
                  'No airplanes registered yet',
                  'Aucun avion enregistré pour le moment'
              ),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: airplanes.length,
      itemBuilder: (context, index) {
        final airplane = airplanes[index];
        final isSelected = _selectedAirplane?.id == airplane.id;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          color: isSelected
              ? Colors.blue.withOpacity(0.1)
              : Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isSelected
                ? BorderSide(color: Colors.blue, width: 2)
                : BorderSide.none,
          ),
          elevation: 3,
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Icon(
                Icons.airplanemode_active,
                color: isSelected ? Colors.blue : Colors.grey[600],
              ),
              title: Text(
                airplane.type,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                "👥 ${airplane.passengerCapacity} | 💨 ${airplane.maxSpeed} km/h | 📏 ${airplane.range} km",
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                setState(() {
                  _selectedAirplane = airplane;
                });

                final isTablet = MediaQuery.of(context).size.width > 600;
                if (!isTablet) {
                  // On phone, show details dialog
                  _showAirplaneDetailsDialog(airplane);
                }
                // On tablet, details will show in the side panel
              },
            ),
          ),
        );
      },
    );
  }

  /// Build the airplane management interface with responsive layout
  ///
  /// Creates a responsive layout that adapts to screen size:
  /// - Tablets: Side-by-side list and details view
  /// - Phones: Single column with inline editing
  ///
  /// [context] Build context for the widget tree
  ///
  /// Returns: Scaffold widget with complete airplane management UI
  /// Requirement 1: ListView for displaying airplanes
  /// Requirement 2: TextFields and buttons for data entry
  /// Requirement 4: Responsive detail view (tablet/phone)
  /// Requirement 8: Multi-language support
  /// Requirement 10: Professional interface design
  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.flight, color: Colors.white),
            const SizedBox(width: 8),
            Text(_getText('Airplane Management', 'Gestion des Avions')),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguageDialog,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          )
        ],
      ),
      backgroundColor: Colors.blue[50],
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: isTablet
              ? Row(
            children: [
              // Left side - Form and List
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormSection(),
                      const Divider(height: 32),
                      Text(
                        _getText('🛬 All Registered Airplanes:', '🛬 Tous les avions enregistrés:'),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildAirplaneList(),
                    ],
                  ),
                ),
              ),
              // Divider
              const VerticalDivider(
                width: 1,
                thickness: 1,
              ),
              // Right side - Details Panel
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.white,
                  child: _buildDetailPanel(),
                ),
              ),
            ],
          )
              : SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormSection(),
                const Divider(height: 32),
                Text(
                  _getText('🛬 All Registered Airplanes:', '🛬 Tous les avions enregistrés:'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                _buildAirplaneList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}