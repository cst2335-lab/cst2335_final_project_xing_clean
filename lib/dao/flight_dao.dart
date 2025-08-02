// flight_dao.dart
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../models/flight.dart';

/// DAO implementation for flights with Windows/Desktop support
///
/// Provides database operations for flight records with cross-platform support
/// including Windows, Linux, and macOS desktop platforms
///
/// @author Matthew Zhang
abstract class FlightDao {
  /// Insert a new flight into the database
  Future<int> insertFlight(Flight flight);

  /// Get all flights from the database
  Future<List<Flight>> getAllFlights();

  /// Update an existing flight
  Future<int> updateFlight(Flight flight);

  /// Delete a flight by ID
  Future<int> deleteFlight(int id);
}

/// Concrete implementation of FlightDao
class FlightDaoImpl implements FlightDao {
  static final FlightDaoImpl _instance = FlightDaoImpl._internal();
  factory FlightDaoImpl() => _instance;
  FlightDaoImpl._internal() {
    _initializeDatabase();
  }

  Database? _db;

  /// Initialize database for desktop platforms
  void _initializeDatabase() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Initialize FFI for desktop platforms
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      print('Initialized sqflite FFI for desktop platform');
    }
  }

  /// Get database instance
  Future<Database> get database async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }
    _db = await _initDb();
    return _db!;
  }

  /// Initialize the database
  Future<Database> _initDb() async {
    try {
      String path;

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // For desktop platforms, use a specific directory
        final Directory appDocDir = Directory.current;
        final String appDocPath = join(appDocDir.path, 'database');

        // Create directory if it doesn't exist
        if (!await Directory(appDocPath).exists()) {
          await Directory(appDocPath).create(recursive: true);
        }

        path = join(appDocPath, 'flights.db');
        print('Desktop database path: $path');
      } else {
        // For mobile platforms
        path = join(await getDatabasesPath(), 'flights.db');
        print('Mobile database path: $path');
      }

      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          print('Creating flights table...');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS flights (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              departure TEXT NOT NULL,
              destination TEXT NOT NULL,
              departureTime TEXT NOT NULL,
              arrivalTime TEXT NOT NULL
            )
          ''');
          print('Flights table created successfully');
        },
        onOpen: (db) async {
          print('Database opened successfully');
          // Verify table exists
          final tables = await db.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table' AND name='flights'"
          );
          print('Tables found: $tables');
        },
      );
    } catch (e) {
      print('Error initializing database: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  @override
  Future<int> insertFlight(Flight flight) async {
    try {
      final db = await database;
      final flightMap = flight.toMap();

      // Remove id from map for insert
      final insertMap = Map<String, dynamic>.from(flightMap);
      insertMap.remove('id');

      print('Inserting flight: $insertMap');
      final id = await db.insert(
        'flights',
        insertMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Successfully inserted flight with ID: $id');

      // Verify insertion
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM flights')
      );
      print('Total flights in database: $count');

      return id;
    } catch (e) {
      print('Error inserting flight: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  @override
  Future<List<Flight>> getAllFlights() async {
    try {
      final db = await database;
      print('Querying all flights...');

      final List<Map<String, dynamic>> maps = await db.query(
        'flights',
        orderBy: 'id DESC',
      );

      print('Query returned ${maps.length} flights');

      if (maps.isEmpty) {
        print('No flights found in database');
        return [];
      }

      // Print each flight for debugging
      for (var i = 0; i < maps.length; i++) {
        print('Flight ${i + 1}: ${maps[i]}');
      }

      final flights = maps.map((map) {
        try {
          return Flight.fromMap(map);
        } catch (e) {
          print('Error parsing flight from map: $map');
          print('Error: $e');
          rethrow;
        }
      }).toList();

      print('Successfully parsed ${flights.length} flights');
      return flights;

    } catch (e) {
      print('Error getting all flights: $e');
      print('Stack trace: ${StackTrace.current}');
      return []; // Return empty list instead of throwing
    }
  }

  @override
  Future<int> updateFlight(Flight flight) async {
    try {
      final db = await database;
      print('Updating flight with ID ${flight.id}: ${flight.toMap()}');

      final result = await db.update(
        'flights',
        flight.toMap(),
        where: 'id = ?',
        whereArgs: [flight.id],
      );

      print('Update result: $result rows affected');
      return result;
    } catch (e) {
      print('Error updating flight: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  @override
  Future<int> deleteFlight(int id) async {
    try {
      final db = await database;
      print('Deleting flight with ID: $id');

      final result = await db.delete(
        'flights',
        where: 'id = ?',
        whereArgs: [id],
      );

      print('Delete result: $result rows affected');
      return result;
    } catch (e) {
      print('Error deleting flight: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Close the database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
    print('Database closed');
  }

  /// Delete the database (for testing/debugging)
  Future<void> deleteDatabase() async {
    try {
      String path;

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final Directory appDocDir = Directory.current;
        path = join(appDocDir.path, 'database', 'flights.db');
      } else {
        path = join(await getDatabasesPath(), 'flights.db');
      }

      if (await File(path).exists()) {
        await File(path).delete();
        print('Database deleted at: $path');
      }

      _db = null;
    } catch (e) {
      print('Error deleting database: $e');
    }
  }
}