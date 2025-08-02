/// Airplane Database Configuration
///
/// Defines the Floor database for airplane management including
/// database version, entities, and data access objects
library;

import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../dao/airplane_dao.dart';
import '../models/airplane.dart';

part 'airplane_database.g.dart';

/// Floor Database for Airplane Management
///
/// This database manages airplane fleet data with a single table
/// for storing airplane specifications and details
/// 
/// Database version: 1
/// Entities: [Airplane]
/// DAOs: [AirplaneDao]
@Database(version: 1, entities: [Airplane])
abstract class AirplaneDatabase extends FloorDatabase {
  /// Get the Data Access Object for airplane operations
  ///
  /// Provides access to all database operations for airplane records
  /// including insert, update, delete, and query operations
  /// 
  /// Returns: Instance of AirplaneDao for database operations
  AirplaneDao get airplaneDao;
}