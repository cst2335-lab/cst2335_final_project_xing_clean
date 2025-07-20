// lib/models/sale_record.dart
import 'package:floor/floor.dart';

/**
 * SaleRecord entity class for Floor database storage
 * Represents a sales transaction record in the database
 *
 * Project Requirements Addressed:
 * - Requirement 3: Database storage using Floor SQLite
 * - Data model for sales list page implementation
 * - Stores customer ID, car ID, dealership ID, and purchase date
 */
@entity
class SaleRecord {
  /**
   * Primary key for the sale record
   * Unique identifier for each sale transaction
   */
  @primaryKey
  final int id;

  /**
   * ID of the customer who purchased the car
   * Requirement: Integer representing customer ID (can be any int)
   */
  final int customerId;

  /**
   * ID of the car that was sold
   * Requirement: Integer representing car ID from car inventory
   */
  final int carId;

  /**
   * ID of the dealership where the sale occurred
   * Requirement: Integer representing dealership location ID
   */
  final int dealershipId;

  /**
   * Date when the purchase was made
   * Requirement: Date of purchase as string format
   */
  final String purchaseDate;

  /**
   * Static counter for generating unique IDs
   * Ensures each new sale record gets a unique identifier
   * Updated automatically when records are loaded from database
   */
  static int ID = 1;

  /**
   * Constructor for SaleRecord
   * Automatically updates the static ID counter to ensure unique IDs
   *
   * @param id - Unique identifier for this sale record
   * @param customerId - Customer who made the purchase
   * @param carId - Car that was purchased
   * @param dealershipId - Dealership where sale occurred
   * @param purchaseDate - Date of the purchase
   */
  SaleRecord(
      this.id,
      this.customerId,
      this.carId,
      this.dealershipId,
      this.purchaseDate,
      ) {
    // Update static ID counter if current ID is higher
    // This prevents ID conflicts when loading existing records
    if (id >= ID) {
      ID = id + 1;
    }
  }

  /**
   * Getter for display title in ListView
   * Requirement 1: ListView displays items inserted by user
   *
   * @return Formatted title string for list display
   */
  String get displayTitle => 'Sale Record #$id';

  /**
   * Getter for display subtitle in ListView
   * Shows key information about the sale in compact format
   *
   * @return Formatted subtitle with customer, car, and date info
   */
  String get displaySubtitle =>
      'Customer: $customerId | Car: $carId | Date: $purchaseDate';

  /**
   * Getter for detailed information display
   * Used in detail view when sale record is selected
   *
   * @return Formatted string with all sale information
   */
  String get detailInfo =>
      'Sale ID: $id\n'
          'Customer ID: $customerId\n'
          'Car ID: $carId\n'
          'Dealership ID: $dealershipId\n'
          'Purchase Date: $purchaseDate';

  /**
   * Creates a copy of this SaleRecord with modified fields
   * Useful for updates and data manipulation in forms
   *
   * @param id - New ID (optional, defaults to current)
   * @param customerId - New customer ID (optional, defaults to current)
   * @param carId - New car ID (optional, defaults to current)
   * @param dealershipId - New dealership ID (optional, defaults to current)
   * @param purchaseDate - New purchase date (optional, defaults to current)
   * @return New SaleRecord instance with updated values
   */
  SaleRecord copyWith({
    int? id,
    int? customerId,
    int? carId,
    int? dealershipId,
    String? purchaseDate,
  }) {
    return SaleRecord(
      id ?? this.id,
      customerId ?? this.customerId,
      carId ?? this.carId,
      dealershipId ?? this.dealershipId,
      purchaseDate ?? this.purchaseDate,
    );
  }

  /**
   * Validates that all required fields have valid values
   * Used for form validation before saving to database
   *
   * @return true if all fields are valid, false otherwise
   */
  bool isValid() {
    return customerId > 0 &&
        carId > 0 &&
        dealershipId > 0 &&
        purchaseDate.isNotEmpty;
  }

  /**
   * Creates a SaleRecord from a Map (useful for JSON/database conversion)
   *
   * @param map - Map containing sale record data
   * @return SaleRecord instance created from map data
   */
  factory SaleRecord.fromMap(Map<String, dynamic> map) {
    return SaleRecord(
      map['id'] ?? 0,
      map['customerId'] ?? 0,
      map['carId'] ?? 0,
      map['dealershipId'] ?? 0,
      map['purchaseDate'] ?? '',
    );
  }

  /**
   * Converts SaleRecord to Map (useful for JSON/database conversion)
   *
   * @return Map representation of the sale record
   */
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'carId': carId,
      'dealershipId': dealershipId,
      'purchaseDate': purchaseDate,
    };
  }

  /**
   * String representation of the SaleRecord for debugging
   * Useful for console output and logging
   *
   * @return Human-readable string representation
   */
  @override
  String toString() {
    return 'SaleRecord{id: $id, customerId: $customerId, carId: $carId, '
        'dealershipId: $dealershipId, purchaseDate: $purchaseDate}';
  }

  /**
   * Equality operator for comparing SaleRecord instances
   * Two records are equal if they have the same ID
   *
   * @param other - Object to compare with
   * @return true if objects are equal, false otherwise
   */
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SaleRecord &&
              runtimeType == other.runtimeType &&
              id == other.id;

  /**
   * Hash code implementation based on ID
   * Required when overriding equality operator
   *
   * @return Hash code for this instance
   */
  @override
  int get hashCode => id.hashCode;
}