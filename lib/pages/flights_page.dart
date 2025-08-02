import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../dao/flight_dao.dart';
import '../models/flight.dart';

/// Flight Management Page Widget
///
/// Provides complete flight booking and management functionality
/// with multi-language support (English/French), responsive layout,
/// and encrypted data persistence
/// 
/// Project Requirements Addressed:
/// * Requirement 1: ListView displaying flight records
/// * Requirement 2: TextFields with submit button for data entry
/// * Requirement 3: SQLite database for persistent storage
/// * Requirement 4: Responsive detail view (tablet/phone)
/// * Requirement 5: Snackbar and AlertDialog for user feedback
/// * Requirement 6: EncryptedSharedPreferences for form data
/// * Requirement 7: Help dialog with instructions
/// * Requirement 8: Multi-language support (English/French)
/// 
/// @author Matthew Zhang
class FlightsPage extends StatefulWidget {
  const FlightsPage({super.key});

  @override
  _FlightsPageState createState() => _FlightsPageState();
}

class _FlightsPageState extends State<FlightsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController departureCityController = TextEditingController();
  final TextEditingController destinationCityController = TextEditingController();
  final TextEditingController departureTimeController = TextEditingController();
  final TextEditingController arrivalTimeController = TextEditingController();

  final encryptedPrefs = EncryptedSharedPreferences();
  final FlightDao flightDao = FlightDaoImpl();

  /// List of flights loaded from database
  List<Flight> flights = [];

  /// Currently selected flight for details view
  Flight? _selectedFlight;

  /// Edit mode flag - true when editing existing flight
  bool _isEditMode = false;

  /// Loading state indicator
  bool _isLoading = true;

  /// Language toggle state (false = English, true = French)
  bool _isFrench = false;

  /// View toggle for compressed screen (false = form/list, true = details)
  bool _showDetailsView = false;

  /// Flight being edited (null for new flight)
  Flight? _editingFlight;

  /// Helper method to get text based on current language
  String _getText(String english, String french) {
    return _isFrench ? french : english;
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// Initialize database and load saved form data
  Future<void> _initializeData() async {
    try {
      print('Step 1: Loading language preference...');
      final savedLang = await encryptedPrefs.getString('language') ?? 'en';
      setState(() {
        _isFrench = savedLang == 'fr';
      });

      print('Step 2: Loading form data from preferences...');
      await _loadFormData();

      print('Step 3: Loading flights from database...');
      await _loadFlights();

      print('Flight initialization completed successfully');
    } catch (e, stackTrace) {
      print('Error during flight initialization: $e');
      print('Stack trace: $stackTrace');

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

  /// Load form data from encrypted shared preferences
  Future<void> _loadFormData() async {
    try {
      if (!_isEditMode) {
        final departure = await encryptedPrefs.getString('flight_departure');
        final destination = await encryptedPrefs.getString('flight_destination');
        final departureTime = await encryptedPrefs.getString('flight_departureTime');
        final arrivalTime = await encryptedPrefs.getString('flight_arrivalTime');

        if (mounted) {
          setState(() {
            departureCityController.text = departure ?? '';
            destinationCityController.text = destination ?? '';
            departureTimeController.text = departureTime ?? '';
            arrivalTimeController.text = arrivalTime ?? '';
          });
        }
      }
    } catch (e) {
      print('Warning: Could not load flight form data: $e');
    }
  }

  /// Load all flights from database
  Future<void> _loadFlights() async {
    try {
      final dbFlights = await flightDao.getAllFlights();
      if (mounted) {
        setState(() {
          flights = dbFlights;
        });
      }
      print('Loaded ${dbFlights.length} flights from database');
    } catch (e) {
      print('Error loading flights: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText('Failed to load flights', 'Échec du chargement des vols')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Add new flight to database
  Future<void> _addFlight() async {
    if (!_validateForm()) {
      return;
    }

    try {
      final newFlight = Flight(
        departure: departureCityController.text.trim(),
        destination: destinationCityController.text.trim(),
        departureTime: departureTimeController.text.trim(),
        arrivalTime: arrivalTimeController.text.trim(),
      );

      await flightDao.insertFlight(newFlight);
      await _saveFormData();
      await _loadFlights();
      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText(
                'Flight added successfully!',
                'Vol ajouté avec succès!'
            )),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error adding flight: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText(
                'Error adding flight',
                'Erreur lors de l\'ajout du vol'
            )),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Update existing flight in database
  Future<void> _updateFlight() async {
    if (_editingFlight == null || !_validateForm()) {
      return;
    }

    try {
      final updatedFlight = Flight(
        id: _editingFlight!.id,
        departure: departureCityController.text.trim(),
        destination: destinationCityController.text.trim(),
        departureTime: departureTimeController.text.trim(),
        arrivalTime: arrivalTimeController.text.trim(),
      );

      await flightDao.updateFlight(updatedFlight);
      await _loadFlights();

      if (_selectedFlight?.id == _editingFlight!.id) {
        setState(() {
          _selectedFlight = updatedFlight;
        });
      }

      _exitEditMode();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText(
                'Flight updated successfully!',
                'Vol mis à jour avec succès!'
            )),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error updating flight: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText(
                'Error updating flight',
                'Erreur lors de la mise à jour du vol'
            )),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Save current form data to encrypted preferences
  Future<void> _saveFormData() async {
    try {
      await encryptedPrefs.setString('flight_departure', departureCityController.text);
      await encryptedPrefs.setString('flight_destination', destinationCityController.text);
      await encryptedPrefs.setString('flight_departureTime', departureTimeController.text);
      await encryptedPrefs.setString('flight_arrivalTime', arrivalTimeController.text);
      print('Flight form data saved to encrypted preferences');
    } catch (e) {
      print('Warning: Could not save flight form data: $e');
    }
  }

  /// Validate form input fields
  bool _validateForm() {
    if (departureCityController.text.trim().isEmpty) {
      _showValidationError(_getText('Departure city is required', 'La ville de départ est requise'));
      return false;
    }

    if (destinationCityController.text.trim().isEmpty) {
      _showValidationError(_getText('Destination city is required', 'La ville de destination est requise'));
      return false;
    }

    if (departureTimeController.text.trim().isEmpty) {
      _showValidationError(_getText('Departure time is required', 'L\'heure de départ est requise'));
      return false;
    }

    if (arrivalTimeController.text.trim().isEmpty) {
      _showValidationError(_getText('Arrival time is required', 'L\'heure d\'arrivée est requise'));
      return false;
    }

    return true;
  }

  /// Show validation error message
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
  void _clearForm() {
    departureCityController.clear();
    destinationCityController.clear();
    departureTimeController.clear();
    arrivalTimeController.clear();
    setState(() {
      _isEditMode = false;
      _editingFlight = null;
    });
  }

  /// Enter edit mode for selected flight
  void _enterEditMode(Flight flight) {
    setState(() {
      _isEditMode = true;
      _editingFlight = flight;
      departureCityController.text = flight.departure;
      destinationCityController.text = flight.destination;
      departureTimeController.text = flight.departureTime;
      arrivalTimeController.text = flight.arrivalTime;

      // If on compressed screen, switch to form view
      final isTablet = MediaQuery.of(context).size.width > 720;
      if (!isTablet) {
        _showDetailsView = false;
      }
    });
  }

  /// Exit edit mode and clear form
  void _exitEditMode() {
    _clearForm();
  }

  /// Delete flight from database
  Future<void> _deleteFlight(Flight flight) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_getText('Confirm Deletion', 'Confirmer la suppression')),
          content: Text(_getText(
              'Are you sure you want to delete this flight?',
              'Êtes-vous sûr de vouloir supprimer ce vol?'
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
        await flightDao.deleteFlight(flight.id!);
        await _loadFlights();

        if (_selectedFlight?.id == flight.id) {
          setState(() {
            _selectedFlight = null;
          });
        }

        if (_editingFlight?.id == flight.id) {
          _exitEditMode();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getText(
                  'Flight deleted successfully',
                  'Vol supprimé avec succès'
              )),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        print('Error deleting flight: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_getText(
                  'Error deleting flight',
                  'Erreur lors de la suppression du vol'
              )),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Show help dialog
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_getText('🧭 How to Use', '🧭 Comment utiliser')),
        content: Text(_getText(
            '1. Fill in flight details:\n'
                '   • Departure and destination cities\n'
                '   • Departure and arrival times\n\n'
                '2. Tap "Add Flight" to save the flight\n\n'
                '3. Tap any flight to view details\n\n'
                '4. Use edit/delete buttons to modify flights\n\n'
                '5. Your last entry is saved automatically',
            '1. Remplissez les détails du vol:\n'
                '   • Villes de départ et de destination\n'
                '   • Heures de départ et d\'arrivée\n\n'
                '2. Appuyez sur "Ajouter Vol" pour enregistrer\n\n'
                '3. Appuyez sur n\'importe quel vol pour voir les détails\n\n'
                '4. Utilisez les boutons modifier/supprimer\n\n'
                '5. Votre dernière saisie est enregistrée automatiquement'
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show language selection dialog
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
                  await encryptedPrefs.setString('language', 'en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.check_circle,
                    color: _isFrench ? Colors.blue : Colors.grey),
                title: const Text('Français'),
                onTap: () async {
                  setState(() => _isFrench = true);
                  await encryptedPrefs.setString('language', 'fr');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build responsive layout based on screen size
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
      if (_selectedFlight != null && !_isEditMode && _showDetailsView) {
        return _buildDetailsPanel();
      } else {
        return _buildListAndForm();
      }
    }
  }

  /// Build list and form section
  Widget _buildListAndForm() {
    return Column(
      children: [
        // Add/Edit Flight Form
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode
                    ? _getText('Edit Flight', 'Modifier le vol')
                    : _getText('Add New Flight', 'Ajouter un nouveau vol'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: departureCityController,
                decoration: InputDecoration(
                  labelText: _getText('Departure City', 'Ville de départ'),
                  hintText: _getText('Enter departure city', 'Entrez la ville de départ'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.flight_takeoff),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: destinationCityController,
                decoration: InputDecoration(
                  labelText: _getText('Destination City', 'Ville de destination'),
                  hintText: _getText('Enter destination city', 'Entrez la ville de destination'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.flight_land),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: departureTimeController,
                decoration: InputDecoration(
                  labelText: _getText('Departure Time', 'Heure de départ'),
                  hintText: _getText('e.g., 08:00 AM', 'ex: 08:00'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.schedule),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: arrivalTimeController,
                decoration: InputDecoration(
                  labelText: _getText('Arrival Time', 'Heure d\'arrivée'),
                  hintText: _getText('e.g., 10:30 AM', 'ex: 10:30'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons
              if (_isEditMode) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _updateFlight,
                        icon: const Icon(Icons.save),
                        label: Text(_getText('Update Flight', 'Mettre à jour le vol')),
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
                        onPressed: _addFlight,
                        icon: const Icon(Icons.add),
                        label: Text(_getText('Add Flight', 'Ajouter le vol')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _clearForm,
                      icon: const Icon(Icons.clear),
                      label: Text(_getText('Clear Form', 'Effacer')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Flights List
        Expanded(
          child: flights.isEmpty
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
                  _getText('No flights found', 'Aucun vol trouvé'),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  _getText('Add your first flight using the form above', 'Ajoutez votre premier vol avec le formulaire ci-dessus'),
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: flights.length,
            itemBuilder: (context, index) {
              final flight = flights[index];
              final isSelected = _selectedFlight?.id == flight.id;

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
                    '${flight.departure} → ${flight.destination}',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getText(
                          'Departs: ${flight.departureTime}',
                          'Départ: ${flight.departureTime}'
                      )),
                      Text(_getText(
                          'Arrives: ${flight.arrivalTime}',
                          'Arrivée: ${flight.arrivalTime}'
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
                        onPressed: () => _enterEditMode(flight),
                        tooltip: _getText('Edit flight', 'Modifier le vol'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFlight(flight),
                        tooltip: _getText('Delete flight', 'Supprimer le vol'),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _selectedFlight = _selectedFlight?.id == flight.id ? null : flight;

                      // If on phone and flight selected, show details
                      final isTablet = MediaQuery.of(context).size.width > 720;
                      if (!isTablet && _selectedFlight != null) {
                        _showDetailsView = true;
                      }
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

  /// Build details panel for selected flight
  Widget _buildDetailsPanel() {
    final size = MediaQuery.of(context).size;
    final isPhone = size.width <= 720 || size.width <= size.height;

    if (_selectedFlight == null) {
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
              _getText('Select a flight to view details', 'Sélectionnez un vol pour voir les détails'),
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getText('Tap any flight from the list', 'Appuyez sur un vol de la liste'),
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
                      _selectedFlight = null;
                      _showDetailsView = false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    _getText('Flight Details', 'Détails du vol'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          else
            Text(
              _getText('Flight Details', 'Détails du vol'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 16),

          Center(
            child: Column(
              children: [
                Icon(Icons.flight_takeoff, size: 48, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  '${_selectedFlight!.departure} → ${_selectedFlight!.destination}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildDetailCard(
            icon: Icons.tag,
            title: _getText('Flight ID', 'ID Vol'),
            value: '${_selectedFlight!.id}',
            color: Colors.blue,
          ),
          const SizedBox(height: 12),

          _buildDetailCard(
            icon: Icons.flight_takeoff,
            title: _getText('Departure', 'Départ'),
            value: '${_selectedFlight!.departure} at ${_selectedFlight!.departureTime}',
            color: Colors.green,
          ),
          const SizedBox(height: 12),

          _buildDetailCard(
            icon: Icons.flight_land,
            title: _getText('Arrival', 'Arrivée'),
            value: '${_selectedFlight!.destination} at ${_selectedFlight!.arrivalTime}',
            color: Colors.orange,
          ),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _enterEditMode(_selectedFlight!),
                  icon: const Icon(Icons.edit),
                  label: Text(_getText('Edit Flight', 'Modifier le vol')),
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
                  onPressed: () => _deleteFlight(_selectedFlight!),
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
    final isTablet = MediaQuery.of(context).size.width > 720;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.flight, color: Colors.white),
            const SizedBox(width: 8),
            Text(_getText('Flight Management', 'Gestion des vols')),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // View toggle button for compressed screens
          if (!isTablet) ...[
            IconButton(
              icon: Icon(_showDetailsView ? Icons.list : Icons.info),
              onPressed: () {
                setState(() {
                  _showDetailsView = !_showDetailsView;
                });
              },
              tooltip: _getText(
                  _showDetailsView ? 'Show List' : 'Show Details',
                  _showDetailsView ? 'Afficher la liste' : 'Afficher les détails'
              ),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguageDialog,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      backgroundColor: Colors.blue[50],
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_getText('Loading flights...', 'Chargement des vols...')),
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
    departureCityController.dispose();
    destinationCityController.dispose();
    departureTimeController.dispose();
    arrivalTimeController.dispose();
    super.dispose();
  }
}