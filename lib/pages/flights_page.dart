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

  int? selectedFlightIndex;
  List<Flight> flights = [];

  /// Language toggle state (false = English, true = French)
  bool _isFrench = false;

  /// Helper method to get text based on current language
  String _getText(String english, String french) {
    return _isFrench ? french : english;
  }

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
    _loadFlights();
    _askReusePreviousFlight();
  }

  /// Load saved language preference
  Future<void> _loadLanguagePreference() async {
    final savedLang = await encryptedPrefs.getString('language') ?? 'en';
    setState(() {
      _isFrench = savedLang == 'fr';
    });
  }

  /// Load all flights from database
  Future<void> _loadFlights() async {
    try {
      final dbFlights = await flightDao.getAllFlights();
      print('Loaded ${dbFlights.length} flights from database'); // 调试信息
      setState(() {
        flights = dbFlights;
      });
    } catch (e) {
      print('Error loading flights: $e');
      _showSnackBar(_getText('❌ Error loading flights', '❌ Erreur de chargement des vols'));
    }
  }

  /// Ask user whether to reuse previous flight data
  /// Requirement 6: EncryptedSharedPreferences usage
  Future<void> _askReusePreviousFlight() async {
    final reuse = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_getText('Reuse Previous Flight?', 'Réutiliser le vol précédent?')),
        content: Text(_getText(
            'Would you like to reuse the last entered flight details?',
            'Voulez-vous réutiliser les détails du dernier vol saisi?'
        )),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(_getText('Start Fresh', 'Recommencer'))
          ),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(_getText('Reuse', 'Réutiliser'))
          ),
        ],
      ),
    );

    if (reuse == true) {
      try {
        departureCityController.text = await encryptedPrefs.getString('flight_departure');
        destinationCityController.text = await encryptedPrefs.getString('flight_destination');
        departureTimeController.text = await encryptedPrefs.getString('flight_departureTime');
        arrivalTimeController.text = await encryptedPrefs.getString('flight_arrivalTime');
      } catch (e) {
        print('Failed to load previous flight: $e');
      }
    }
  }

  /// Save flight data to encrypted preferences
  Future<void> _saveFlightToEncryptedPrefs(Map<String, String> flight) async {
    await encryptedPrefs.setString('flight_departure', flight['departure'] ?? '');
    await encryptedPrefs.setString('flight_destination', flight['destination'] ?? '');
    await encryptedPrefs.setString('flight_departureTime', flight['departureTime'] ?? '');
    await encryptedPrefs.setString('flight_arrivalTime', flight['arrivalTime'] ?? '');
  }

  /// Reset form to initial state
  void _resetForm() {
    departureCityController.clear();
    destinationCityController.clear();
    departureTimeController.clear();
    arrivalTimeController.clear();
    setState(() => selectedFlightIndex = null);
  }

  /// Submit form data to database
  /// Requirement 2: Insert/Update functionality
  /// Requirement 5: Snackbar feedback
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final flight = Flight(
        id: selectedFlightIndex != null ? flights[selectedFlightIndex!].id : null,
        departure: departureCityController.text,
        destination: destinationCityController.text,
        departureTime: departureTimeController.text,
        arrivalTime: arrivalTimeController.text,
      );

      try {
        if (selectedFlightIndex != null) {
          await flightDao.updateFlight(flight);
          _showSnackBar(_getText('✈️ Flight updated successfully!', '✈️ Vol mis à jour avec succès!'));
        } else {
          final insertedId = await flightDao.insertFlight(flight);
          print('Inserted flight with ID: $insertedId'); // 调试信息
          _showSnackBar(_getText('✈️ Flight added successfully!', '✈️ Vol ajouté avec succès!'));
        }

        await _saveFlightToEncryptedPrefs({
          'departure': flight.departure,
          'destination': flight.destination,
          'departureTime': flight.departureTime,
          'arrivalTime': flight.arrivalTime,
        });

        await _loadFlights();
        print('Loaded ${flights.length} flights'); // 调试信息

        _resetForm();
      } catch (e) {
        print('Error submitting form: $e');
        _showSnackBar(_getText('❌ Error saving flight', '❌ Erreur lors de l\'enregistrement'));
      }
    }
  }

  /// Edit existing flight
  void _editFlight(int index) {
    final flight = flights[index];
    departureCityController.text = flight.departure;
    destinationCityController.text = flight.destination;
    departureTimeController.text = flight.departureTime;
    arrivalTimeController.text = flight.arrivalTime;
    setState(() => selectedFlightIndex = index);
  }

  /// Delete flight with confirmation
  /// Requirement 5: AlertDialog for confirmation
  void _deleteFlight(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_getText('Delete Flight?', 'Supprimer le vol?')),
        content: Text(_getText(
            'Are you sure you want to delete this flight?',
            'Êtes-vous sûr de vouloir supprimer ce vol?'
        )),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(_getText('Cancel', 'Annuler'))
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
                _getText('Delete', 'Supprimer'),
                style: const TextStyle(color: Colors.red)
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final flightId = flights[index].id;
      if (flightId != null) {
        await flightDao.deleteFlight(flightId);
        await _loadFlights();
        _resetForm();
        _showSnackBar(_getText('🗑️ Flight deleted', '🗑️ Vol supprimé'));
      }
    }
  }

  /// Show snackbar with message
  /// Requirement 5: Snackbar for user feedback
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
    );
  }

  /// Show help dialog
  /// Requirement 7: Help instructions
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_getText('🧭 How to Use', '🧭 Comment utiliser')),
        content: Text(_getText(
            '1. Fill in flight details:\n'
                '   • Departure and destination cities\n'
                '   • Departure and arrival times\n\n'
                '2. Tap "Submit" to save the flight\n\n'
                '3. Tap any flight to edit or delete it\n\n'
                '4. Your last entry is saved automatically',
            '1. Remplissez les détails du vol:\n'
                '   • Villes de départ et de destination\n'
                '   • Heures de départ et d\'arrivée\n\n'
                '2. Appuyez sur "Soumettre" pour enregistrer\n\n'
                '3. Appuyez sur n\'importe quel vol pour modifier ou supprimer\n\n'
                '4. Votre dernière saisie est enregistrée automatiquement'
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
  /// Requirement 8: Language switching
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

  /// Build text field widget
  Widget _buildTextField(TextEditingController controller, String labelEn, String labelFr) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: _getText(labelEn, labelFr),
        border: const OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.isEmpty
          ? _getText('Please enter $labelEn', 'Veuillez entrer $labelFr')
          : null,
    );
  }

  /// Build responsive layout
  /// Requirement 4: Responsive design for tablet/phone
  Widget _buildResponsiveLayout() {
    final isTablet = MediaQuery.of(context).size.width > 600;

    if (isTablet && selectedFlightIndex != null) {
      // Tablet: Show list and details side by side
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: _buildFlightList(),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 1,
            child: _buildFlightDetails(flights[selectedFlightIndex!]),
          ),
        ],
      );
    } else {
      // Phone: Show list only
      return _buildFlightList();
    }
  }

  /// Build flight details panel for tablets
  Widget _buildFlightDetails(Flight flight) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getText('Flight Details', 'Détails du vol'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('${_getText("From", "De")}: ${flight.departure}'),
            Text('${_getText("To", "À")}: ${flight.destination}'),
            Text('${_getText("Departure", "Départ")}: ${flight.departureTime}'),
            Text('${_getText("Arrival", "Arrivée")}: ${flight.arrivalTime}'),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: Text(_getText('Edit', 'Modifier')),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () => _editFlight(selectedFlightIndex!),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: Text(_getText('Delete', 'Supprimer')),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => _deleteFlight(selectedFlightIndex!),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build flight list
  /// Requirement 1: ListView for displaying flights
  Widget _buildFlightList() {
    if (flights.isEmpty) {
      return Container(
        height: 200, // 给定固定高度
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flight_land, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _getText('No flights added yet.', 'Aucun vol ajouté pour le moment.'),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: flights.length,
      itemBuilder: (context, index) {
        final flight = flights[index];
        final isSelected = selectedFlightIndex == index;

        return Card(
          elevation: isSelected ? 4 : 2,
          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isSelected ? const BorderSide(color: Colors.blue, width: 2) : BorderSide.none,
          ),
          child: ListTile(
            leading: const Icon(Icons.flight_takeoff, color: Colors.blue),
            title: Text('${flight.departure} → ${flight.destination}'),
            subtitle: Text('${_getText("Departs", "Départ")}: ${flight.departureTime} | ${_getText("Arrives", "Arrivée")}: ${flight.arrivalTime}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _editFlight(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteFlight(index),
                ),
              ],
            ),
            onTap: () {
              setState(() => selectedFlightIndex = index);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        selectedFlightIndex == null
                            ? _getText('Add New Flight', 'Ajouter un nouveau vol')
                            : _getText('Update Flight', 'Mettre à jour le vol'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(departureCityController, 'Departure City', 'Ville de départ'),
                      const SizedBox(height: 12),
                      _buildTextField(destinationCityController, 'Destination City', 'Ville de destination'),
                      const SizedBox(height: 12),
                      _buildTextField(departureTimeController, 'Departure Time (e.g. 08:00 AM)', 'Heure de départ (ex: 08:00)'),
                      const SizedBox(height: 12),
                      _buildTextField(arrivalTimeController, 'Arrival Time (e.g. 10:30 AM)', 'Heure d\'arrivée (ex: 10:30)'),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(selectedFlightIndex == null ? Icons.add : Icons.update),
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedFlightIndex == null ? Colors.blue : Colors.orange,
                                minimumSize: const Size.fromHeight(45),
                              ),
                              label: Text(selectedFlightIndex == null
                                  ? _getText('Submit', 'Soumettre')
                                  : _getText('Update', 'Mettre à jour')),
                            ),
                          ),
                          if (selectedFlightIndex != null) ...[
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _resetForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                minimumSize: const Size.fromHeight(45),
                              ),
                              child: Text(_getText('Cancel', 'Annuler')),
                            ),
                          ]
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getText('✈️ All Flights:', '✈️ Tous les vols:'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            _buildResponsiveLayout(),
          ],
        ),
      ),
    );
  }
}