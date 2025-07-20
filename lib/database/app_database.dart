// lib/database/app_database.dart
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

// Import your entities and DAOs
import '../models/sale_record.dart';
import '../dao/sale_record_dao.dart';

// This annotation tells the code generator where to put the generated code
part 'app_database.g.dart';

/**
 * Main application database configuration
 * Uses Floor library for SQLite database management
 *
 * Project Requirements Addressed:
 * - Requirement 3: Database storage for ListView items
 * - Persistent storage that survives app restarts
 * - SQLite implementation as specified in project requirements
 */
@Database(version: 1, entities: [SaleRecord])
abstract class AppDatabase extends FloorDatabase {
  /**
   * Getter for accessing sale record data operations
   * Provides access to all CRUD operations for sales
   *
   * @return SaleRecordDao instance for database operations
   */
  SaleRecordDao get saleRecordDao;
}