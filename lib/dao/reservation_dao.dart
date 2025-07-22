// lib/dao/reservation_dao.dart
import 'package:floor/floor.dart';
import '../models/reservation.dart';

/// Data Access Object for Reservation entity
/// Provides database operations for flight reservations
///
/// Project Requirements Addressed:
/// * Requirement 3: Database storage and retrieval operations
/// * CRUD operations for reservation management
@dao
abstract class ReservationDao {
  /// Retrieve all reservations from the database
  /// Used to populate ListView with existing reservations
  /// Ordered by ID in descending order (newest first)
  ///
  /// Returns: Future containing list of all reservations
  @Query('SELECT * FROM Reservation ORDER BY id DESC')
  Future<List<Reservation>> findAllReservations();

  /// Insert a new reservation into the database
  /// Requirement 2: Insert items into ListView (via database)
  ///
  /// [reservation] - Reservation to insert
  ///
  /// Returns: Future that completes when insertion is done
  @insert
  Future<void> insertReservation(Reservation reservation);

  /// Update an existing reservation in the database
  /// Used for modifying reservation information
  ///
  /// [reservation] - Updated reservation
  ///
  /// Returns: Future that completes when update is done
  @update
  Future<void> updateReservation(Reservation reservation);

  /// Delete a reservation from the database
  /// Used for removing reservations from the system
  ///
  /// [reservation] - Reservation to delete
  ///
  /// Returns: Future that completes when deletion is done
  @delete
  Future<void> deleteReservation(Reservation reservation);

  /// Delete a reservation by its ID
  /// Alternative deletion method using ID
  ///
  /// [id] - ID of the reservation to delete
  ///
  /// Returns: Future that completes when deletion is done
  @Query('DELETE FROM Reservation WHERE id = :id')
  Future<void> deleteReservationById(int id);

  /// Find reservations by customer ID
  /// Useful for customer-specific queries
  ///
  /// [customerId] - Customer ID to search for
  ///
  /// Returns: Future containing list of reservations for the customer
  @Query('SELECT * FROM Reservation WHERE customerId = :customerId ORDER BY id DESC')
  Future<List<Reservation>> findReservationsByCustomer(int customerId);

  /// Find reservations by flight ID
  /// Useful for tracking which flights have been reserved
  ///
  /// [flightId] - Flight ID to search for
  ///
  /// Returns: Future containing list of reservations for the flight
  @Query('SELECT * FROM Reservation WHERE flightId = :flightId ORDER BY id DESC')
  Future<List<Reservation>> findReservationsByFlight(int flightId);

  /// Find reservations by flight date
  /// Useful for daily reservation reports
  ///
  /// [flightDate] - Flight date to search for (YYYY-MM-DD format)
  ///
  /// Returns: Future containing list of reservations for the specified date
  @Query('SELECT * FROM Reservation WHERE flightDate = :flightDate ORDER BY id DESC')
  Future<List<Reservation>> findReservationsByDate(String flightDate);

  /// Count total number of reservations
  /// Useful for statistics and reporting
  ///
  /// Returns: Future containing the total count of reservations
  @Query('SELECT COUNT(*) FROM Reservation')
  Future<int?> countReservations();

  /// Find reservations by date range
  /// Useful for period-based reporting
  ///
  /// [startDate] - Start date in YYYY-MM-DD format
  /// [endDate] - End date in YYYY-MM-DD format
  ///
  /// Returns: Future containing list of reservations in the date range
  @Query('SELECT * FROM Reservation WHERE flightDate >= :startDate AND flightDate <= :endDate ORDER BY flightDate DESC')
  Future<List<Reservation>> findReservationsByDateRange(String startDate, String endDate);

  /// Search reservations by reservation name
  /// Useful for finding reservations by user-friendly names
  ///
  /// [searchTerm] - Search term to look for in reservation names
  ///
  /// Returns: Future containing list of matching reservations
  @Query('SELECT * FROM Reservation WHERE reservationName LIKE :searchTerm ORDER BY id DESC')
  Future<List<Reservation>> searchReservationsByName(String searchTerm);

  /// Find reservations for a specific customer and flight combination
  /// Useful for checking if a customer already has a reservation on a flight
  ///
  /// [customerId] - Customer ID to search for
  /// [flightId] - Flight ID to search for
  ///
  /// Returns: Future containing list of matching reservations
  @Query('SELECT * FROM Reservation WHERE customerId = :customerId AND flightId = :flightId ORDER BY id DESC')
  Future<List<Reservation>> findReservationsByCustomerAndFlight(int customerId, int flightId);

  /// Get the most recent reservation for a customer
  /// Useful for pre-filling form data with last reservation details
  ///
  /// [customerId] - Customer ID to search for
  ///
  /// Returns: Future containing the most recent reservation or null if none found
  @Query('SELECT * FROM Reservation WHERE customerId = :customerId ORDER BY id DESC LIMIT 1')
  Future<Reservation?> getLatestReservationForCustomer(int customerId);

  /// Count reservations for a specific flight
  /// Useful for flight capacity management
  ///
  /// [flightId] - Flight ID to count reservations for
  ///
  /// Returns: Future containing the count of reservations for the flight
  @Query('SELECT COUNT(*) FROM Reservation WHERE flightId = :flightId')
  Future<int?> countReservationsForFlight(int flightId);

  /// Get upcoming reservations (future dates from today)
  /// Useful for showing active/upcoming reservations
  ///
  /// [today] - Today's date in YYYY-MM-DD format
  ///
  /// Returns: Future containing list of upcoming reservations
  @Query('SELECT * FROM Reservation WHERE flightDate >= :today ORDER BY flightDate ASC')
  Future<List<Reservation>> getUpcomingReservations(String today);

  /// Get past reservations (dates before today)
  /// Useful for showing reservation history
  ///
  /// [today] - Today's date in YYYY-MM-DD format
  ///
  /// Returns: Future containing list of past reservations
  @Query('SELECT * FROM Reservation WHERE flightDate < :today ORDER BY flightDate DESC')
  Future<List<Reservation>> getPastReservations(String today);
}