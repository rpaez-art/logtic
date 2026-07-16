import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/odoo_models.dart';

/// Singleton service that caches Odoo route data locally using sqflite.
/// On sync success the fresh data is stored; on network errors the cached
/// data is returned so the driver can still see their routes offline.
class RouteCacheService {
  static const String _dbName = 'logtic_cache.db';
  static const int _dbVersion = 1;
  static const String _tableRoutes = 'routes';
  static const String _tableLines = 'route_lines';

  static final RouteCacheService _instance = RouteCacheService._();
  static RouteCacheService get instance => _instance;
  RouteCacheService._();

  Database? _db;

  // ──────────────────────────────────────────────
  //  Initialization
  // ──────────────────────────────────────────────

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableRoutes (
        id INTEGER PRIMARY KEY,
        driver_id INTEGER NOT NULL,
        json TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableLines (
        id INTEGER PRIMARY KEY,
        route_id INTEGER NOT NULL,
        driver_id INTEGER NOT NULL,
        json TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here
  }

  // ──────────────────────────────────────────────
  //  Write – save routes + lines for a driver
  // ──────────────────────────────────────────────

  /// Store the full list of [RouteData] for [driverId] into the local cache.
  /// Any previously cached data for this driver is replaced.
  Future<void> cacheRoutes(int driverId, List<RouteData> routes) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      // Remove stale data for this driver
      await txn.delete(_tableRoutes, where: 'driver_id = ?', whereArgs: [driverId]);
      await txn.delete(_tableLines, where: 'driver_id = ?', whereArgs: [driverId]);

      // Insert each route with its full JSON representation
      for (final route in routes) {
        // Serialise the route (without lines – those go in the lines table)
        final routeJson = {
          'id': route.id,
          'name': route.name,
          'driver_id': route.driverId != null
              ? {'id': route.driverId!.id, 'name': route.driverId!.name}
              : null,
          'state': route.state,
          'max_priority': route.maxPriority,
          'date': route.date,
          'start_date': route.startDate,
          'end_date': route.endDate,
        };

        await txn.insert(_tableRoutes, {
          'id': route.id,
          'driver_id': driverId,
          'json': jsonEncode(routeJson),
          'cached_at': now,
        });

        // Insert each line for this route
        for (final line in route.routeLines) {
          final lineJson = {
            'id': line.id,
            'partner_id': {'id': line.partnerId.id, 'name': line.partnerId.name},
            'street': line.street,
            'city': line.city,
            'latitude': line.latitude,
            'longitude': line.longitude,
            'sequence': line.sequence,
            'notes': line.notes,
            'obra': line.obra,
            'priority': line.priority,
            'state': line.state,
            'scheduled_time': line.scheduledTime,
            'start_time': line.startTime,
            'pickup_time': line.pickupTime,
            'end_time': line.endTime,
            'order_type': line.orderType,
            'order_name': line.orderName,
            'order_lines': line.orderLines?.map((ol) => {
              'product_name': ol.productName,
              'quantity': ol.quantity,
              'uom': ol.uom,
              'price_unit': ol.priceUnit,
            }).toList(),
            'attachments': line.attachments?.map((a) => {
              'id': a.id,
              'name': a.name,
              'filename': a.filename,
              'mimetype': a.mimetype,
              'file_size': a.fileSize,
              'create_date': a.createDate,
              'download_url': a.downloadUrl,
            }).toList(),
            'incomplete_reason': line.incompleteReason,
            'incomplete_notes': line.incompleteNotes,
          };

          await txn.insert(_tableLines, {
            'id': line.id,
            'route_id': route.id,
            'driver_id': driverId,
            'json': jsonEncode(lineJson),
            'cached_at': now,
          });
        }
      }
    });

    debugPrint('🗄️ Cached ${routes.length} routes for driver $driverId');
  }

  // ──────────────────────────────────────────────
  //  Read – restore from cache
  // ──────────────────────────────────────────────

  /// Returns the cached [RouteData] list for [driverId], or an empty list
  /// when nothing has been cached yet.
  Future<List<RouteData>> getCachedRoutes(int driverId) async {
    final db = await database;

    final routeRows = await db.query(
      _tableRoutes,
      where: 'driver_id = ?',
      whereArgs: [driverId],
    );

    if (routeRows.isEmpty) return [];

    final routes = <RouteData>[];
    for (final row in routeRows) {
      final routeJson = jsonDecode(row['json'] as String) as Map<String, dynamic>;

      // Fetch lines for this route
      final lineRows = await db.query(
        _tableLines,
        where: 'driver_id = ? AND route_id = ?',
        whereArgs: [driverId, row['id']],
      );

      final lines = lineRows.map((lr) {
        final lineJson = jsonDecode(lr['json'] as String) as Map<String, dynamic>;
        return RouteLineData.fromJson(lineJson);
      }).toList();

      // Reconstruct the full RouteData with its lines
      routes.add(RouteData(
        id: routeJson['id'] as int,
        name: routeJson['name'] as String? ?? '',
        driverId: routeJson['driver_id'] != null
            ? DriverInfo(
                id: (routeJson['driver_id'] as Map)['id'] as int,
                name: (routeJson['driver_id'] as Map)['name'] as String? ?? '',
              )
            : null,
        state: routeJson['state'] as String? ?? '',
        maxPriority: routeJson['max_priority'] as String?,
        date: routeJson['date'] as String? ?? '',
        startDate: routeJson['start_date'] as String?,
        endDate: routeJson['end_date'] as String?,
        routeLines: lines,
      ));
    }

    debugPrint('🗄️ Loaded ${routes.length} cached routes for driver $driverId');
    return routes;
  }

  /// Returns true if any cached data exists for the given driver.
  Future<bool> hasCache(int driverId) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableRoutes WHERE driver_id = ?',
        [driverId],
      ),
    );
    return (count ?? 0) > 0;
  }

  /// Remove all cached data for a driver (e.g. on logout).
  Future<void> clearCache(int driverId) async {
    final db = await database;
    await db.delete(_tableRoutes, where: 'driver_id = ?', whereArgs: [driverId]);
    await db.delete(_tableLines, where: 'driver_id = ?', whereArgs: [driverId]);
  }

  /// Remove ALL cached data for all drivers.
  Future<void> clearAll() async {
    final db = await database;
    await db.delete(_tableRoutes);
    await db.delete(_tableLines);
  }
}
