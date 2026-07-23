import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/odoo_models.dart';

/// Service that manages local route caching using Drift (strongly-typed SQLite reactive ORM).
class RouteCacheService {
  static final RouteCacheService _instance = RouteCacheService._();
  static RouteCacheService get instance => _instance;
  RouteCacheService._();

  AppDatabase? _db;

  AppDatabase get database {
    _db ??= AppDatabase();
    return _db!;
  }

  /// Store the full list of [RouteData] for [driverId] into the Drift database.
  /// Any previously cached data for this driver is replaced using type-safe transactions.
  Future<void> cacheRoutes(int driverId, List<RouteData> routes) async {
    final db = database;
    final now = DateTime.now().toIso8601String();

    await db.transaction(() async {
      // Remove stale data for this driver
      await (db.delete(db.cachedRoutes)..where((t) => t.driverId.equals(driverId))).go();
      await (db.delete(db.cachedRouteLines)..where((t) => t.driverId.equals(driverId))).go();

      for (final route in routes) {
        await db.into(db.cachedRoutes).insertOnConflictUpdate(
          CachedRoute(
            id: route.id,
            driverId: driverId,
            name: route.name,
            state: route.state,
            maxPriority: route.maxPriority,
            date: route.date,
            startDate: route.startDate,
            endDate: route.endDate,
            cachedAt: now,
          ),
        );

        for (final line in route.routeLines) {
          await db.into(db.cachedRouteLines).insertOnConflictUpdate(
            CachedRouteLine(
              id: line.id,
              routeId: route.id,
              driverId: driverId,
              partnerId: line.partnerId.id,
              partnerName: line.partnerId.name,
              street: line.street,
              city: line.city,
              latitude: line.latitude,
              longitude: line.longitude,
              sequence: line.sequence,
              notes: line.notes,
              obra: line.obra,
              priority: line.priority,
              state: line.state,
              scheduledTime: line.scheduledTime,
              startTime: line.startTime,
              pickupTime: line.pickupTime,
              endTime: line.endTime,
              orderType: line.orderType,
              orderName: line.orderName,
              incompleteReason: line.incompleteReason,
              incompleteNotes: line.incompleteNotes,
              cachedAt: now,
            ),
          );

          // Clear & Insert Order Lines
          await (db.delete(db.cachedOrderLines)..where((t) => t.lineId.equals(line.id))).go();
          if (line.orderLines != null) {
            for (final ol in line.orderLines!) {
              await db.into(db.cachedOrderLines).insert(
                CachedOrderLine(
                  id: 0,
                  lineId: line.id,
                  productName: ol.productName,
                  quantity: ol.quantity,
                  uom: ol.uom,
                  priceUnit: ol.priceUnit,
                ),
              );
            }
          }

          // Clear & Insert Attachments
          await (db.delete(db.cachedAttachments)..where((t) => t.lineId.equals(line.id))).go();
          if (line.attachments != null) {
            for (final att in line.attachments!) {
              await db.into(db.cachedAttachments).insertOnConflictUpdate(
                CachedAttachment(
                  id: att.id,
                  lineId: line.id,
                  name: att.name,
                  filename: att.filename,
                  mimetype: att.mimetype,
                  fileSize: att.fileSize,
                  createDate: att.createDate,
                  downloadUrl: att.downloadUrl,
                ),
              );
            }
          }
        }
      }
    });

    debugPrint('🗄️ Drift Cached ${routes.length} routes for driver $driverId');
  }

  /// Returns the cached [RouteData] list for [driverId], or an empty list
  /// when nothing has been cached yet.
  Future<List<RouteData>> getCachedRoutes(int driverId) async {
    final db = database;
    final routeRows = await (db.select(db.cachedRoutes)..where((t) => t.driverId.equals(driverId))).get();

    if (routeRows.isEmpty) return [];

    final routes = <RouteData>[];
    for (final row in routeRows) {
      final lineRows = await (db.select(db.cachedRouteLines)
        ..where((t) => t.driverId.equals(driverId) & t.routeId.equals(row.id)))
        .get();

      final lines = <RouteLineData>[];
      for (final lr in lineRows) {
        final orderLineRows = await (db.select(db.cachedOrderLines)..where((t) => t.lineId.equals(lr.id))).get();
        final attachmentRows = await (db.select(db.cachedAttachments)..where((t) => t.lineId.equals(lr.id))).get();

        lines.add(RouteLineData(
          id: lr.id,
          partnerId: PartnerInfo(id: lr.partnerId, name: lr.partnerName),
          street: lr.street,
          city: lr.city,
          latitude: lr.latitude,
          longitude: lr.longitude,
          sequence: lr.sequence,
          notes: lr.notes,
          obra: lr.obra,
          priority: lr.priority,
          state: lr.state,
          scheduledTime: lr.scheduledTime,
          startTime: lr.startTime,
          pickupTime: lr.pickupTime,
          endTime: lr.endTime,
          orderType: lr.orderType,
          orderName: lr.orderName,
          orderLines: orderLineRows
              .map((ol) => OrderLineData(
                    productName: ol.productName,
                    quantity: ol.quantity,
                    uom: ol.uom,
                    priceUnit: ol.priceUnit,
                  ))
              .toList(),
          attachments: attachmentRows
              .map((att) => AttachmentData(
                    id: att.id,
                    name: att.name,
                    filename: att.filename,
                    mimetype: att.mimetype,
                    fileSize: att.fileSize,
                    createDate: att.createDate,
                    downloadUrl: att.downloadUrl,
                  ))
              .toList(),
          incompleteReason: lr.incompleteReason,
          incompleteNotes: lr.incompleteNotes,
        ));
      }

      routes.add(RouteData(
        id: row.id,
        name: row.name,
        driverId: DriverInfo(id: row.driverId),
        state: row.state,
        maxPriority: row.maxPriority,
        date: row.date,
        startDate: row.startDate,
        endDate: row.endDate,
        routeLines: lines,
      ));
    }

    debugPrint('🗄️ Drift Loaded ${routes.length} cached routes for driver $driverId');
    return routes;
  }

  /// Returns true if any cached data exists for the given driver.
  Future<bool> hasCache(int driverId) async {
    final db = database;
    final query = db.select(db.cachedRoutes)..where((t) => t.driverId.equals(driverId));
    final rows = await query.get();
    return rows.isNotEmpty;
  }

  /// Remove all cached data for a driver (e.g. on logout).
  Future<void> clearCache(int driverId) async {
    final db = database;
    await (db.delete(db.cachedRoutes)..where((t) => t.driverId.equals(driverId))).go();
    await (db.delete(db.cachedRouteLines)..where((t) => t.driverId.equals(driverId))).go();
  }

  /// Remove ALL cached data for all drivers.
  Future<void> clearAll() async {
    final db = database;
    await db.delete(db.cachedRoutes).go();
    await db.delete(db.cachedRouteLines).go();
    await db.delete(db.cachedOrderLines).go();
    await db.delete(db.cachedAttachments).go();
  }
}
