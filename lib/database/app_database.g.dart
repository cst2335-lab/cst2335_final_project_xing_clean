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

  SaleRecordDao? _saleRecordDaoInstance;

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
            'CREATE TABLE IF NOT EXISTS `SaleRecord` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `customerId` INTEGER NOT NULL, `carId` INTEGER NOT NULL, `dealershipId` INTEGER NOT NULL, `purchaseDate` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  SaleRecordDao get saleRecordDao {
    return _saleRecordDaoInstance ??= _$SaleRecordDao(database, changeListener);
  }
}

class _$SaleRecordDao extends SaleRecordDao {
  _$SaleRecordDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _saleRecordInsertionAdapter = InsertionAdapter(
            database,
            'SaleRecord',
            (SaleRecord item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'carId': item.carId,
                  'dealershipId': item.dealershipId,
                  'purchaseDate': item.purchaseDate
                }),
        _saleRecordUpdateAdapter = UpdateAdapter(
            database,
            'SaleRecord',
            ['id'],
            (SaleRecord item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'carId': item.carId,
                  'dealershipId': item.dealershipId,
                  'purchaseDate': item.purchaseDate
                }),
        _saleRecordDeletionAdapter = DeletionAdapter(
            database,
            'SaleRecord',
            ['id'],
            (SaleRecord item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'carId': item.carId,
                  'dealershipId': item.dealershipId,
                  'purchaseDate': item.purchaseDate
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<SaleRecord> _saleRecordInsertionAdapter;

  final UpdateAdapter<SaleRecord> _saleRecordUpdateAdapter;

  final DeletionAdapter<SaleRecord> _saleRecordDeletionAdapter;

  @override
  Future<List<SaleRecord>> findAllSaleRecords() async {
    return _queryAdapter.queryList('SELECT * FROM SaleRecord ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => SaleRecord(
            id: row['id'] as int?,
            customerId: row['customerId'] as int,
            carId: row['carId'] as int,
            dealershipId: row['dealershipId'] as int,
            purchaseDate: row['purchaseDate'] as String));
  }

  @override
  Future<void> deleteSaleRecordById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM SaleRecord WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<List<SaleRecord>> findSalesByCustomer(int customerId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM SaleRecord WHERE customerId = ?1 ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => SaleRecord(
            id: row['id'] as int?,
            customerId: row['customerId'] as int,
            carId: row['carId'] as int,
            dealershipId: row['dealershipId'] as int,
            purchaseDate: row['purchaseDate'] as String),
        arguments: [customerId]);
  }

  @override
  Future<List<SaleRecord>> findSalesByCar(int carId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM SaleRecord WHERE carId = ?1 ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => SaleRecord(
            id: row['id'] as int?,
            customerId: row['customerId'] as int,
            carId: row['carId'] as int,
            dealershipId: row['dealershipId'] as int,
            purchaseDate: row['purchaseDate'] as String),
        arguments: [carId]);
  }

  @override
  Future<List<SaleRecord>> findSalesByDealership(int dealershipId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM SaleRecord WHERE dealershipId = ?1 ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => SaleRecord(
            id: row['id'] as int?,
            customerId: row['customerId'] as int,
            carId: row['carId'] as int,
            dealershipId: row['dealershipId'] as int,
            purchaseDate: row['purchaseDate'] as String),
        arguments: [dealershipId]);
  }

  @override
  Future<int?> countSaleRecords() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM SaleRecord',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<List<SaleRecord>> findSalesByDateRange(
    String startDate,
    String endDate,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM SaleRecord WHERE purchaseDate >= ?1 AND purchaseDate <= ?2 ORDER BY purchaseDate DESC',
        mapper: (Map<String, Object?> row) => SaleRecord(id: row['id'] as int?, customerId: row['customerId'] as int, carId: row['carId'] as int, dealershipId: row['dealershipId'] as int, purchaseDate: row['purchaseDate'] as String),
        arguments: [startDate, endDate]);
  }

  @override
  Future<void> insertSaleRecord(SaleRecord saleRecord) async {
    await _saleRecordInsertionAdapter.insert(
        saleRecord, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateSaleRecord(SaleRecord saleRecord) async {
    await _saleRecordUpdateAdapter.update(saleRecord, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteSaleRecord(SaleRecord saleRecord) async {
    await _saleRecordDeletionAdapter.delete(saleRecord);
  }
}
