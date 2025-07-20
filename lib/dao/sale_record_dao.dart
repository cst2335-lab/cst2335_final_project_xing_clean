// lib/dao/sale_record_dao.dart
import 'package:floor/floor.dart';
import '../models/sale_record.dart';

/// Data Access Object for SaleRecord entity
/// Provides database operations for sales records
///
/// Project Requirements Addressed:
/// * Requirement 3: Database storage and retrieval operations
/// * CRUD operations for sales management
@dao
abstract class SaleRecordDao {
  /// Retrieve all sale records from the database
  /// Used to populate ListView with existing records
  /// Ordered by ID in descending order (newest first)
  ///
  /// Returns: Future containing list of all sale records
  @Query('SELECT * FROM SaleRecord ORDER BY id DESC')
  Future<List<SaleRecord>> findAllSaleRecords();

  /// Insert a new sale record into the database
  /// Requirement 2: Insert items into ListView (via database)
  ///
  /// [saleRecord] - Sale record to insert
  ///
  /// Returns: Future that completes when insertion is done
  @insert
  Future<void> insertSaleRecord(SaleRecord saleRecord);

  /// Update an existing sale record in the database
  /// Used for modifying sale information
  ///
  /// [saleRecord] - Updated sale record
  ///
  /// Returns: Future that completes when update is done
  @update
  Future<void> updateSaleRecord(SaleRecord saleRecord);

  /// Delete a sale record from the database
  /// Used for removing sales from the system
  ///
  /// [saleRecord] - Sale record to delete
  ///
  /// Returns: Future that completes when deletion is done
  @delete
  Future<void> deleteSaleRecord(SaleRecord saleRecord);

  /// Delete a sale record by its ID
  /// Alternative deletion method using ID
  ///
  /// [id] - ID of the sale record to delete
  ///
  /// Returns: Future that completes when deletion is done
  @Query('DELETE FROM SaleRecord WHERE id = :id')
  Future<void> deleteSaleRecordById(int id);

  /// Find sale records by customer ID
  /// Useful for customer-specific queries
  ///
  /// [customerId] - Customer ID to search for
  ///
  /// Returns: Future containing list of sales for the customer
  @Query('SELECT * FROM SaleRecord WHERE customerId = :customerId ORDER BY id DESC')
  Future<List<SaleRecord>> findSalesByCustomer(int customerId);

  /// Find sale records by car ID
  /// Useful for tracking which cars have been sold
  ///
  /// [carId] - Car ID to search for
  ///
  /// Returns: Future containing list of sales for the car
  @Query('SELECT * FROM SaleRecord WHERE carId = :carId ORDER BY id DESC')
  Future<List<SaleRecord>> findSalesByCar(int carId);

  /// Find sale records by dealership ID
  /// Useful for dealership performance tracking
  ///
  /// [dealershipId] - Dealership ID to search for
  ///
  /// Returns: Future containing list of sales for the dealership
  @Query('SELECT * FROM SaleRecord WHERE dealershipId = :dealershipId ORDER BY id DESC')
  Future<List<SaleRecord>> findSalesByDealership(int dealershipId);

  /// Count total number of sale records
  /// Useful for statistics and reporting
  ///
  /// Returns: Future containing the total count of sales
  @Query('SELECT COUNT(*) FROM SaleRecord')
  Future<int?> countSaleRecords();

  /// Find sale records by date range
  /// Useful for period-based reporting
  ///
  /// [startDate] - Start date in YYYY-MM-DD format
  /// [endDate] - End date in YYYY-MM-DD format
  ///
  /// Returns: Future containing list of sales in the date range
  @Query('SELECT * FROM SaleRecord WHERE purchaseDate >= :startDate AND purchaseDate <= :endDate ORDER BY purchaseDate DESC')
  Future<List<SaleRecord>> findSalesByDateRange(String startDate, String endDate);
}