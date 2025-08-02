/// Airplane Data Access Object (DAO) for database operations
///
/// Provides an abstraction layer for airplane database operations
/// using Floor database framework annotations
library;

import 'package:floor/floor.dart';
import '../models/airplane.dart';

/// Data Access Object for Airplane entity
///
/// Defines database operations for airplane records including
/// insert, update, delete, and query operations
/// This is an abstract class that Floor will implement during code generation
@dao
abstract class AirplaneDao {
  /// Insert new airplane into database
  ///
  /// Adds a new airplane record to the airplanes table
  /// Returns the auto-generated ID of the inserted record
  ///
  /// [airplane] The airplane object to insert
  /// Returns: The ID of the newly inserted airplane
  @insert
  Future<int> insertAirplane(Airplane airplane);

  /// Update existing airplane in database
  ///
  /// Updates an airplane record with new values based on its ID
  ///
  /// [airplane] The airplane object with updated values
  @update
  Future<void> updateAirplane(Airplane airplane);

  /// Delete airplane from database
  ///
  /// Removes an airplane record from the database
  ///
  /// [airplane] The airplane object to delete
  @delete
  Future<void> deleteAirplane(Airplane airplane);

  /// Retrieve all airplanes from database
  ///
  /// Queries the airplanes table and returns all records
  /// ordered by ID in descending order (newest first)
  ///
  /// Returns: List of all airplane objects in the database
  @Query('SELECT * FROM airplanes ORDER BY id DESC')
  Future<List<Airplane>> findAllAirplanes();

  /// Find airplane by ID
  ///
  /// Queries for a specific airplane by its unique identifier
  ///
  /// [id] The ID of the airplane to find
  /// Returns: The airplane object or null if not found
  @Query('SELECT * FROM airplanes WHERE id = :id')
  Future<Airplane?> findAirplaneById(int id);

  /// Find airplanes by type
  ///
  /// Queries for all airplanes of a specific type/model
  ///
  /// [type] The type/model of airplane to search for
  /// Returns: List of airplanes matching the type
  @Query('SELECT * FROM airplanes WHERE type = :type ORDER BY id DESC')
  Future<List<Airplane>> findAirplanesByType(String type);

  /// Find airplanes by minimum capacity
  ///
  /// Queries for airplanes with passenger capacity >= specified value
  ///
  /// [minCapacity] The minimum passenger capacity
  /// Returns: List of airplanes meeting the capacity requirement
  @Query('SELECT * FROM airplanes WHERE passengerCapacity >= :minCapacity ORDER BY passengerCapacity DESC')
  Future<List<Airplane>> findAirplanesByMinCapacity(int minCapacity);

  /// Find airplanes by speed range
  ///
  /// Queries for airplanes with max speed within specified range
  ///
  /// [minSpeed] The minimum speed
  /// [maxSpeed] The maximum speed
  /// Returns: List of airplanes within the speed range
  @Query('SELECT * FROM airplanes WHERE maxSpeed >= :minSpeed AND maxSpeed <= :maxSpeed ORDER BY maxSpeed DESC')
  Future<List<Airplane>> findAirplanesBySpeedRange(int minSpeed, int maxSpeed);

  /// Delete airplane by ID
  ///
  /// Removes an airplane record by its unique identifier
  ///
  /// [id] The ID of the airplane to delete
  @Query('DELETE FROM airplanes WHERE id = :id')
  Future<void> deleteAirplaneById(int id);

  /// Count total number of airplanes
  ///
  /// Returns the total count of airplanes in the database
  ///
  /// Returns: Total number of airplane records
  @Query('SELECT COUNT(*) FROM airplanes')
  Future<int?> countAirplanes();

  /// Search airplanes by type pattern
  ///
  /// Queries for airplanes with type containing search term
  ///
  /// [searchTerm] The search term (use % for wildcard)
  /// Returns: List of matching airplanes
  @Query('SELECT * FROM airplanes WHERE type LIKE :searchTerm ORDER BY id DESC')
  Future<List<Airplane>> searchAirplanesByType(String searchTerm);

  /// Get airplane with highest capacity
  ///
  /// Returns the airplane with the maximum passenger capacity
  ///
  /// Returns: Airplane with highest capacity or null if none
  @Query('SELECT * FROM airplanes ORDER BY passengerCapacity DESC LIMIT 1')
  Future<Airplane?> getAirplaneWithHighestCapacity();

  /// Get airplane with longest range
  ///
  /// Returns the airplane with the maximum flight range
  ///
  /// Returns: Airplane with longest range or null if none
  @Query('SELECT * FROM airplanes ORDER BY range DESC LIMIT 1')
  Future<Airplane?> getAirplaneWithLongestRange();

  /// Get fastest airplane
  ///
  /// Returns the airplane with the highest max speed
  ///
  /// Returns: Fastest airplane or null if none
  @Query('SELECT * FROM airplanes ORDER BY maxSpeed DESC LIMIT 1')
  Future<Airplane?> getFastestAirplane();
}