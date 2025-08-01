import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../models/customer.dart';
import '../dao/customer_dao.dart';

part 'customer_database.g.dart';

/// Customer database configuration
/// Uses Floor library for SQLite database management
/// Database features:
/// Customer table with auto-increment primary key
/// Stores first name, last name, address, and date of birth
/// Supports all required database operations (insert, update, delete, query)
@Database(version: 1, entities: [Customer])
abstract class CustomerDatabase extends FloorDatabase {
  /// Getter for accessing customer data operations
  /// Provides access to all CRUD operations for customers
  ///
  /// Returns: CustomerDao instance for database operations
  CustomerDao get customerDao;

  /// Static method to create and initialize the database
  /// Creates a singleton database instance with proper configuration
  ///
  /// This method should be called once in the application lifecycle
  /// to initialize the database connection
  ///
  /// [databaseName] - Name of the database file
  ///
  /// Returns: Future containing the initialized CustomerDatabase instance
  ///
  /// Throws: Exception if database initialization fails
  static Future<CustomerDatabase> createDatabase({String databaseName = 'customers_database.db'}) async {
    try {
      return await $FloorCustomerDatabase
          .databaseBuilder(databaseName)
          .build();
    } catch (e) {
      throw Exception('Failed to initialize customer database: $e');
    }
  }

  /// Static method to create database with callback handling
  /// Creates database with proper lifecycle callbacks
  /// [databaseName] - Name of the database file
  ///
  /// Returns: Future containing the initialized CustomerDatabase instance
  static Future<CustomerDatabase> createDatabaseWithCallbacks({String databaseName = 'customers_database.db'}) async {
    try {
      return await $FloorCustomerDatabase
          .databaseBuilder(databaseName)
          .addCallback(Callback(
        onCreate: (database, version) async {
          print('Customer database created successfully with version $version');
        },
        onOpen: (database) async {
          print('Customer database opened successfully');
        },
      ))
          .build();
    } catch (e) {
      throw Exception('Failed to create customer database with callbacks: $e');
    }
  }


  /// Method to close database connection
  /// Called when the application is shutting down
  ///
  /// Properly closes the database connection to prevent data corruption
  /// and release system resources
  Future<void> closeDatabase() async {
    try {
      await close();
      print('Customer database connection closed successfully');
    } catch (e) {
      print('Error closing customer database: $e');
    }
  }

  /// Method to load all customers
  /// Wrapper around DAO method for convenience
  ///
  /// Returns: Future<List<Customer>> containing all customers
  Future<List<Customer>> loadAllCustomers() async {
    try {
      return await customerDao.findAllCustomers();
    } catch (e) {
      print('Error loading customers: $e');
      return [];
    }
  }

  /// Method to save a new customer
  ///
  /// [customer] - Customer to save
  ///
  /// Returns: Future<bool> indicating if save was successful
  Future<bool> saveCustomer(Customer customer) async {
    try {
      await customerDao.insertCustomer(customer);
      print('Customer saved successfully: ${customer.fullName}');
      return true;
    } catch (e) {
      print('Error saving customer: $e');
      return false;
    }
  }

  /// Method to update an existing customer
  ///
  /// [customer] - Updated customer
  ///
  /// Returns: Future<bool> indicating if update was successful
  Future<bool> updateCustomer(Customer customer) async {
    try {
      await customerDao.updateCustomer(customer);
      print('Customer updated successfully: ${customer.fullName}');
      return true;
    } catch (e) {
      print('Error updating customer: $e');
      return false;
    }
  }

  /// Method to delete a customer
  ///
  /// [customer] - Customer to delete
  ///
  /// Returns: Future<bool> indicating if deletion was successful
  Future<bool> removeCustomer(Customer customer) async {
    try {
      await customerDao.deleteCustomer(customer);
      print('Customer deleted successfully: ${customer.fullName}');
      return true;
    } catch (e) {
      print('Error deleting customer: $e');
      return false;
    }
  }

  /// Method to get the most recently added customer
  /// Useful for pre-filling form data with last customer details
  ///
  /// Returns: Future<Customer?> containing the most recent customer
  Future<Customer?> getLatestCustomer() async {
    try {
      return await customerDao.getLatestCustomer();
    } catch (e) {
      print('Error getting latest customer: $e');
      return null;
    }
  }

  /// Method to check for duplicate customers
  /// Prevents adding customers with same name and address
  ///
  /// [firstName] - First name to check
  /// [lastName] - Last name to check
  /// [address] - Address to check
  ///
  /// Returns: Future<bool> indicating if duplicate exists
  Future<bool> isDuplicateCustomer(String firstName, String lastName, String address) async {
    try {
      final count = await customerDao.countDuplicateCustomers(firstName, lastName, address);
      return (count ?? 0) > 0;
    } catch (e) {
      print('Error checking for duplicate customer: $e');
      return false;
    }
  }
}