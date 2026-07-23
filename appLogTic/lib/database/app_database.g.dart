// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class CachedRoute extends DataClass implements Insertable<CachedRoute> {
  final int id;
  final int driverId;
  final String name;
  final String state;
  final String? maxPriority;
  final String date;
  final String? startDate;
  final String? endDate;
  final String cachedAt;
  const CachedRoute({
    required this.id,
    required this.driverId,
    required this.name,
    required this.state,
    this.maxPriority,
    required this.date,
    this.startDate,
    this.endDate,
    required this.cachedAt,
  });

  @override
  Map<String, Expression> toColumns(bool nullToEmpty) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['driver_id'] = Variable<int>(driverId);
    map['name'] = Variable<String>(name);
    map['state'] = Variable<String>(state);
    if (!nullToEmpty || maxPriority != null) {
      map['max_priority'] = Variable<String>(maxPriority);
    }
    map['date'] = Variable<String>(date);
    if (!nullToEmpty || startDate != null) {
      map['start_date'] = Variable<String>(startDate);
    }
    if (!nullToEmpty || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    map['cached_at'] = Variable<String>(cachedAt);
    return map;
  }

  factory CachedRoute.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRoute(
      id: serializer.fromJson<int>(json['id']),
      driverId: serializer.fromJson<int>(json['driverId']),
      name: serializer.fromJson<String>(json['name']),
      state: serializer.fromJson<String>(json['state']),
      maxPriority: serializer.fromJson<String?>(json['maxPriority']),
      date: serializer.fromJson<String>(json['date']),
      startDate: serializer.fromJson<String?>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      cachedAt: serializer.fromJson<String>(json['cachedAt']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'driverId': serializer.toJson<int>(driverId),
      'name': serializer.toJson<String>(name),
      'state': serializer.toJson<String>(state),
      'maxPriority': serializer.toJson<String?>(maxPriority),
      'date': serializer.toJson<String>(date),
      'startDate': serializer.toJson<String?>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'cachedAt': serializer.toJson<String>(cachedAt),
    };
  }

  CachedRoute copyWith({
    int? id,
    int? driverId,
    String? name,
    String? state,
    Value<String?> maxPriority = const Value.absent(),
    String? date,
    Value<String?> startDate = const Value.absent(),
    Value<String?> endDate = const Value.absent(),
    String? cachedAt,
  }) =>
      CachedRoute(
        id: id ?? this.id,
        driverId: driverId ?? this.driverId,
        name: name ?? this.name,
        state: state ?? this.state,
        maxPriority: maxPriority.present ? maxPriority.value : this.maxPriority,
        date: date ?? this.date,
        startDate: startDate.present ? startDate.value : this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        cachedAt: cachedAt ?? this.cachedAt,
      );
}

class CachedRoutesCompanion extends UpdateCompanion<CachedRoute> {
  final Value<int> id;
  final Value<int> driverId;
  final Value<String> name;
  final Value<String> state;
  final Value<String?> maxPriority;
  final Value<String> date;
  final Value<String?> startDate;
  final Value<String?> endDate;
  final Value<String> cachedAt;
  const CachedRoutesCompanion({
    this.id = const Value.absent(),
    this.driverId = const Value.absent(),
    this.name = const Value.absent(),
    this.state = const Value.absent(),
    this.maxPriority = const Value.absent(),
    this.date = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });

  Map<String, Expression> toColumns(bool nullToEmpty) {
    final map = <String, Expression>{};
    if (id.present) map['id'] = Variable<int>(id.value);
    if (driverId.present) map['driver_id'] = Variable<int>(driverId.value);
    if (name.present) map['name'] = Variable<String>(name.value);
    if (state.present) map['state'] = Variable<String>(state.value);
    if (maxPriority.present) map['max_priority'] = Variable<String>(maxPriority.value);
    if (date.present) map['date'] = Variable<String>(date.value);
    if (startDate.present) map['start_date'] = Variable<String>(startDate.value);
    if (endDate.present) map['end_date'] = Variable<String>(endDate.value);
    if (cachedAt.present) map['cached_at'] = Variable<String>(cachedAt.value);
    return map;
  }
}

class $CachedRoutesTable extends CachedRoutes
    with TableInfo<$CachedRoutesTable, CachedRoute> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRoutesTable(this.attachedDatabase, [this._alias]);

  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, type: DriftSqlType.int);
  late final GeneratedColumn<int> driverId = GeneratedColumn<int>('driver_id', aliasedName, false, type: DriftSqlType.int);
  late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false, type: DriftSqlType.string, defaultValue: const Constant(''));
  late final GeneratedColumn<String> state = GeneratedColumn<String>('state', aliasedName, false, type: DriftSqlType.string, defaultValue: const Constant(''));
  late final GeneratedColumn<String> maxPriority = GeneratedColumn<String>('max_priority', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<String> date = GeneratedColumn<String>('date', aliasedName, false, type: DriftSqlType.string, defaultValue: const Constant(''));
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>('start_date', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>('end_date', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<String> cachedAt = GeneratedColumn<String>('cached_at', aliasedName, false, type: DriftSqlType.string);

  @override
  List<GeneratedColumn> get $columns => [id, driverId, name, state, maxPriority, date, startDate, endDate, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => 'cached_routes';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedRoute map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRoute(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      driverId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}driver_id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      state: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      maxPriority: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}max_priority']),
      date: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      startDate: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}start_date']),
      endDate: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}end_date']),
      cachedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedRoutesTable createAlias(String alias) {
    return $CachedRoutesTable(attachedDatabase, alias);
  }
}

class CachedRouteLine extends DataClass implements Insertable<CachedRouteLine> {
  final int id;
  final int routeId;
  final int driverId;
  final int partnerId;
  final String partnerName;
  final String? street;
  final String? city;
  final double? latitude;
  final double? longitude;
  final int sequence;
  final String? notes;
  final String? obra;
  final String? priority;
  final String state;
  final String? scheduledTime;
  final String? startTime;
  final String? pickupTime;
  final String? endTime;
  final String? orderType;
  final String? orderName;
  final String? incompleteReason;
  final String? incompleteNotes;
  final String cachedAt;

  const CachedRouteLine({
    required this.id,
    required this.routeId,
    required this.driverId,
    required this.partnerId,
    required this.partnerName,
    this.street,
    this.city,
    this.latitude,
    this.longitude,
    required this.sequence,
    this.notes,
    this.obra,
    this.priority,
    required this.state,
    this.scheduledTime,
    this.startTime,
    this.pickupTime,
    this.endTime,
    this.orderType,
    this.orderName,
    this.incompleteReason,
    this.incompleteNotes,
    required this.cachedAt,
  });

  @override
  Map<String, Expression> toColumns(bool nullToEmpty) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['route_id'] = Variable<int>(routeId);
    map['driver_id'] = Variable<int>(driverId);
    map['partner_id'] = Variable<int>(partnerId);
    map['partner_name'] = Variable<String>(partnerName);
    if (!nullToEmpty || street != null) map['street'] = Variable<String>(street);
    if (!nullToEmpty || city != null) map['city'] = Variable<String>(city);
    if (!nullToEmpty || latitude != null) map['latitude'] = Variable<double>(latitude);
    if (!nullToEmpty || longitude != null) map['longitude'] = Variable<double>(longitude);
    map['sequence'] = Variable<int>(sequence);
    if (!nullToEmpty || notes != null) map['notes'] = Variable<String>(notes);
    if (!nullToEmpty || obra != null) map['obra'] = Variable<String>(obra);
    if (!nullToEmpty || priority != null) map['priority'] = Variable<String>(priority);
    map['state'] = Variable<String>(state);
    if (!nullToEmpty || scheduledTime != null) map['scheduled_time'] = Variable<String>(scheduledTime);
    if (!nullToEmpty || startTime != null) map['start_time'] = Variable<String>(startTime);
    if (!nullToEmpty || pickupTime != null) map['pickup_time'] = Variable<String>(pickupTime);
    if (!nullToEmpty || endTime != null) map['end_time'] = Variable<String>(endTime);
    if (!nullToEmpty || orderType != null) map['order_type'] = Variable<String>(orderType);
    if (!nullToEmpty || orderName != null) map['order_name'] = Variable<String>(orderName);
    if (!nullToEmpty || incompleteReason != null) map['incomplete_reason'] = Variable<String>(incompleteReason);
    if (!nullToEmpty || incompleteNotes != null) map['incomplete_notes'] = Variable<String>(incompleteNotes);
    map['cached_at'] = Variable<String>(cachedAt);
    return map;
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routeId': serializer.toJson<int>(routeId),
      'driverId': serializer.toJson<int>(driverId),
      'partnerId': serializer.toJson<int>(partnerId),
      'partnerName': serializer.toJson<String>(partnerName),
      'street': serializer.toJson<String?>(street),
      'city': serializer.toJson<String?>(city),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'sequence': serializer.toJson<int>(sequence),
      'notes': serializer.toJson<String?>(notes),
      'obra': serializer.toJson<String?>(obra),
      'priority': serializer.toJson<String?>(priority),
      'state': serializer.toJson<String>(state),
      'scheduledTime': serializer.toJson<String?>(scheduledTime),
      'startTime': serializer.toJson<String?>(startTime),
      'pickupTime': serializer.toJson<String?>(pickupTime),
      'endTime': serializer.toJson<String?>(endTime),
      'orderType': serializer.toJson<String?>(orderType),
      'orderName': serializer.toJson<String?>(orderName),
      'incompleteReason': serializer.toJson<String?>(incompleteReason),
      'incompleteNotes': serializer.toJson<String?>(incompleteNotes),
      'cachedAt': serializer.toJson<String>(cachedAt),
    };
  }
}

class $CachedRouteLinesTable extends CachedRouteLines
    with TableInfo<$CachedRouteLinesTable, CachedRouteLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRouteLinesTable(this.attachedDatabase, [this._alias]);

  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, type: DriftSqlType.int);
  late final GeneratedColumn<int> routeId = GeneratedColumn<int>('route_id', aliasedName, false, type: DriftSqlType.int);
  late final GeneratedColumn<int> driverId = GeneratedColumn<int>('driver_id', aliasedName, false, type: DriftSqlType.int);
  late final GeneratedColumn<int> partnerId = GeneratedColumn<int>('partner_id', aliasedName, false, type: DriftSqlType.int);
  late final GeneratedColumn<String> partnerName = GeneratedColumn<String>('partner_name', aliasedName, false, type: DriftSqlType.string, defaultValue: const Constant(''));
  late final GeneratedColumn<String> street = GeneratedColumn<String>('street', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<String> city = GeneratedColumn<String>('city', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>('latitude', aliasedName, true, type: DriftSqlType.double);
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>('longitude', aliasedName, true, type: DriftSqlType.double);
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>('sequence', aliasedName, false, type: DriftSqlType.int, defaultValue: const Constant(0));
  late final GeneratedColumn<String> notes = GeneratedColumn<String>('notes', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<String> obra = GeneratedColumn<String>('obra', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<String> priority = GeneratedColumn<String>('priority', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<String> state = GeneratedColumn<String>('state', aliasedName, false, type: DriftSqlType.string, defaultValue: const Constant('pending'));
  late final GeneratedColumn<String> scheduledTime = GeneratedColumn<String>('scheduled_time', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>('start_time', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<String> pickupTime = GeneratedColumn<String>('pickup_time', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>('end_time', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<String> orderType = GeneratedColumn<String>('order_type', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<String> orderName = GeneratedColumn<String>('order_name', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<String> incompleteReason = GeneratedColumn<String>('incomplete_reason', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<String> incompleteNotes = GeneratedColumn<String>('incomplete_notes', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<String> cachedAt = GeneratedColumn<String>('cached_at', aliasedName, false, type: DriftSqlType.string);

  @override
  List<GeneratedColumn> get $columns => [
        id, routeId, driverId, partnerId, partnerName, street, city, latitude, longitude,
        sequence, notes, obra, priority, state, scheduledTime, startTime, pickupTime, endTime,
        orderType, orderName, incompleteReason, incompleteNotes, cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => 'cached_route_lines';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedRouteLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRouteLine(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      routeId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}route_id'])!,
      driverId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}driver_id'])!,
      partnerId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}partner_id'])!,
      partnerName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}partner_name'])!,
      street: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}street']),
      city: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}city']),
      latitude: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      sequence: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sequence'])!,
      notes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}notes']),
      obra: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}obra']),
      priority: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}priority']),
      state: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      scheduledTime: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}scheduled_time']),
      startTime: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}start_time']),
      pickupTime: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}pickup_time']),
      endTime: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}end_time']),
      orderType: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}order_type']),
      orderName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}order_name']),
      incompleteReason: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}incomplete_reason']),
      incompleteNotes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}incomplete_notes']),
      cachedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedRouteLinesTable createAlias(String alias) {
    return $CachedRouteLinesTable(attachedDatabase, alias);
  }
}

class CachedOrderLine extends DataClass implements Insertable<CachedOrderLine> {
  final int id;
  final int lineId;
  final String productName;
  final double quantity;
  final String uom;
  final double priceUnit;

  const CachedOrderLine({
    required this.id,
    required this.lineId,
    required this.productName,
    required this.quantity,
    required this.uom,
    required this.priceUnit,
  });

  @override
  Map<String, Expression> toColumns(bool nullToEmpty) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['line_id'] = Variable<int>(lineId);
    map['product_name'] = Variable<String>(productName);
    map['quantity'] = Variable<double>(quantity);
    map['uom'] = Variable<String>(uom);
    map['price_unit'] = Variable<double>(priceUnit);
    return map;
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lineId': serializer.toJson<int>(lineId),
      'productName': serializer.toJson<String>(productName),
      'quantity': serializer.toJson<double>(quantity),
      'uom': serializer.toJson<String>(uom),
      'priceUnit': serializer.toJson<double>(priceUnit),
    };
  }
}

class $CachedOrderLinesTable extends CachedOrderLines
    with TableInfo<$CachedOrderLinesTable, CachedOrderLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedOrderLinesTable(this.attachedDatabase, [this._alias]);

  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int);
  late final GeneratedColumn<int> lineId = GeneratedColumn<int>('line_id', aliasedName, false, type: DriftSqlType.int);
  late final GeneratedColumn<String> productName = GeneratedColumn<String>('product_name', aliasedName, false, type: DriftSqlType.string, defaultValue: const Constant(''));
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>('quantity', aliasedName, false, type: DriftSqlType.double, defaultValue: const Constant(0.0));
  late final GeneratedColumn<String> uom = GeneratedColumn<String>('uom', aliasedName, false, type: DriftSqlType.string, defaultValue: const Constant(''));
  late final GeneratedColumn<double> priceUnit = GeneratedColumn<double>('price_unit', aliasedName, false, type: DriftSqlType.double, defaultValue: const Constant(0.0));

  @override
  List<GeneratedColumn> get $columns => [id, lineId, productName, quantity, uom, priceUnit];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => 'cached_order_lines';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedOrderLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedOrderLine(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      lineId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}line_id'])!,
      productName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      quantity: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      uom: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uom'])!,
      priceUnit: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}price_unit'])!,
    );
  }

  @override
  $CachedOrderLinesTable createAlias(String alias) {
    return $CachedOrderLinesTable(attachedDatabase, alias);
  }
}

class CachedAttachment extends DataClass implements Insertable<CachedAttachment> {
  final int id;
  final int lineId;
  final String name;
  final String? filename;
  final String? mimetype;
  final int? fileSize;
  final String? createDate;
  final String? downloadUrl;

  const CachedAttachment({
    required this.id,
    required this.lineId,
    required this.name,
    this.filename,
    this.mimetype,
    this.fileSize,
    this.createDate,
    this.downloadUrl,
  });

  @override
  Map<String, Expression> toColumns(bool nullToEmpty) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['line_id'] = Variable<int>(lineId);
    map['name'] = Variable<String>(name);
    if (!nullToEmpty || filename != null) map['filename'] = Variable<String>(filename);
    if (!nullToEmpty || mimetype != null) map['mimetype'] = Variable<String>(mimetype);
    if (!nullToEmpty || fileSize != null) map['file_size'] = Variable<int>(fileSize);
    if (!nullToEmpty || createDate != null) map['create_date'] = Variable<String>(createDate);
    if (!nullToEmpty || downloadUrl != null) map['download_url'] = Variable<String>(downloadUrl);
    return map;
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lineId': serializer.toJson<int>(lineId),
      'name': serializer.toJson<String>(name),
      'filename': serializer.toJson<String?>(filename),
      'mimetype': serializer.toJson<String?>(mimetype),
      'fileSize': serializer.toJson<int?>(fileSize),
      'createDate': serializer.toJson<String?>(createDate),
      'downloadUrl': serializer.toJson<String?>(downloadUrl),
    };
  }
}

class $CachedAttachmentsTable extends CachedAttachments
    with TableInfo<$CachedAttachmentsTable, CachedAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAttachmentsTable(this.attachedDatabase, [this._alias]);

  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, type: DriftSqlType.int);
  late final GeneratedColumn<int> lineId = GeneratedColumn<int>('line_id', aliasedName, false, type: DriftSqlType.int);
  late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false, type: DriftSqlType.string, defaultValue: const Constant(''));
  late final GeneratedColumn<String> filename = GeneratedColumn<String>('filename', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<String> mimetype = GeneratedColumn<String>('mimetype', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>('file_size', aliasedName, true, type: DriftSqlType.int);
  late final GeneratedColumn<String> createDate = GeneratedColumn<String>('create_date', aliasedName, true, type: DriftSqlType.string);
  late final GeneratedColumn<String> downloadUrl = GeneratedColumn<String>('download_url', aliasedName, true, type: DriftSqlType.string);

  @override
  List<GeneratedColumn> get $columns => [id, lineId, name, filename, mimetype, fileSize, createDate, downloadUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => 'cached_attachments';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAttachment(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      lineId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}line_id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      filename: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}filename']),
      mimetype: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}mimetype']),
      fileSize: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}file_size']),
      createDate: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}create_date']),
      downloadUrl: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}download_url']),
    );
  }

  @override
  $CachedAttachmentsTable createAlias(String alias) {
    return $CachedAttachmentsTable(attachedDatabase, alias);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $CachedRoutesTable cachedRoutes = $CachedRoutesTable(this);
  late final $CachedRouteLinesTable cachedRouteLines = $CachedRouteLinesTable(this);
  late final $CachedOrderLinesTable cachedOrderLines = $CachedOrderLinesTable(this);
  late final $CachedAttachmentsTable cachedAttachments = $CachedAttachmentsTable(this);

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        cachedRoutes,
        cachedRouteLines,
        cachedOrderLines,
        cachedAttachments,
      ];
}
