// flight_dao.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/flight.dart';

/// DAO implementation for flights.
///
/// @author Matthew Zhang


abstract class FlightDao {
  Future<int> insertFlight(Flight flight);
  Future<List<Flight>> getAllFlights();
  Future<int> updateFlight(Flight flight);
  Future<int> deleteFlight(int id);
}

class FlightDaoImpl implements FlightDao {
  static final FlightDaoImpl _instance = FlightDaoImpl._internal();
  factory FlightDaoImpl() => _instance;
  FlightDaoImpl._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'flights.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE flights (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            departure TEXT,
            destination TEXT,
            departureTime TEXT,
            arrivalTime TEXT
          )
        ''');
      },
    );
  }

  @override
  Future<int> insertFlight(Flight flight) async {
    final db = await database;
    return await db.insert('flights', flight.toMap());
  }

  @override
  Future<List<Flight>> getAllFlights() async {
    final db = await database;
    final maps = await db.query('flights');
    return maps.map((map) => Flight.fromMap(map)).toList();
  }

  @override
  Future<int> updateFlight(Flight flight) async {
    final db = await database;
    return await db.update(
      'flights',
      flight.toMap(),
      where: 'id = ?',
      whereArgs: [flight.id],
    );
  }

  @override
  Future<int> deleteFlight(int id) async {
    final db = await database;
    return await db.delete('flights', where: 'id = ?', whereArgs: [id]);
  }
}
