import 'package:floor/floor.dart';
import '../models/customer.dart';

/// Data Access Object for Customer entity
/// Provides database operations for customer management
@dao
abstract class CustomerDao {
  /// Retrieve all customers from the database
  /// Used to populate ListView with existing customers
  ///
  /// Returns: Future containing list of all customers
  @Query('SELECT * FROM Customer ORDER BY lastName ASC, firstName ASC')
  Future<List<Customer>> findAllCustomers();

  /// Insert a new customer into the database
  ///
  /// [customer] - Customer to insert
  ///
  /// Returns: Future that completes when insertion is done
  @insert
  Future<void> insertCustomer(Customer customer);

  /// Update an existing customer in the database
  /// Used for modifying customer information
  ///
  /// [customer] - Updated customer
  ///
  /// Returns: Future that completes when update is done
  @update
  Future<void> updateCustomer(Customer customer);

  /// Delete a customer from the database
  ///
  /// [customer] - Customer to delete
  ///
  /// Returns: Future that completes when deletion is done
  @delete
  Future<void> deleteCustomer(Customer customer);


  /// Get the most recently added customer
  ///
  /// Returns: Future containing the most recent customer or null if none found
  @Query('SELECT * FROM Customer ORDER BY id DESC LIMIT 1')
  Future<Customer?> getLatestCustomer();

  /// Get customer by ID
  /// Useful for retrieving specific customer details
  ///
  /// [id] - Customer ID to retrieve
  ///
  /// Returns: Future containing customer with specified ID or null if not found
  @Query('SELECT * FROM Customer WHERE id = :id')
  Future<Customer?> getCustomerById(int id);

  /// Check if customer exists with the same name and address
  /// Useful for preventing duplicate customer entries
  ///
  /// [firstName] - First name to check
  /// [lastName] - Last name to check
  /// [address] - Address to check
  ///
  /// Returns: Future containing count of matching customers
  @Query('SELECT COUNT(*) FROM Customer WHERE firstName = :firstName AND lastName = :lastName AND address = :address')
  Future<int?> countDuplicateCustomers(String firstName, String lastName, String address);
}