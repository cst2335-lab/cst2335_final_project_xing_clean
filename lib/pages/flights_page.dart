
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../dao/flight_dao.dart';
import '../models/flight.dart';




///Page for booking flights
///
///@author Matthew Zhang
///
///

class FlightsPage extends StatefulWidget {
  @override
  _FlightsPageState createState() => _FlightsPageState();
}

final encryptedPrefs = EncryptedSharedPreferences();
final FlightDao flightDao = FlightDaoImpl();

class _FlightsPageState extends State<FlightsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController departureCityController = TextEditingController();
  final TextEditingController destinationCityController = TextEditingController();
  final TextEditingController departureTimeController = TextEditingController();
  final TextEditingController arrivalTimeController = TextEditingController();

  int? selectedFlightIndex;
  List<Flight> flights = [];

  @override
  void initState() {
    super.initState();
    _loadFlights();
    _askReusePreviousFlight();
  }

  Future<void> _loadFlights() async {
    final dbFlights = await flightDao.getAllFlights();
    setState(() => flights = dbFlights);
  }

  Future<void> _askReusePreviousFlight() async {
    final reuse = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reuse Previous Flight?'),
        content: Text('Would you like to reuse the last entered flight details?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Start Fresh')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Reuse')),
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
        print('Failed to load previous flight: \$e');
      }
    }
  }

  Future<void> _saveFlightToEncryptedPrefs(Map<String, String> flight) async {
    await encryptedPrefs.setString('flight_departure', flight['departure'] ?? '');
    await encryptedPrefs.setString('flight_destination', flight['destination'] ?? '');
    await encryptedPrefs.setString('flight_departureTime', flight['departureTime'] ?? '');
    await encryptedPrefs.setString('flight_arrivalTime', flight['arrivalTime'] ?? '');
  }

  void _resetForm() {
    departureCityController.clear();
    destinationCityController.clear();
    departureTimeController.clear();
    arrivalTimeController.clear();
    setState(() => selectedFlightIndex = null);
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final flight = Flight(
        id: selectedFlightIndex != null ? flights[selectedFlightIndex!].id : null,
        departure: departureCityController.text,
        destination: destinationCityController.text,
        departureTime: departureTimeController.text,
        arrivalTime: arrivalTimeController.text,
      );

      if (selectedFlightIndex != null) {
        await flightDao.updateFlight(flight);
      } else {
        await flightDao.insertFlight(flight);
      }

      await _saveFlightToEncryptedPrefs({
        'departure': flight.departure,
        'destination': flight.destination,
        'departureTime': flight.departureTime,
        'arrivalTime': flight.arrivalTime,
      });

      await _loadFlights();
      _resetForm();
    }
  }

  void _editFlight(int index) {
    final flight = flights[index];
    departureCityController.text = flight.departure;
    destinationCityController.text = flight.destination;
    departureTimeController.text = flight.departureTime;
    arrivalTimeController.text = flight.arrivalTime;
    setState(() => selectedFlightIndex = index);
  }

  void _deleteFlight(int index) async {
    final flightId = flights[index].id;
    if (flightId != null) {
      await flightDao.deleteFlight(flightId);
      await _loadFlights();
      _resetForm();
    }
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value == null || value.isEmpty ? 'Please enter \$label' : null,
    );
  }

  Widget _buildFlightList() {
    if (flights.isEmpty) return Text('No flights added yet.');
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: flights.length,
      itemBuilder: (context, index) {
        final  flight = flights[index];
        return Card(
          child: ListTile(
            title: Text('\${flight.departure} → \${flight.destination}'),
            subtitle: Text('Departs: \${flight.departureTime} | Arrives: \${flight.arrivalTime}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _editFlight(index)),
                IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteFlight(index)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flight Management')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
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
                        selectedFlightIndex == null ? 'Add New Flight' : 'Update Flight',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(departureCityController, 'Departure City'),
                      SizedBox(height: 12),
                      _buildTextField(destinationCityController, 'Destination City'),
                      SizedBox(height: 12),
                      _buildTextField(departureTimeController, 'Departure Time (e.g. 08:00 AM)'),
                      SizedBox(height: 12),
                      _buildTextField(arrivalTimeController, 'Arrival Time (e.g. 10:30 AM)'),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              child: Text(selectedFlightIndex == null ? 'Submit' : 'Update'),
                            ),
                          ),
                          if (selectedFlightIndex != null) ...[
                            SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _resetForm,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                              child: Text('Cancel'),
                            ),
                          ]
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            _buildFlightList(),
          ],
        ),
      ),
    );
  }
}
