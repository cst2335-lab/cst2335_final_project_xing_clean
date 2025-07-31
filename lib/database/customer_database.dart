// lib/database/customer_database.dart
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

// Import your entities and DAOs
import '../models/customer.dart';
import '../dao/customer_dao.dart';

// This annotation tells the code generator where to put the generated code
part 'customer_database.g.dart';

/// Customer database configuration
/// Uses Floor library for SQLite database management
///
/// Project Requirements Addressed:
/// * Requirement 3: Database storage for ListView items
/// * Persistent storage that survives app restarts
/// * SQLite implementation as specified in project requirements
/// * CRUD operations for customer management system
///
/// Database Schema:
/// * Customer table with auto-increment primary key
/// * Stores first name, last name, address, and date of birth
/// * Supports all required database operations (insert, update, delete, query)
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
  /// [databaseName] - Name of the database file (default: 'customers_database.db')
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
  ///
  /// Includes callbacks for database creation and opening events
  /// Useful for debugging and monitoring database operations
  ///
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

  /// Static method for development/testing database
  /// Creates an in-memory database for testing purposes
  ///
  /// This database will be destroyed when the app closes
  /// Useful for unit testing and development
  ///
  /// Returns: Future containing the in-memory CustomerDatabase instance
  static Future<CustomerDatabase> createInMemoryDatabase() async {
    try {
      return await $FloorCustomerDatabase.inMemoryDatabaseBuilder().build();
    } catch (e) {
      throw Exception('Failed to create in-memory customer database: $e');
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
      print('Customer database connection closed successfully');
    } catch (e) {
      print('Error closing customer database: $e');
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
      final count = await customerDao.countCustomers();
      print('Customer database health check passed. Current customers: ${count ?? 0}');
      return true;
    } catch (e) {
      print('Customer database health check failed: $e');
      return false;
    }
  }

  /// Method to get total count of customers
  /// Useful for statistics and monitoring
  /// Handles nullable return from DAO method
  ///
  /// Returns: Future<int> containing the total number of customers
  Future<int> getTotalCustomersCount() async {
    try {
      final count = await customerDao.countCustomers();
      return count ?? 0; // Handle null case
    } catch (e) {
      print('Error getting customers count: $e');
      return 0;
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
  /// Wrapper around DAO insert method with error handling
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
  /// Wrapper around DAO update method with error handling
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
  /// Wrapper around DAO delete method with error handling
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

  /// Method to delete a customer by ID
  /// Wrapper around DAO delete by ID method with error handling
  ///
  /// [id] - ID of customer to delete
  ///
  /// Returns: Future<bool> indicating if deletion was successful
  Future<bool> removeCustomerById(int id) async {
    try {
      await customerDao.deleteCustomerById(id);
      print('Customer with ID $id deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting customer by ID: $e');
      return false;
    }
  }

  /// Method to search customers by name
  /// Allows users to find customers by partial name matching
  ///
  /// [searchTerm] - Search term (use % for wildcard matching)
  ///
  /// Returns: Future<List<Customer>> containing matching customers
  Future<List<Customer>> searchCustomersByName(String searchTerm) async {
    try {
      final wildcardTerm = '%$searchTerm%'; // Add wildcards for partial matching
      return await customerDao.searchCustomersByName(wildcardTerm);
    } catch (e) {
      print('Error searching customers by name: $e');
      return [];
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

  /// Method to get customers with birthdays in current month
  /// Useful for birthday reminders
  ///
  /// Returns: Future<List<Customer>> containing customers with birthdays this month
  Future<List<Customer>> getCustomersWithBirthdaysThisMonth() async {
    try {
      final now = DateTime.now();
      final month = now.month.toString().padLeft(2, '0');
      return await customerDao.findCustomersByBirthMonth(month);
    } catch (e) {
      print('Error getting customers with birthdays this month: $e');
      return [];
    }
  }

  /// Method to get customers with birthdays today
  /// Useful for daily birthday notifications
  ///
  /// Returns: Future<List<Customer>> containing customers with birthday today
  Future<List<Customer>> getCustomersWithBirthdayToday() async {
    try {
      final now = DateTime.now();
      final monthDay = '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      return await customerDao.findCustomersWithBirthdayToday(monthDay);
    } catch (e) {
      print('Error getting customers with birthday today: $e');
      return [];
    }
  }
}