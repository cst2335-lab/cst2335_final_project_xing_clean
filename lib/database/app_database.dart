// lib/database/app_database.dart
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

// Import your entities and DAOs
import '../models/reservation.dart';
import '../dao/reservation_dao.dart';

// This annotation tells the code generator where to put the generated code
part 'app_database.g.dart';

/// Main application database configuration
/// Uses Floor library for SQLite database management
///
/// Project Requirements Addressed:
/// * Requirement 3: Database storage for ListView items
/// * Persistent storage that survives app restarts
/// * SQLite implementation as specified in project requirements
/// * CRUD operations for flight reservation management system
///
/// Database Schema:
/// * Reservation table with auto-increment primary key
/// * Stores customer ID, flight ID, flight date, and reservation name
/// * Supports all required database operations (insert, update, delete, query)
@Database(version: 1, entities: [Reservation])
abstract class AppDatabase extends FloorDatabase {
  /// Getter for accessing reservation data operations
  /// Provides access to all CRUD operations for reservations
  ///
  /// Returns: ReservationDao instance for database operations
  ReservationDao get reservationDao;

  /// Static method to create and initialize the database
  /// Creates a singleton database instance with proper configuration
  ///
  /// This method should be called once in the application lifecycle
  /// to initialize the database connection
  ///
  /// [databaseName] - Name of the database file (default: 'reservations_database.db')
  ///
  /// Returns: Future containing the initialized AppDatabase instance
  ///
  /// Throws: Exception if database initialization fails
  static Future<AppDatabase> createDatabase({String databaseName = 'reservations_database.db'}) async {
    try {
      return await $FloorAppDatabase
          .databaseBuilder(databaseName)
          .build();
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }

  /// Static method to create database with callback handling
  /// Creates database with proper lifecycle callbacks
  ///
  /// Includes callbacks for database creation and opening events
  /// Useful for debugging and monitoring database operations
  ///
  /// [databaseName] - Name of the database file
  ///
  /// Returns: Future containing the initialized AppDatabase instance
  static Future<AppDatabase> createDatabaseWithCallbacks({String databaseName = 'reservations_database.db'}) async {
    try {
      return await $FloorAppDatabase
          .databaseBuilder(databaseName)
          .addCallback(Callback(
        onCreate: (database, version) async {
          print('Database created successfully with version $version');
        },
        onOpen: (database) async {
          print('Database opened successfully');
        },
      ))
          .build();
    } catch (e) {
      throw Exception('Failed to create database with callbacks: $e');
    }
  }

  /// Static method for development/testing database
  /// Creates an in-memory database for testing purposes
  ///
  /// This database will be destroyed when the app closes
  /// Useful for unit testing and development
  ///
  /// Returns: Future containing the in-memory AppDatabase instance
  static Future<AppDatabase> createInMemoryDatabase() async {
    try {
      return await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
    } catch (e) {
      throw Exception('Failed to create in-memory database: $e');
    }
  }

  /// Method to close database connection
  /// Should be called when the application is shutting down
  ///
  /// Properly closes the database connection to prevent data corruption
  /// and release system resources
  Future<void> closeDatabase() async {
    try {
      await close();
      print('Database connection closed successfully');
    } catch (e) {
      print('Error closing database: $e');
    }
  }

  /// Method to perform database health check
  /// Validates that the database is accessible and functional
  ///
  /// Tests basic database operations to ensure everything is working
  ///
  /// Returns: Future<bool> indicating if database is healthy
  Future<bool> performHealthCheck() async {
    try {
      // Try to perform a simple count operation to test database access
      final count = await reservationDao.countReservations();
      print('Database health check passed. Current reservations: ${count ?? 0}');
      return true;
    } catch (e) {
      print('Database health check failed: $e');
      return false;
    }
  }

  /// Method to get total count of reservations
  /// Useful for statistics and monitoring
  /// Handles nullable return from DAO method
  ///
  /// Returns: Future<int> containing the total number of reservations
  Future<int> getTotalReservationsCount() async {
    try {
      final count = await reservationDao.countReservations();
      return count ?? 0; // Handle null case
    } catch (e) {
      print('Error getting reservations count: $e');
      return 0;
    }
  }

  /// Method to load all reservations
  /// Wrapper around DAO method for convenience
  ///
  /// Returns: Future<List<Reservation>> containing all reservations
  Future<List<Reservation>> loadAllReservations() async {
    try {
      return await reservationDao.findAllReservations();
    } catch (e) {
      print('Error loading reservations: $e');
      return [];
    }
  }

  /// Method to save a new reservation
  /// Wrapper around DAO insert method with error handling
  ///
  /// [reservation] - Reservation to save
  ///
  /// Returns: Future<bool> indicating if save was successful
  Future<bool> saveReservation(Reservation reservation) async {
    try {
      await reservationDao.insertReservation(reservation);
      print('Reservation saved successfully');
      return true;
    } catch (e) {
      print('Error saving reservation: $e');
      return false;
    }
  }

  /// Method to update an existing reservation
  /// Wrapper around DAO update method with error handling
  ///
  /// [reservation] - Updated reservation
  ///
  /// Returns: Future<bool> indicating if update was successful
  Future<bool> updateReservation(Reservation reservation) async {
    try {
      await reservationDao.updateReservation(reservation);
      print('Reservation updated successfully');
      return true;
    } catch (e) {
      print('Error updating reservation: $e');
      return false;
    }
  }

  /// Method to delete a reservation
  /// Wrapper around DAO delete method with error handling
  ///
  /// [reservation] - Reservation to delete
  ///
  /// Returns: Future<bool> indicating if deletion was successful
  Future<bool> removeReservation(Reservation reservation) async {
    try {
      await reservationDao.deleteReservation(reservation);
      print('Reservation deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting reservation: $e');
      return false;
    }
  }

  /// Method to delete a reservation by ID
  /// Wrapper around DAO delete by ID method with error handling
  ///
  /// [id] - ID of reservation to delete
  ///
  /// Returns: Future<bool> indicating if deletion was successful
  Future<bool> removeReservationById(int id) async {
    try {
      await reservationDao.deleteReservationById(id);
      print('Reservation with ID $id deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting reservation by ID: $e');
      return false;
    }
  }

  /// Method to search reservations by customer ID
  /// Convenient wrapper for customer-specific queries
  ///
  /// [customerId] - Customer ID to search for
  ///
  /// Returns: Future<List<Reservation>> containing customer's reservations
  Future<List<Reservation>> getReservationsForCustomer(int customerId) async {
    try {
      return await reservationDao.findReservationsByCustomer(customerId);
    } catch (e) {
      print('Error getting reservations for customer $customerId: $e');
      return [];
    }
  }

  /// Method to search reservations by flight ID
  /// Convenient wrapper for flight-specific queries
  ///
  /// [flightId] - Flight ID to search for
  ///
  /// Returns: Future<List<Reservation>> containing flight's reservations
  Future<List<Reservation>> getReservationsForFlight(int flightId) async {
    try {
      return await reservationDao.findReservationsByFlight(flightId);
    } catch (e) {
      print('Error getting reservations for flight $flightId: $e');
      return [];
    }
  }

  /// Method to get reservations for a specific date
  /// Useful for daily reports and scheduling
  ///
  /// [date] - Date in YYYY-MM-DD format
  ///
  /// Returns: Future<List<Reservation>> containing date's reservations
  Future<List<Reservation>> getReservationsForDate(String date) async {
    try {
      return await reservationDao.findReservationsByDate(date);
    } catch (e) {
      print('Error getting reservations for date $date: $e');
      return [];
    }
  }

  /// Method to search reservations by name
  /// Allows users to find reservations by friendly names
  ///
  /// [searchTerm] - Search term (use % for wildcard matching)
  ///
  /// Returns: Future<List<Reservation>> containing matching reservations
  Future<List<Reservation>> searchReservationsByName(String searchTerm) async {
    try {
      final wildcardTerm = '%$searchTerm%'; // Add wildcards for partial matching
      return await reservationDao.searchReservationsByName(wildcardTerm);
    } catch (e) {
      print('Error searching reservations by name: $e');
      return [];
    }
  }

  /// Method to get upcoming reservations
  /// Shows reservations for future dates
  ///
  /// Returns: Future<List<Reservation>> containing upcoming reservations
  Future<List<Reservation>> getUpcomingReservations() async {
    try {
      final today = DateTime.now().toString().split(' ')[0]; // Get YYYY-MM-DD format
      return await reservationDao.getUpcomingReservations(today);
    } catch (e) {
      print('Error getting upcoming reservations: $e');
      return [];
    }
  }

  /// Method to get past reservations
  /// Shows reservation history
  ///
  /// Returns: Future<List<Reservation>> containing past reservations
  Future<List<Reservation>> getPastReservations() async {
    try {
      final today = DateTime.now().toString().split(' ')[0]; // Get YYYY-MM-DD format
      return await reservationDao.getPastReservations(today);
    } catch (e) {
      print('Error getting past reservations: $e');
      return [];
    }
  }
}