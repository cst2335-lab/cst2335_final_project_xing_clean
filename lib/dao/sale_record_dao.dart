// lib/dao/sale_record_dao.dart
import 'package:floor/floor.dart';
import '../models/sale_record.dart';

/**
 * Data Access Object for SaleRecord entity
 * Provides database operations for sales records
 *
 * Project Requirements Addressed:
 * - Requirement 3: Database storage and retrieval operations
 * - CRUD operations for sales management
 */
@dao
abstract class SaleRecordDao {
  /**
   * Retrieve all sale records from the database
   * Used to populate ListView with existing records
   * Ordered by ID in descending order (newest first)
   *
   * @return Future containing list of all sale records
   */
  @Query('SELECT * FROM SaleRecord ORDER BY id DESC')
  Future<List<SaleRecord>> findAllSaleRecords();

  /**
   * Insert a new sale record into the database
   * Requirement 2: Insert items into ListView (via database)
   *
   * @param saleRecord - Sale record to insert
   * @return Future that completes when insertion is done
   */
  @insert
  Future<void> insertSaleRecord(SaleRecord saleRecord);

  /**
   * Update an existing sale record in the database
   * Used for modifying sale information
   *
   * @param saleRecord - Updated sale record
   * @return Future that completes when update is done
   */
  @update
  Future<void> updateSaleRecord(SaleRecord saleRecord);

  /**
   * Delete a sale record from the database
   * Used for removing sales from the system
   *
   * @param saleRecord - Sale record to delete
   * @return Future that completes when deletion is done
   */
  @delete
  Future<void> deleteSaleRecord(SaleRecord saleRecord);

  /**
   * Delete a sale record by its ID
   * Alternative deletion method using ID
   *
   * @param id - ID of the sale record to delete
   * @return Future that completes when deletion is done
   */
  @Query('DELETE FROM SaleRecord WHERE id = :id')
  Future<void> deleteSaleRecordById(int id);

  /**
   * Find sale records by customer ID
   * Useful for customer-specific queries
   *
   * @param customerId - Customer ID to search for
   * @return Future containing list of sales for the customer
   */
  @Query('SELECT * FROM SaleRecord WHERE customerId = :customerId ORDER BY id DESC')
  Future<List<SaleRecord>> findSalesByCustomer(int customerId);

  /**
   * Find sale records by car ID
   * Useful for tracking which cars have been sold
   *
   * @param carId - Car ID to search for
   * @return Future containing list of sales for the car
   */
  @Query('SELECT * FROM SaleRecord WHERE carId = :carId ORDER BY id DESC')
  Future<List<SaleRecord>> findSalesByCar(int carId);

  /**
   * Find sale records by dealership ID
   * Useful for dealership performance tracking
   *
   * @param dealershipId - Dealership ID to search for
   * @return Future containing list of sales for the dealership
   */
  @Query('SELECT * FROM SaleRecord WHERE dealershipId = :dealershipId ORDER BY id DESC')
  Future<List<SaleRecord>> findSalesByDealership(int dealershipId);

  /**
   * Count total number of sale records
   * Useful for statistics and reporting
   *
   * @return Future containing the total count of sales
   */
  @Query('SELECT COUNT(*) FROM SaleRecord')
  Future<int?> countSaleRecords();
}