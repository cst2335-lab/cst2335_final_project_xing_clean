// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ReservationDao? _reservationDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Reservation` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `customerId` INTEGER NOT NULL, `flightId` INTEGER NOT NULL, `flightDate` TEXT NOT NULL, `reservationName` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ReservationDao get reservationDao {
    return _reservationDaoInstance ??=
        _$ReservationDao(database, changeListener);
  }
}

class _$ReservationDao extends ReservationDao {
  _$ReservationDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _reservationInsertionAdapter = InsertionAdapter(
            database,
            'Reservation',
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'flightDate': item.flightDate,
                  'reservationName': item.reservationName
                }),
        _reservationUpdateAdapter = UpdateAdapter(
            database,
            'Reservation',
            ['id'],
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'flightDate': item.flightDate,
                  'reservationName': item.reservationName
                }),
        _reservationDeletionAdapter = DeletionAdapter(
            database,
            'Reservation',
            ['id'],
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'flightDate': item.flightDate,
                  'reservationName': item.reservationName
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Reservation> _reservationInsertionAdapter;

  final UpdateAdapter<Reservation> _reservationUpdateAdapter;

  final DeletionAdapter<Reservation> _reservationDeletionAdapter;

  @override
  Future<List<Reservation>> findAllReservations() async {
    return _queryAdapter.queryList('SELECT * FROM Reservation ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => Reservation(
            id: row['id'] as int?,
            customerId: row['customerId'] as int,
            flightId: row['flightId'] as int,
            flightDate: row['flightDate'] as String,
            reservationName: row['reservationName'] as String));
  }

  @override
  Future<void> deleteReservationById(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM Reservation WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<List<Reservation>> findReservationsByCustomer(int customerId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Reservation WHERE customerId = ?1 ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => Reservation(
            id: row['id'] as int?,
            customerId: row['customerId'] as int,
            flightId: row['flightId'] as int,
            flightDate: row['flightDate'] as String,
            reservationName: row['reservationName'] as String),
        arguments: [customerId]);
  }

  @override
  Future<List<Reservation>> findReservationsByFlight(int flightId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Reservation WHERE flightId = ?1 ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => Reservation(
            id: row['id'] as int?,
            customerId: row['customerId'] as int,
            flightId: row['flightId'] as int,
            flightDate: row['flightDate'] as String,
            reservationName: row['reservationName'] as String),
        arguments: [flightId]);
  }

  @override
  Future<List<Reservation>> findReservationsByDate(String flightDate) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Reservation WHERE flightDate = ?1 ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => Reservation(
            id: row['id'] as int?,
            customerId: row['customerId'] as int,
            flightId: row['flightId'] as int,
            flightDate: row['flightDate'] as String,
            reservationName: row['reservationName'] as String),
        arguments: [flightDate]);
  }

  @override
  Future<int?> countReservations() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM Reservation',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<List<Reservation>> findReservationsByDateRange(
    String startDate,
    String endDate,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Reservation WHERE flightDate >= ?1 AND flightDate <= ?2 ORDER BY flightDate DESC',
        mapper: (Map<String, Object?> row) => Reservation(id: row['id'] as int?, customerId: row['customerId'] as int, flightId: row['flightId'] as int, flightDate: row['flightDate'] as String, reservationName: row['reservationName'] as String),
        arguments: [startDate, endDate]);
  }

  @override
  Future<List<Reservation>> searchReservationsByName(String searchTerm) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Reservation WHERE reservationName LIKE ?1 ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => Reservation(id: row['id'] as int?, customerId: row['customerId'] as int, flightId: row['flightId'] as int, flightDate: row['flightDate'] as String, reservationName: row['reservationName'] as String),
        arguments: [searchTerm]);
  }

  @override
  Future<List<Reservation>> findReservationsByCustomerAndFlight(
    int customerId,
    int flightId,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Reservation WHERE customerId = ?1 AND flightId = ?2 ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => Reservation(id: row['id'] as int?, customerId: row['customerId'] as int, flightId: row['flightId'] as int, flightDate: row['flightDate'] as String, reservationName: row['reservationName'] as String),
        arguments: [customerId, flightId]);
  }

  @override
  Future<Reservation?> getLatestReservationForCustomer(int customerId) async {
    return _queryAdapter.query(
        'SELECT * FROM Reservation WHERE customerId = ?1 ORDER BY id DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => Reservation(id: row['id'] as int?, customerId: row['customerId'] as int, flightId: row['flightId'] as int, flightDate: row['flightDate'] as String, reservationName: row['reservationName'] as String),
        arguments: [customerId]);
  }

  @override
  Future<int?> countReservationsForFlight(int flightId) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM Reservation WHERE flightId = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [flightId]);
  }

  @override
  Future<List<Reservation>> getUpcomingReservations(String today) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Reservation WHERE flightDate >= ?1 ORDER BY flightDate ASC',
        mapper: (Map<String, Object?> row) => Reservation(id: row['id'] as int?, customerId: row['customerId'] as int, flightId: row['flightId'] as int, flightDate: row['flightDate'] as String, reservationName: row['reservationName'] as String),
        arguments: [today]);
  }

  @override
  Future<List<Reservation>> getPastReservations(String today) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Reservation WHERE flightDate < ?1 ORDER BY flightDate DESC',
        mapper: (Map<String, Object?> row) => Reservation(id: row['id'] as int?, customerId: row['customerId'] as int, flightId: row['flightId'] as int, flightDate: row['flightDate'] as String, reservationName: row['reservationName'] as String),
        arguments: [today]);
  }

  @override
  Future<void> insertReservation(Reservation reservation) async {
    await _reservationInsertionAdapter.insert(
        reservation, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateReservation(Reservation reservation) async {
    await _reservationUpdateAdapter.update(
        reservation, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteReservation(Reservation reservation) async {
    await _reservationDeletionAdapter.delete(reservation);
  }
}
