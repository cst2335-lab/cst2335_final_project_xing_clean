// lib/database/app_database.dart
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

// Import your entities and DAOs
import '../models/sale_record.dart';
import '../dao/sale_record_dao.dart';

// This annotation tells the code generator where to put the generated code
part 'app_database.g.dart';

/// Main application database configuration
/// Uses Floor library for SQLite database management
///
/// Project Requirements Addressed:
/// * Requirement 3: Database storage for ListView items
/// * Persistent storage that survives app restarts
/// * SQLite implementation as specified in project requirements
/// * CRUD operations for sales management system
///
/// Database Schema:
/// * SaleRecord table with auto-increment primary key
/// * Stores customer ID, car ID, dealership ID, and purchase date
/// * Supports all required database operations (insert, update, delete, query)
@Database(version: 1, entities: [SaleRecord])
abstract class AppDatabase extends FloorDatabase {
  /// Getter for accessing sale record data operations
  /// Provides access to all CRUD operations for sales
  ///
  /// Returns: SaleRecordDao instance for database operations
  SaleRecordDao get saleRecordDao;

  /// Static method to create and initialize the database
  /// Creates a singleton database instance with proper configuration
  ///
  /// This method should be called once in the application lifecycle
  /// to initialize the database connection
  ///
  /// [databaseName] - Name of the database file (default: 'sales_database.db')
  ///
  /// Returns: Future containing the initialized AppDatabase instance
  ///
  /// Throws: Exception if database initialization fails
  static Future<AppDatabase> createDatabase({String databaseName = 'sales_database.db'}) async {
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
  static Future<AppDatabase> createDatabaseWithCallbacks({String databaseName = 'sales_database.db'}) async {
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
      final count = await saleRecordDao.countSaleRecords();
      print('Database health check passed. Current records: ${count ?? 0}');
      return true;
    } catch (e) {
      print('Database health check failed: $e');
      return false;
    }
  }

  /// Method to get total count of sale records
  /// Useful for statistics and monitoring
  /// Handles nullable return from DAO method
  ///
  /// Returns: Future<int> containing the total number of sale records
  Future<int> getTotalSaleRecordsCount() async {
    try {
      final count = await saleRecordDao.countSaleRecords();
      return count ?? 0; // Handle null case
    } catch (e) {
      print('Error getting sale records count: $e');
      return 0;
    }
  }

  /// Method to load all sale records
  /// Wrapper around DAO method for convenience
  ///
  /// Returns: Future<List<SaleRecord>> containing all sale records
  Future<List<SaleRecord>> loadAllSaleRecords() async {
    try {
      return await saleRecordDao.findAllSaleRecords();
    } catch (e) {
      print('Error loading sale records: $e');
      return [];
    }
  }

  /// Method to save a new sale record
  /// Wrapper around DAO insert method with error handling
  ///
  /// [saleRecord] - Sale record to save
  ///
  /// Returns: Future<bool> indicating if save was successful
  Future<bool> saveSaleRecord(SaleRecord saleRecord) async {
    try {
      await saleRecordDao.insertSaleRecord(saleRecord);
      print('Sale record saved successfully');
      return true;
    } catch (e) {
      print('Error saving sale record: $e');
      return false;
    }
  }

  /// Method to update an existing sale record
  /// Wrapper around DAO update method with error handling
  ///
  /// [saleRecord] - Updated sale record
  ///
  /// Returns: Future<bool> indicating if update was successful
  Future<bool> updateSaleRecord(SaleRecord saleRecord) async {
    try {
      await saleRecordDao.updateSaleRecord(saleRecord);
      print('Sale record updated successfully');
      return true;
    } catch (e) {
      print('Error updating sale record: $e');
      return false;
    }
  }

  /// Method to delete a sale record
  /// Wrapper around DAO delete method with error handling
  ///
  /// [saleRecord] - Sale record to delete
  ///
  /// Returns: Future<bool> indicating if deletion was successful
  Future<bool> removeSaleRecord(SaleRecord saleRecord) async {
    try {
      await saleRecordDao.deleteSaleRecord(saleRecord);
      print('Sale record deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting sale record: $e');
      return false;
    }
  }

  /// Method to delete a sale record by ID
  /// Wrapper around DAO delete by ID method with error handling
  ///
  /// [id] - ID of sale record to delete
  ///
  /// Returns: Future<bool> indicating if deletion was successful
  Future<bool> removeSaleRecordById(int id) async {
    try {
      await saleRecordDao.deleteSaleRecordById(id);
      print('Sale record with ID $id deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting sale record by ID: $e');
      return false;
    }
  }
}