import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class CachedRoutes extends Table {
  IntColumn get id => integer()();
  IntColumn get driverId => integer()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get state => text().withDefault(const Constant(''))();
  TextColumn get maxPriority => text().nullable()();
  TextColumn get date => text().withDefault(const Constant(''))();
  TextColumn get startDate => text().nullable()();
  TextColumn get endDate => text().nullable()();
  TextColumn get cachedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedRouteLines extends Table {
  IntColumn get id => integer()();
  IntColumn get routeId => integer()();
  IntColumn get driverId => integer()();
  IntColumn get partnerId => integer()();
  TextColumn get partnerName => text().withDefault(const Constant(''))();
  TextColumn get street => text().nullable()();
  TextColumn get city => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  IntColumn get sequence => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  TextColumn get obra => text().nullable()();
  TextColumn get priority => text().nullable()();
  TextColumn get state => text().withDefault(const Constant('pending'))();
  TextColumn get scheduledTime => text().nullable()();
  TextColumn get startTime => text().nullable()();
  TextColumn get pickupTime => text().nullable()();
  TextColumn get endTime => text().nullable()();
  TextColumn get orderType => text().nullable()();
  TextColumn get orderName => text().nullable()();
  TextColumn get incompleteReason => text().nullable()();
  TextColumn get incompleteNotes => text().nullable()();
  TextColumn get cachedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedOrderLines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get lineId => integer()();
  TextColumn get productName => text().withDefault(const Constant(''))();
  RealColumn get quantity => real().withDefault(const Constant(0.0))();
  TextColumn get uom => text().withDefault(const Constant(''))();
  RealColumn get priceUnit => real().withDefault(const Constant(0.0))();
}

class CachedAttachments extends Table {
  IntColumn get id => integer()();
  IntColumn get lineId => integer()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get filename => text().nullable()();
  TextColumn get mimetype => text().nullable()();
  IntColumn get fileSize => integer().nullable()();
  TextColumn get createDate => text().nullable()();
  TextColumn get downloadUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  CachedRoutes,
  CachedRouteLines,
  CachedOrderLines,
  CachedAttachments,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'logtic_drift.db');
  }
}
