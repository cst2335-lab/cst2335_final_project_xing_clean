// lib/dao/customer_dao.dart
import 'package:floor/floor.dart';
import '../models/customer.dart';

/// Data Access Object for Customer entity
/// Provides database operations for customer management
///
/// Project Requirements Addressed:
/// * Requirement 3: Database storage and retrieval operations
/// * CRUD operations for customer management
@dao
abstract class CustomerDao {
  /// Retrieve all customers from the database
  /// Used to populate ListView with existing customers
  /// Ordered by last name, then first name for alphabetical sorting
  ///
  /// Returns: Future containing list of all customers
  @Query('SELECT * FROM Customer ORDER BY lastName ASC, firstName ASC')
  Future<List<Customer>> findAllCustomers();

  /// Insert a new customer into the database
  /// Requirement 2: Insert items into ListView (via database)
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
  /// Used for removing customers from the system
  ///
  /// [customer] - Customer to delete
  ///
  /// Returns: Future that completes when deletion is done
  @delete
  Future<void> deleteCustomer(Customer customer);

  /// Delete a customer by their ID
  /// Alternative deletion method using ID
  ///
  /// [id] - ID of the customer to delete
  ///
  /// Returns: Future that completes when deletion is done
  @Query('DELETE FROM Customer WHERE id = :id')
  Future<void> deleteCustomerById(int id);

  /// Find customers by first name
  /// Useful for searching customers by first name
  ///
  /// [firstName] - First name to search for
  ///
  /// Returns: Future containing list of customers with matching first name
  @Query('SELECT * FROM Customer WHERE firstName = :firstName ORDER BY lastName ASC')
  Future<List<Customer>> findCustomersByFirstName(String firstName);

  /// Find customers by last name
  /// Useful for searching customers by last name
  ///
  /// [lastName] - Last name to search for
  ///
  /// Returns: Future containing list of customers with matching last name
  @Query('SELECT * FROM Customer WHERE lastName = :lastName ORDER BY firstName ASC')
  Future<List<Customer>> findCustomersByLastName(String lastName);

  /// Search customers by name (first or last name contains search term)
  /// Useful for finding customers with partial name matching
  ///
  /// [searchTerm] - Search term to look for in names (use % for wildcards)
  ///
  /// Returns: Future containing list of matching customers
  @Query('SELECT * FROM Customer WHERE firstName LIKE :searchTerm OR lastName LIKE :searchTerm ORDER BY lastName ASC, firstName ASC')
  Future<List<Customer>> searchCustomersByName(String searchTerm);

  /// Find customers by address
  /// Useful for location-based customer queries
  ///
  /// [address] - Address to search for
  ///
  /// Returns: Future containing list of customers with matching address
  @Query('SELECT * FROM Customer WHERE address LIKE :address ORDER BY lastName ASC')
  Future<List<Customer>> findCustomersByAddress(String address);

  /// Find customers by date of birth
  /// Useful for birthday-related queries
  ///
  /// [dateOfBirth] - Date of birth to search for (YYYY-MM-DD format)
  ///
  /// Returns: Future containing list of customers with matching birth date
  @Query('SELECT * FROM Customer WHERE dateOfBirth = :dateOfBirth ORDER BY lastName ASC')
  Future<List<Customer>> findCustomersByDateOfBirth(String dateOfBirth);

  /// Count total number of customers
  /// Useful for statistics and reporting
  ///
  /// Returns: Future containing the total count of customers
  @Query('SELECT COUNT(*) FROM Customer')
  Future<int?> countCustomers();

  /// Find customers by age range (birth year)
  /// Useful for demographic analysis
  ///
  /// [startYear] - Start year (YYYY format)
  /// [endYear] - End year (YYYY format)
  ///
  /// Returns: Future containing list of customers born between years
  @Query('SELECT * FROM Customer WHERE substr(dateOfBirth, 1, 4) >= :startYear AND substr(dateOfBirth, 1, 4) <= :endYear ORDER BY dateOfBirth DESC')
  Future<List<Customer>> findCustomersByAgeRange(String startYear, String endYear);

  /// Find customer by exact full name
  /// Useful for checking duplicate names
  ///
  /// [firstName] - First name to search for
  /// [lastName] - Last name to search for
  ///
  /// Returns: Future containing list of customers with exact name match
  @Query('SELECT * FROM Customer WHERE firstName = :firstName AND lastName = :lastName ORDER BY id DESC')
  Future<List<Customer>> findCustomersByFullName(String firstName, String lastName);

  /// Get the most recently added customer
  /// Useful for pre-filling form data with last customer details
  ///
  /// Returns: Future containing the most recent customer or null if none found
  @Query('SELECT * FROM Customer ORDER BY id DESC LIMIT 1')
  Future<Customer?> getLatestCustomer();

  /// Find customers with birthdays in a specific month
  /// Useful for birthday reminders and marketing
  ///
  /// [month] - Month number (01-12)
  ///
  /// Returns: Future containing list of customers born in the specified month
  @Query('SELECT * FROM Customer WHERE substr(dateOfBirth, 6, 2) = :month ORDER BY substr(dateOfBirth, 9, 2) ASC')
  Future<List<Customer>> findCustomersByBirthMonth(String month);

  /// Find customers with today's birthday
  /// Useful for daily birthday notifications
  ///
  /// [monthDay] - Month and day in MM-DD format
  ///
  /// Returns: Future containing list of customers with birthday today
  @Query('SELECT * FROM Customer WHERE substr(dateOfBirth, 6, 5) = :monthDay ORDER BY lastName ASC')
  Future<List<Customer>> findCustomersWithBirthdayToday(String monthDay);

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