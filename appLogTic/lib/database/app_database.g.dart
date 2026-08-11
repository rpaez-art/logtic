// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedRoutesTable extends CachedRoutes
    with TableInfo<$CachedRoutesTable, CachedRoute> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRoutesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _driverIdMeta = const VerificationMeta(
    'driverId',
  );
  @override
  late final GeneratedColumn<int> driverId = GeneratedColumn<int>(
    'driver_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _maxPriorityMeta = const VerificationMeta(
    'maxPriority',
  );
  @override
  late final GeneratedColumn<String> maxPriority = GeneratedColumn<String>(
    'max_priority',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<String> cachedAt = GeneratedColumn<String>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    driverId,
    name,
    state,
    maxPriority,
    date,
    startDate,
    endDate,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_routes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedRoute> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('driver_id')) {
      context.handle(
        _driverIdMeta,
        driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('max_priority')) {
      context.handle(
        _maxPriorityMeta,
        maxPriority.isAcceptableOrUnknown(
          data['max_priority']!,
          _maxPriorityMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedRoute map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRoute(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      driverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}driver_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      maxPriority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}max_priority'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      ),
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedRoutesTable createAlias(String alias) {
    return $CachedRoutesTable(attachedDatabase, alias);
  }
}

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
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['driver_id'] = Variable<int>(driverId);
    map['name'] = Variable<String>(name);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || maxPriority != null) {
      map['max_priority'] = Variable<String>(maxPriority);
    }
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<String>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    map['cached_at'] = Variable<String>(cachedAt);
    return map;
  }

  CachedRoutesCompanion toCompanion(bool nullToAbsent) {
    return CachedRoutesCompanion(
      id: Value(id),
      driverId: Value(driverId),
      name: Value(name),
      state: Value(state),
      maxPriority: maxPriority == null && nullToAbsent
          ? const Value.absent()
          : Value(maxPriority),
      date: Value(date),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedRoute.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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
  }) => CachedRoute(
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
  CachedRoute copyWithCompanion(CachedRoutesCompanion data) {
    return CachedRoute(
      id: data.id.present ? data.id.value : this.id,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      name: data.name.present ? data.name.value : this.name,
      state: data.state.present ? data.state.value : this.state,
      maxPriority: data.maxPriority.present
          ? data.maxPriority.value
          : this.maxPriority,
      date: data.date.present ? data.date.value : this.date,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedRoute(')
          ..write('id: $id, ')
          ..write('driverId: $driverId, ')
          ..write('name: $name, ')
          ..write('state: $state, ')
          ..write('maxPriority: $maxPriority, ')
          ..write('date: $date, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    driverId,
    name,
    state,
    maxPriority,
    date,
    startDate,
    endDate,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRoute &&
          other.id == this.id &&
          other.driverId == this.driverId &&
          other.name == this.name &&
          other.state == this.state &&
          other.maxPriority == this.maxPriority &&
          other.date == this.date &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.cachedAt == this.cachedAt);
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
  CachedRoutesCompanion.insert({
    this.id = const Value.absent(),
    required int driverId,
    this.name = const Value.absent(),
    this.state = const Value.absent(),
    this.maxPriority = const Value.absent(),
    this.date = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    required String cachedAt,
  }) : driverId = Value(driverId),
       cachedAt = Value(cachedAt);
  static Insertable<CachedRoute> custom({
    Expression<int>? id,
    Expression<int>? driverId,
    Expression<String>? name,
    Expression<String>? state,
    Expression<String>? maxPriority,
    Expression<String>? date,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<String>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (driverId != null) 'driver_id': driverId,
      if (name != null) 'name': name,
      if (state != null) 'state': state,
      if (maxPriority != null) 'max_priority': maxPriority,
      if (date != null) 'date': date,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedRoutesCompanion copyWith({
    Value<int>? id,
    Value<int>? driverId,
    Value<String>? name,
    Value<String>? state,
    Value<String?>? maxPriority,
    Value<String>? date,
    Value<String?>? startDate,
    Value<String?>? endDate,
    Value<String>? cachedAt,
  }) {
    return CachedRoutesCompanion(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      name: name ?? this.name,
      state: state ?? this.state,
      maxPriority: maxPriority ?? this.maxPriority,
      date: date ?? this.date,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<int>(driverId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (maxPriority.present) {
      map['max_priority'] = Variable<String>(maxPriority.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<String>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRoutesCompanion(')
          ..write('id: $id, ')
          ..write('driverId: $driverId, ')
          ..write('name: $name, ')
          ..write('state: $state, ')
          ..write('maxPriority: $maxPriority, ')
          ..write('date: $date, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedRouteLinesTable extends CachedRouteLines
    with TableInfo<$CachedRouteLinesTable, CachedRouteLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRouteLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routeIdMeta = const VerificationMeta(
    'routeId',
  );
  @override
  late final GeneratedColumn<int> routeId = GeneratedColumn<int>(
    'route_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _driverIdMeta = const VerificationMeta(
    'driverId',
  );
  @override
  late final GeneratedColumn<int> driverId = GeneratedColumn<int>(
    'driver_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partnerIdMeta = const VerificationMeta(
    'partnerId',
  );
  @override
  late final GeneratedColumn<int> partnerId = GeneratedColumn<int>(
    'partner_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partnerNameMeta = const VerificationMeta(
    'partnerName',
  );
  @override
  late final GeneratedColumn<String> partnerName = GeneratedColumn<String>(
    'partner_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _streetMeta = const VerificationMeta('street');
  @override
  late final GeneratedColumn<String> street = GeneratedColumn<String>(
    'street',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _obraMeta = const VerificationMeta('obra');
  @override
  late final GeneratedColumn<String> obra = GeneratedColumn<String>(
    'obra',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _scheduledTimeMeta = const VerificationMeta(
    'scheduledTime',
  );
  @override
  late final GeneratedColumn<String> scheduledTime = GeneratedColumn<String>(
    'scheduled_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pickupTimeMeta = const VerificationMeta(
    'pickupTime',
  );
  @override
  late final GeneratedColumn<String> pickupTime = GeneratedColumn<String>(
    'pickup_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderTypeMeta = const VerificationMeta(
    'orderType',
  );
  @override
  late final GeneratedColumn<String> orderType = GeneratedColumn<String>(
    'order_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderNameMeta = const VerificationMeta(
    'orderName',
  );
  @override
  late final GeneratedColumn<String> orderName = GeneratedColumn<String>(
    'order_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _incompleteReasonMeta = const VerificationMeta(
    'incompleteReason',
  );
  @override
  late final GeneratedColumn<String> incompleteReason = GeneratedColumn<String>(
    'incomplete_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _incompleteNotesMeta = const VerificationMeta(
    'incompleteNotes',
  );
  @override
  late final GeneratedColumn<String> incompleteNotes = GeneratedColumn<String>(
    'incomplete_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<String> cachedAt = GeneratedColumn<String>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routeId,
    driverId,
    partnerId,
    partnerName,
    street,
    city,
    latitude,
    longitude,
    sequence,
    notes,
    obra,
    priority,
    state,
    scheduledTime,
    startTime,
    pickupTime,
    endTime,
    orderType,
    orderName,
    incompleteReason,
    incompleteNotes,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_route_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedRouteLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('route_id')) {
      context.handle(
        _routeIdMeta,
        routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routeIdMeta);
    }
    if (data.containsKey('driver_id')) {
      context.handle(
        _driverIdMeta,
        driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta),
      );
    } else if (isInserting) {
      context.missing(_driverIdMeta);
    }
    if (data.containsKey('partner_id')) {
      context.handle(
        _partnerIdMeta,
        partnerId.isAcceptableOrUnknown(data['partner_id']!, _partnerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partnerIdMeta);
    }
    if (data.containsKey('partner_name')) {
      context.handle(
        _partnerNameMeta,
        partnerName.isAcceptableOrUnknown(
          data['partner_name']!,
          _partnerNameMeta,
        ),
      );
    }
    if (data.containsKey('street')) {
      context.handle(
        _streetMeta,
        street.isAcceptableOrUnknown(data['street']!, _streetMeta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('obra')) {
      context.handle(
        _obraMeta,
        obra.isAcceptableOrUnknown(data['obra']!, _obraMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('scheduled_time')) {
      context.handle(
        _scheduledTimeMeta,
        scheduledTime.isAcceptableOrUnknown(
          data['scheduled_time']!,
          _scheduledTimeMeta,
        ),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('pickup_time')) {
      context.handle(
        _pickupTimeMeta,
        pickupTime.isAcceptableOrUnknown(data['pickup_time']!, _pickupTimeMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('order_type')) {
      context.handle(
        _orderTypeMeta,
        orderType.isAcceptableOrUnknown(data['order_type']!, _orderTypeMeta),
      );
    }
    if (data.containsKey('order_name')) {
      context.handle(
        _orderNameMeta,
        orderName.isAcceptableOrUnknown(data['order_name']!, _orderNameMeta),
      );
    }
    if (data.containsKey('incomplete_reason')) {
      context.handle(
        _incompleteReasonMeta,
        incompleteReason.isAcceptableOrUnknown(
          data['incomplete_reason']!,
          _incompleteReasonMeta,
        ),
      );
    }
    if (data.containsKey('incomplete_notes')) {
      context.handle(
        _incompleteNotesMeta,
        incompleteNotes.isAcceptableOrUnknown(
          data['incomplete_notes']!,
          _incompleteNotesMeta,
        ),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedRouteLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRouteLine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      routeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}route_id'],
      )!,
      driverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}driver_id'],
      )!,
      partnerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}partner_id'],
      )!,
      partnerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_name'],
      )!,
      street: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}street'],
      ),
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      obra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}obra'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      scheduledTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scheduled_time'],
      ),
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      ),
      pickupTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pickup_time'],
      ),
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      ),
      orderType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_type'],
      ),
      orderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_name'],
      ),
      incompleteReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}incomplete_reason'],
      ),
      incompleteNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}incomplete_notes'],
      ),
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedRouteLinesTable createAlias(String alias) {
    return $CachedRouteLinesTable(attachedDatabase, alias);
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
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['route_id'] = Variable<int>(routeId);
    map['driver_id'] = Variable<int>(driverId);
    map['partner_id'] = Variable<int>(partnerId);
    map['partner_name'] = Variable<String>(partnerName);
    if (!nullToAbsent || street != null) {
      map['street'] = Variable<String>(street);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['sequence'] = Variable<int>(sequence);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || obra != null) {
      map['obra'] = Variable<String>(obra);
    }
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<String>(priority);
    }
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || scheduledTime != null) {
      map['scheduled_time'] = Variable<String>(scheduledTime);
    }
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<String>(startTime);
    }
    if (!nullToAbsent || pickupTime != null) {
      map['pickup_time'] = Variable<String>(pickupTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<String>(endTime);
    }
    if (!nullToAbsent || orderType != null) {
      map['order_type'] = Variable<String>(orderType);
    }
    if (!nullToAbsent || orderName != null) {
      map['order_name'] = Variable<String>(orderName);
    }
    if (!nullToAbsent || incompleteReason != null) {
      map['incomplete_reason'] = Variable<String>(incompleteReason);
    }
    if (!nullToAbsent || incompleteNotes != null) {
      map['incomplete_notes'] = Variable<String>(incompleteNotes);
    }
    map['cached_at'] = Variable<String>(cachedAt);
    return map;
  }

  CachedRouteLinesCompanion toCompanion(bool nullToAbsent) {
    return CachedRouteLinesCompanion(
      id: Value(id),
      routeId: Value(routeId),
      driverId: Value(driverId),
      partnerId: Value(partnerId),
      partnerName: Value(partnerName),
      street: street == null && nullToAbsent
          ? const Value.absent()
          : Value(street),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      sequence: Value(sequence),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      obra: obra == null && nullToAbsent ? const Value.absent() : Value(obra),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      state: Value(state),
      scheduledTime: scheduledTime == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledTime),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      pickupTime: pickupTime == null && nullToAbsent
          ? const Value.absent()
          : Value(pickupTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      orderType: orderType == null && nullToAbsent
          ? const Value.absent()
          : Value(orderType),
      orderName: orderName == null && nullToAbsent
          ? const Value.absent()
          : Value(orderName),
      incompleteReason: incompleteReason == null && nullToAbsent
          ? const Value.absent()
          : Value(incompleteReason),
      incompleteNotes: incompleteNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(incompleteNotes),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedRouteLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRouteLine(
      id: serializer.fromJson<int>(json['id']),
      routeId: serializer.fromJson<int>(json['routeId']),
      driverId: serializer.fromJson<int>(json['driverId']),
      partnerId: serializer.fromJson<int>(json['partnerId']),
      partnerName: serializer.fromJson<String>(json['partnerName']),
      street: serializer.fromJson<String?>(json['street']),
      city: serializer.fromJson<String?>(json['city']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      sequence: serializer.fromJson<int>(json['sequence']),
      notes: serializer.fromJson<String?>(json['notes']),
      obra: serializer.fromJson<String?>(json['obra']),
      priority: serializer.fromJson<String?>(json['priority']),
      state: serializer.fromJson<String>(json['state']),
      scheduledTime: serializer.fromJson<String?>(json['scheduledTime']),
      startTime: serializer.fromJson<String?>(json['startTime']),
      pickupTime: serializer.fromJson<String?>(json['pickupTime']),
      endTime: serializer.fromJson<String?>(json['endTime']),
      orderType: serializer.fromJson<String?>(json['orderType']),
      orderName: serializer.fromJson<String?>(json['orderName']),
      incompleteReason: serializer.fromJson<String?>(json['incompleteReason']),
      incompleteNotes: serializer.fromJson<String?>(json['incompleteNotes']),
      cachedAt: serializer.fromJson<String>(json['cachedAt']),
    );
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

  CachedRouteLine copyWith({
    int? id,
    int? routeId,
    int? driverId,
    int? partnerId,
    String? partnerName,
    Value<String?> street = const Value.absent(),
    Value<String?> city = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    int? sequence,
    Value<String?> notes = const Value.absent(),
    Value<String?> obra = const Value.absent(),
    Value<String?> priority = const Value.absent(),
    String? state,
    Value<String?> scheduledTime = const Value.absent(),
    Value<String?> startTime = const Value.absent(),
    Value<String?> pickupTime = const Value.absent(),
    Value<String?> endTime = const Value.absent(),
    Value<String?> orderType = const Value.absent(),
    Value<String?> orderName = const Value.absent(),
    Value<String?> incompleteReason = const Value.absent(),
    Value<String?> incompleteNotes = const Value.absent(),
    String? cachedAt,
  }) => CachedRouteLine(
    id: id ?? this.id,
    routeId: routeId ?? this.routeId,
    driverId: driverId ?? this.driverId,
    partnerId: partnerId ?? this.partnerId,
    partnerName: partnerName ?? this.partnerName,
    street: street.present ? street.value : this.street,
    city: city.present ? city.value : this.city,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    sequence: sequence ?? this.sequence,
    notes: notes.present ? notes.value : this.notes,
    obra: obra.present ? obra.value : this.obra,
    priority: priority.present ? priority.value : this.priority,
    state: state ?? this.state,
    scheduledTime: scheduledTime.present
        ? scheduledTime.value
        : this.scheduledTime,
    startTime: startTime.present ? startTime.value : this.startTime,
    pickupTime: pickupTime.present ? pickupTime.value : this.pickupTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    orderType: orderType.present ? orderType.value : this.orderType,
    orderName: orderName.present ? orderName.value : this.orderName,
    incompleteReason: incompleteReason.present
        ? incompleteReason.value
        : this.incompleteReason,
    incompleteNotes: incompleteNotes.present
        ? incompleteNotes.value
        : this.incompleteNotes,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedRouteLine copyWithCompanion(CachedRouteLinesCompanion data) {
    return CachedRouteLine(
      id: data.id.present ? data.id.value : this.id,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      partnerId: data.partnerId.present ? data.partnerId.value : this.partnerId,
      partnerName: data.partnerName.present
          ? data.partnerName.value
          : this.partnerName,
      street: data.street.present ? data.street.value : this.street,
      city: data.city.present ? data.city.value : this.city,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      notes: data.notes.present ? data.notes.value : this.notes,
      obra: data.obra.present ? data.obra.value : this.obra,
      priority: data.priority.present ? data.priority.value : this.priority,
      state: data.state.present ? data.state.value : this.state,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      pickupTime: data.pickupTime.present
          ? data.pickupTime.value
          : this.pickupTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      orderType: data.orderType.present ? data.orderType.value : this.orderType,
      orderName: data.orderName.present ? data.orderName.value : this.orderName,
      incompleteReason: data.incompleteReason.present
          ? data.incompleteReason.value
          : this.incompleteReason,
      incompleteNotes: data.incompleteNotes.present
          ? data.incompleteNotes.value
          : this.incompleteNotes,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedRouteLine(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('driverId: $driverId, ')
          ..write('partnerId: $partnerId, ')
          ..write('partnerName: $partnerName, ')
          ..write('street: $street, ')
          ..write('city: $city, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('sequence: $sequence, ')
          ..write('notes: $notes, ')
          ..write('obra: $obra, ')
          ..write('priority: $priority, ')
          ..write('state: $state, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('startTime: $startTime, ')
          ..write('pickupTime: $pickupTime, ')
          ..write('endTime: $endTime, ')
          ..write('orderType: $orderType, ')
          ..write('orderName: $orderName, ')
          ..write('incompleteReason: $incompleteReason, ')
          ..write('incompleteNotes: $incompleteNotes, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    routeId,
    driverId,
    partnerId,
    partnerName,
    street,
    city,
    latitude,
    longitude,
    sequence,
    notes,
    obra,
    priority,
    state,
    scheduledTime,
    startTime,
    pickupTime,
    endTime,
    orderType,
    orderName,
    incompleteReason,
    incompleteNotes,
    cachedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRouteLine &&
          other.id == this.id &&
          other.routeId == this.routeId &&
          other.driverId == this.driverId &&
          other.partnerId == this.partnerId &&
          other.partnerName == this.partnerName &&
          other.street == this.street &&
          other.city == this.city &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.sequence == this.sequence &&
          other.notes == this.notes &&
          other.obra == this.obra &&
          other.priority == this.priority &&
          other.state == this.state &&
          other.scheduledTime == this.scheduledTime &&
          other.startTime == this.startTime &&
          other.pickupTime == this.pickupTime &&
          other.endTime == this.endTime &&
          other.orderType == this.orderType &&
          other.orderName == this.orderName &&
          other.incompleteReason == this.incompleteReason &&
          other.incompleteNotes == this.incompleteNotes &&
          other.cachedAt == this.cachedAt);
}

class CachedRouteLinesCompanion extends UpdateCompanion<CachedRouteLine> {
  final Value<int> id;
  final Value<int> routeId;
  final Value<int> driverId;
  final Value<int> partnerId;
  final Value<String> partnerName;
  final Value<String?> street;
  final Value<String?> city;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int> sequence;
  final Value<String?> notes;
  final Value<String?> obra;
  final Value<String?> priority;
  final Value<String> state;
  final Value<String?> scheduledTime;
  final Value<String?> startTime;
  final Value<String?> pickupTime;
  final Value<String?> endTime;
  final Value<String?> orderType;
  final Value<String?> orderName;
  final Value<String?> incompleteReason;
  final Value<String?> incompleteNotes;
  final Value<String> cachedAt;
  const CachedRouteLinesCompanion({
    this.id = const Value.absent(),
    this.routeId = const Value.absent(),
    this.driverId = const Value.absent(),
    this.partnerId = const Value.absent(),
    this.partnerName = const Value.absent(),
    this.street = const Value.absent(),
    this.city = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.sequence = const Value.absent(),
    this.notes = const Value.absent(),
    this.obra = const Value.absent(),
    this.priority = const Value.absent(),
    this.state = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.startTime = const Value.absent(),
    this.pickupTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.orderType = const Value.absent(),
    this.orderName = const Value.absent(),
    this.incompleteReason = const Value.absent(),
    this.incompleteNotes = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedRouteLinesCompanion.insert({
    this.id = const Value.absent(),
    required int routeId,
    required int driverId,
    required int partnerId,
    this.partnerName = const Value.absent(),
    this.street = const Value.absent(),
    this.city = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.sequence = const Value.absent(),
    this.notes = const Value.absent(),
    this.obra = const Value.absent(),
    this.priority = const Value.absent(),
    this.state = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.startTime = const Value.absent(),
    this.pickupTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.orderType = const Value.absent(),
    this.orderName = const Value.absent(),
    this.incompleteReason = const Value.absent(),
    this.incompleteNotes = const Value.absent(),
    required String cachedAt,
  }) : routeId = Value(routeId),
       driverId = Value(driverId),
       partnerId = Value(partnerId),
       cachedAt = Value(cachedAt);
  static Insertable<CachedRouteLine> custom({
    Expression<int>? id,
    Expression<int>? routeId,
    Expression<int>? driverId,
    Expression<int>? partnerId,
    Expression<String>? partnerName,
    Expression<String>? street,
    Expression<String>? city,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? sequence,
    Expression<String>? notes,
    Expression<String>? obra,
    Expression<String>? priority,
    Expression<String>? state,
    Expression<String>? scheduledTime,
    Expression<String>? startTime,
    Expression<String>? pickupTime,
    Expression<String>? endTime,
    Expression<String>? orderType,
    Expression<String>? orderName,
    Expression<String>? incompleteReason,
    Expression<String>? incompleteNotes,
    Expression<String>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routeId != null) 'route_id': routeId,
      if (driverId != null) 'driver_id': driverId,
      if (partnerId != null) 'partner_id': partnerId,
      if (partnerName != null) 'partner_name': partnerName,
      if (street != null) 'street': street,
      if (city != null) 'city': city,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (sequence != null) 'sequence': sequence,
      if (notes != null) 'notes': notes,
      if (obra != null) 'obra': obra,
      if (priority != null) 'priority': priority,
      if (state != null) 'state': state,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (startTime != null) 'start_time': startTime,
      if (pickupTime != null) 'pickup_time': pickupTime,
      if (endTime != null) 'end_time': endTime,
      if (orderType != null) 'order_type': orderType,
      if (orderName != null) 'order_name': orderName,
      if (incompleteReason != null) 'incomplete_reason': incompleteReason,
      if (incompleteNotes != null) 'incomplete_notes': incompleteNotes,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedRouteLinesCompanion copyWith({
    Value<int>? id,
    Value<int>? routeId,
    Value<int>? driverId,
    Value<int>? partnerId,
    Value<String>? partnerName,
    Value<String?>? street,
    Value<String?>? city,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<int>? sequence,
    Value<String?>? notes,
    Value<String?>? obra,
    Value<String?>? priority,
    Value<String>? state,
    Value<String?>? scheduledTime,
    Value<String?>? startTime,
    Value<String?>? pickupTime,
    Value<String?>? endTime,
    Value<String?>? orderType,
    Value<String?>? orderName,
    Value<String?>? incompleteReason,
    Value<String?>? incompleteNotes,
    Value<String>? cachedAt,
  }) {
    return CachedRouteLinesCompanion(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      driverId: driverId ?? this.driverId,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      street: street ?? this.street,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sequence: sequence ?? this.sequence,
      notes: notes ?? this.notes,
      obra: obra ?? this.obra,
      priority: priority ?? this.priority,
      state: state ?? this.state,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      startTime: startTime ?? this.startTime,
      pickupTime: pickupTime ?? this.pickupTime,
      endTime: endTime ?? this.endTime,
      orderType: orderType ?? this.orderType,
      orderName: orderName ?? this.orderName,
      incompleteReason: incompleteReason ?? this.incompleteReason,
      incompleteNotes: incompleteNotes ?? this.incompleteNotes,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routeId.present) {
      map['route_id'] = Variable<int>(routeId.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<int>(driverId.value);
    }
    if (partnerId.present) {
      map['partner_id'] = Variable<int>(partnerId.value);
    }
    if (partnerName.present) {
      map['partner_name'] = Variable<String>(partnerName.value);
    }
    if (street.present) {
      map['street'] = Variable<String>(street.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (obra.present) {
      map['obra'] = Variable<String>(obra.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<String>(scheduledTime.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (pickupTime.present) {
      map['pickup_time'] = Variable<String>(pickupTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (orderType.present) {
      map['order_type'] = Variable<String>(orderType.value);
    }
    if (orderName.present) {
      map['order_name'] = Variable<String>(orderName.value);
    }
    if (incompleteReason.present) {
      map['incomplete_reason'] = Variable<String>(incompleteReason.value);
    }
    if (incompleteNotes.present) {
      map['incomplete_notes'] = Variable<String>(incompleteNotes.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<String>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRouteLinesCompanion(')
          ..write('id: $id, ')
          ..write('routeId: $routeId, ')
          ..write('driverId: $driverId, ')
          ..write('partnerId: $partnerId, ')
          ..write('partnerName: $partnerName, ')
          ..write('street: $street, ')
          ..write('city: $city, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('sequence: $sequence, ')
          ..write('notes: $notes, ')
          ..write('obra: $obra, ')
          ..write('priority: $priority, ')
          ..write('state: $state, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('startTime: $startTime, ')
          ..write('pickupTime: $pickupTime, ')
          ..write('endTime: $endTime, ')
          ..write('orderType: $orderType, ')
          ..write('orderName: $orderName, ')
          ..write('incompleteReason: $incompleteReason, ')
          ..write('incompleteNotes: $incompleteNotes, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedOrderLinesTable extends CachedOrderLines
    with TableInfo<$CachedOrderLinesTable, CachedOrderLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedOrderLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _lineIdMeta = const VerificationMeta('lineId');
  @override
  late final GeneratedColumn<int> lineId = GeneratedColumn<int>(
    'line_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _uomMeta = const VerificationMeta('uom');
  @override
  late final GeneratedColumn<String> uom = GeneratedColumn<String>(
    'uom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _priceUnitMeta = const VerificationMeta(
    'priceUnit',
  );
  @override
  late final GeneratedColumn<double> priceUnit = GeneratedColumn<double>(
    'price_unit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lineId,
    productName,
    quantity,
    uom,
    priceUnit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_order_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedOrderLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('line_id')) {
      context.handle(
        _lineIdMeta,
        lineId.isAcceptableOrUnknown(data['line_id']!, _lineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lineIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('uom')) {
      context.handle(
        _uomMeta,
        uom.isAcceptableOrUnknown(data['uom']!, _uomMeta),
      );
    }
    if (data.containsKey('price_unit')) {
      context.handle(
        _priceUnitMeta,
        priceUnit.isAcceptableOrUnknown(data['price_unit']!, _priceUnitMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedOrderLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedOrderLine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      uom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uom'],
      )!,
      priceUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_unit'],
      )!,
    );
  }

  @override
  $CachedOrderLinesTable createAlias(String alias) {
    return $CachedOrderLinesTable(attachedDatabase, alias);
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
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['line_id'] = Variable<int>(lineId);
    map['product_name'] = Variable<String>(productName);
    map['quantity'] = Variable<double>(quantity);
    map['uom'] = Variable<String>(uom);
    map['price_unit'] = Variable<double>(priceUnit);
    return map;
  }

  CachedOrderLinesCompanion toCompanion(bool nullToAbsent) {
    return CachedOrderLinesCompanion(
      id: Value(id),
      lineId: Value(lineId),
      productName: Value(productName),
      quantity: Value(quantity),
      uom: Value(uom),
      priceUnit: Value(priceUnit),
    );
  }

  factory CachedOrderLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedOrderLine(
      id: serializer.fromJson<int>(json['id']),
      lineId: serializer.fromJson<int>(json['lineId']),
      productName: serializer.fromJson<String>(json['productName']),
      quantity: serializer.fromJson<double>(json['quantity']),
      uom: serializer.fromJson<String>(json['uom']),
      priceUnit: serializer.fromJson<double>(json['priceUnit']),
    );
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

  CachedOrderLine copyWith({
    int? id,
    int? lineId,
    String? productName,
    double? quantity,
    String? uom,
    double? priceUnit,
  }) => CachedOrderLine(
    id: id ?? this.id,
    lineId: lineId ?? this.lineId,
    productName: productName ?? this.productName,
    quantity: quantity ?? this.quantity,
    uom: uom ?? this.uom,
    priceUnit: priceUnit ?? this.priceUnit,
  );
  CachedOrderLine copyWithCompanion(CachedOrderLinesCompanion data) {
    return CachedOrderLine(
      id: data.id.present ? data.id.value : this.id,
      lineId: data.lineId.present ? data.lineId.value : this.lineId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      uom: data.uom.present ? data.uom.value : this.uom,
      priceUnit: data.priceUnit.present ? data.priceUnit.value : this.priceUnit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedOrderLine(')
          ..write('id: $id, ')
          ..write('lineId: $lineId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('uom: $uom, ')
          ..write('priceUnit: $priceUnit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, lineId, productName, quantity, uom, priceUnit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedOrderLine &&
          other.id == this.id &&
          other.lineId == this.lineId &&
          other.productName == this.productName &&
          other.quantity == this.quantity &&
          other.uom == this.uom &&
          other.priceUnit == this.priceUnit);
}

class CachedOrderLinesCompanion extends UpdateCompanion<CachedOrderLine> {
  final Value<int> id;
  final Value<int> lineId;
  final Value<String> productName;
  final Value<double> quantity;
  final Value<String> uom;
  final Value<double> priceUnit;
  const CachedOrderLinesCompanion({
    this.id = const Value.absent(),
    this.lineId = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.uom = const Value.absent(),
    this.priceUnit = const Value.absent(),
  });
  CachedOrderLinesCompanion.insert({
    this.id = const Value.absent(),
    required int lineId,
    this.productName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.uom = const Value.absent(),
    this.priceUnit = const Value.absent(),
  }) : lineId = Value(lineId);
  static Insertable<CachedOrderLine> custom({
    Expression<int>? id,
    Expression<int>? lineId,
    Expression<String>? productName,
    Expression<double>? quantity,
    Expression<String>? uom,
    Expression<double>? priceUnit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lineId != null) 'line_id': lineId,
      if (productName != null) 'product_name': productName,
      if (quantity != null) 'quantity': quantity,
      if (uom != null) 'uom': uom,
      if (priceUnit != null) 'price_unit': priceUnit,
    });
  }

  CachedOrderLinesCompanion copyWith({
    Value<int>? id,
    Value<int>? lineId,
    Value<String>? productName,
    Value<double>? quantity,
    Value<String>? uom,
    Value<double>? priceUnit,
  }) {
    return CachedOrderLinesCompanion(
      id: id ?? this.id,
      lineId: lineId ?? this.lineId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      uom: uom ?? this.uom,
      priceUnit: priceUnit ?? this.priceUnit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lineId.present) {
      map['line_id'] = Variable<int>(lineId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (uom.present) {
      map['uom'] = Variable<String>(uom.value);
    }
    if (priceUnit.present) {
      map['price_unit'] = Variable<double>(priceUnit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedOrderLinesCompanion(')
          ..write('id: $id, ')
          ..write('lineId: $lineId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('uom: $uom, ')
          ..write('priceUnit: $priceUnit')
          ..write(')'))
        .toString();
  }
}

class $CachedAttachmentsTable extends CachedAttachments
    with TableInfo<$CachedAttachmentsTable, CachedAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lineIdMeta = const VerificationMeta('lineId');
  @override
  late final GeneratedColumn<int> lineId = GeneratedColumn<int>(
    'line_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _filenameMeta = const VerificationMeta(
    'filename',
  );
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
    'filename',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimetypeMeta = const VerificationMeta(
    'mimetype',
  );
  @override
  late final GeneratedColumn<String> mimetype = GeneratedColumn<String>(
    'mimetype',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createDateMeta = const VerificationMeta(
    'createDate',
  );
  @override
  late final GeneratedColumn<String> createDate = GeneratedColumn<String>(
    'create_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadUrlMeta = const VerificationMeta(
    'downloadUrl',
  );
  @override
  late final GeneratedColumn<String> downloadUrl = GeneratedColumn<String>(
    'download_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lineId,
    name,
    filename,
    mimetype,
    fileSize,
    createDate,
    downloadUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('line_id')) {
      context.handle(
        _lineIdMeta,
        lineId.isAcceptableOrUnknown(data['line_id']!, _lineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lineIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('filename')) {
      context.handle(
        _filenameMeta,
        filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta),
      );
    }
    if (data.containsKey('mimetype')) {
      context.handle(
        _mimetypeMeta,
        mimetype.isAcceptableOrUnknown(data['mimetype']!, _mimetypeMeta),
      );
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('create_date')) {
      context.handle(
        _createDateMeta,
        createDate.isAcceptableOrUnknown(data['create_date']!, _createDateMeta),
      );
    }
    if (data.containsKey('download_url')) {
      context.handle(
        _downloadUrlMeta,
        downloadUrl.isAcceptableOrUnknown(
          data['download_url']!,
          _downloadUrlMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      filename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filename'],
      ),
      mimetype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mimetype'],
      ),
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      ),
      createDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}create_date'],
      ),
      downloadUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}download_url'],
      ),
    );
  }

  @override
  $CachedAttachmentsTable createAlias(String alias) {
    return $CachedAttachmentsTable(attachedDatabase, alias);
  }
}

class CachedAttachment extends DataClass
    implements Insertable<CachedAttachment> {
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
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['line_id'] = Variable<int>(lineId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || filename != null) {
      map['filename'] = Variable<String>(filename);
    }
    if (!nullToAbsent || mimetype != null) {
      map['mimetype'] = Variable<String>(mimetype);
    }
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    if (!nullToAbsent || createDate != null) {
      map['create_date'] = Variable<String>(createDate);
    }
    if (!nullToAbsent || downloadUrl != null) {
      map['download_url'] = Variable<String>(downloadUrl);
    }
    return map;
  }

  CachedAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return CachedAttachmentsCompanion(
      id: Value(id),
      lineId: Value(lineId),
      name: Value(name),
      filename: filename == null && nullToAbsent
          ? const Value.absent()
          : Value(filename),
      mimetype: mimetype == null && nullToAbsent
          ? const Value.absent()
          : Value(mimetype),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      createDate: createDate == null && nullToAbsent
          ? const Value.absent()
          : Value(createDate),
      downloadUrl: downloadUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadUrl),
    );
  }

  factory CachedAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAttachment(
      id: serializer.fromJson<int>(json['id']),
      lineId: serializer.fromJson<int>(json['lineId']),
      name: serializer.fromJson<String>(json['name']),
      filename: serializer.fromJson<String?>(json['filename']),
      mimetype: serializer.fromJson<String?>(json['mimetype']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      createDate: serializer.fromJson<String?>(json['createDate']),
      downloadUrl: serializer.fromJson<String?>(json['downloadUrl']),
    );
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

  CachedAttachment copyWith({
    int? id,
    int? lineId,
    String? name,
    Value<String?> filename = const Value.absent(),
    Value<String?> mimetype = const Value.absent(),
    Value<int?> fileSize = const Value.absent(),
    Value<String?> createDate = const Value.absent(),
    Value<String?> downloadUrl = const Value.absent(),
  }) => CachedAttachment(
    id: id ?? this.id,
    lineId: lineId ?? this.lineId,
    name: name ?? this.name,
    filename: filename.present ? filename.value : this.filename,
    mimetype: mimetype.present ? mimetype.value : this.mimetype,
    fileSize: fileSize.present ? fileSize.value : this.fileSize,
    createDate: createDate.present ? createDate.value : this.createDate,
    downloadUrl: downloadUrl.present ? downloadUrl.value : this.downloadUrl,
  );
  CachedAttachment copyWithCompanion(CachedAttachmentsCompanion data) {
    return CachedAttachment(
      id: data.id.present ? data.id.value : this.id,
      lineId: data.lineId.present ? data.lineId.value : this.lineId,
      name: data.name.present ? data.name.value : this.name,
      filename: data.filename.present ? data.filename.value : this.filename,
      mimetype: data.mimetype.present ? data.mimetype.value : this.mimetype,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      createDate: data.createDate.present
          ? data.createDate.value
          : this.createDate,
      downloadUrl: data.downloadUrl.present
          ? data.downloadUrl.value
          : this.downloadUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAttachment(')
          ..write('id: $id, ')
          ..write('lineId: $lineId, ')
          ..write('name: $name, ')
          ..write('filename: $filename, ')
          ..write('mimetype: $mimetype, ')
          ..write('fileSize: $fileSize, ')
          ..write('createDate: $createDate, ')
          ..write('downloadUrl: $downloadUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lineId,
    name,
    filename,
    mimetype,
    fileSize,
    createDate,
    downloadUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAttachment &&
          other.id == this.id &&
          other.lineId == this.lineId &&
          other.name == this.name &&
          other.filename == this.filename &&
          other.mimetype == this.mimetype &&
          other.fileSize == this.fileSize &&
          other.createDate == this.createDate &&
          other.downloadUrl == this.downloadUrl);
}

class CachedAttachmentsCompanion extends UpdateCompanion<CachedAttachment> {
  final Value<int> id;
  final Value<int> lineId;
  final Value<String> name;
  final Value<String?> filename;
  final Value<String?> mimetype;
  final Value<int?> fileSize;
  final Value<String?> createDate;
  final Value<String?> downloadUrl;
  const CachedAttachmentsCompanion({
    this.id = const Value.absent(),
    this.lineId = const Value.absent(),
    this.name = const Value.absent(),
    this.filename = const Value.absent(),
    this.mimetype = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.createDate = const Value.absent(),
    this.downloadUrl = const Value.absent(),
  });
  CachedAttachmentsCompanion.insert({
    this.id = const Value.absent(),
    required int lineId,
    this.name = const Value.absent(),
    this.filename = const Value.absent(),
    this.mimetype = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.createDate = const Value.absent(),
    this.downloadUrl = const Value.absent(),
  }) : lineId = Value(lineId);
  static Insertable<CachedAttachment> custom({
    Expression<int>? id,
    Expression<int>? lineId,
    Expression<String>? name,
    Expression<String>? filename,
    Expression<String>? mimetype,
    Expression<int>? fileSize,
    Expression<String>? createDate,
    Expression<String>? downloadUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lineId != null) 'line_id': lineId,
      if (name != null) 'name': name,
      if (filename != null) 'filename': filename,
      if (mimetype != null) 'mimetype': mimetype,
      if (fileSize != null) 'file_size': fileSize,
      if (createDate != null) 'create_date': createDate,
      if (downloadUrl != null) 'download_url': downloadUrl,
    });
  }

  CachedAttachmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? lineId,
    Value<String>? name,
    Value<String?>? filename,
    Value<String?>? mimetype,
    Value<int?>? fileSize,
    Value<String?>? createDate,
    Value<String?>? downloadUrl,
  }) {
    return CachedAttachmentsCompanion(
      id: id ?? this.id,
      lineId: lineId ?? this.lineId,
      name: name ?? this.name,
      filename: filename ?? this.filename,
      mimetype: mimetype ?? this.mimetype,
      fileSize: fileSize ?? this.fileSize,
      createDate: createDate ?? this.createDate,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lineId.present) {
      map['line_id'] = Variable<int>(lineId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (mimetype.present) {
      map['mimetype'] = Variable<String>(mimetype.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (createDate.present) {
      map['create_date'] = Variable<String>(createDate.value);
    }
    if (downloadUrl.present) {
      map['download_url'] = Variable<String>(downloadUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('lineId: $lineId, ')
          ..write('name: $name, ')
          ..write('filename: $filename, ')
          ..write('mimetype: $mimetype, ')
          ..write('fileSize: $fileSize, ')
          ..write('createDate: $createDate, ')
          ..write('downloadUrl: $downloadUrl')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedRoutesTable cachedRoutes = $CachedRoutesTable(this);
  late final $CachedRouteLinesTable cachedRouteLines = $CachedRouteLinesTable(
    this,
  );
  late final $CachedOrderLinesTable cachedOrderLines = $CachedOrderLinesTable(
    this,
  );
  late final $CachedAttachmentsTable cachedAttachments =
      $CachedAttachmentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedRoutes,
    cachedRouteLines,
    cachedOrderLines,
    cachedAttachments,
  ];
}

typedef $$CachedRoutesTableCreateCompanionBuilder =
    CachedRoutesCompanion Function({
      Value<int> id,
      required int driverId,
      Value<String> name,
      Value<String> state,
      Value<String?> maxPriority,
      Value<String> date,
      Value<String?> startDate,
      Value<String?> endDate,
      required String cachedAt,
    });
typedef $$CachedRoutesTableUpdateCompanionBuilder =
    CachedRoutesCompanion Function({
      Value<int> id,
      Value<int> driverId,
      Value<String> name,
      Value<String> state,
      Value<String?> maxPriority,
      Value<String> date,
      Value<String?> startDate,
      Value<String?> endDate,
      Value<String> cachedAt,
    });

class $$CachedRoutesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedRoutesTable> {
  $$CachedRoutesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get driverId => $composableBuilder(
    column: $table.driverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maxPriority => $composableBuilder(
    column: $table.maxPriority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedRoutesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedRoutesTable> {
  $$CachedRoutesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get driverId => $composableBuilder(
    column: $table.driverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maxPriority => $composableBuilder(
    column: $table.maxPriority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedRoutesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedRoutesTable> {
  $$CachedRoutesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get driverId =>
      $composableBuilder(column: $table.driverId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get maxPriority => $composableBuilder(
    column: $table.maxPriority,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedRoutesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedRoutesTable,
          CachedRoute,
          $$CachedRoutesTableFilterComposer,
          $$CachedRoutesTableOrderingComposer,
          $$CachedRoutesTableAnnotationComposer,
          $$CachedRoutesTableCreateCompanionBuilder,
          $$CachedRoutesTableUpdateCompanionBuilder,
          (
            CachedRoute,
            BaseReferences<_$AppDatabase, $CachedRoutesTable, CachedRoute>,
          ),
          CachedRoute,
          PrefetchHooks Function()
        > {
  $$CachedRoutesTableTableManager(_$AppDatabase db, $CachedRoutesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedRoutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedRoutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedRoutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> driverId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> maxPriority = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String?> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<String> cachedAt = const Value.absent(),
              }) => CachedRoutesCompanion(
                id: id,
                driverId: driverId,
                name: name,
                state: state,
                maxPriority: maxPriority,
                date: date,
                startDate: startDate,
                endDate: endDate,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int driverId,
                Value<String> name = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> maxPriority = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String?> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                required String cachedAt,
              }) => CachedRoutesCompanion.insert(
                id: id,
                driverId: driverId,
                name: name,
                state: state,
                maxPriority: maxPriority,
                date: date,
                startDate: startDate,
                endDate: endDate,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedRoutesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedRoutesTable,
      CachedRoute,
      $$CachedRoutesTableFilterComposer,
      $$CachedRoutesTableOrderingComposer,
      $$CachedRoutesTableAnnotationComposer,
      $$CachedRoutesTableCreateCompanionBuilder,
      $$CachedRoutesTableUpdateCompanionBuilder,
      (
        CachedRoute,
        BaseReferences<_$AppDatabase, $CachedRoutesTable, CachedRoute>,
      ),
      CachedRoute,
      PrefetchHooks Function()
    >;
typedef $$CachedRouteLinesTableCreateCompanionBuilder =
    CachedRouteLinesCompanion Function({
      Value<int> id,
      required int routeId,
      required int driverId,
      required int partnerId,
      Value<String> partnerName,
      Value<String?> street,
      Value<String?> city,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int> sequence,
      Value<String?> notes,
      Value<String?> obra,
      Value<String?> priority,
      Value<String> state,
      Value<String?> scheduledTime,
      Value<String?> startTime,
      Value<String?> pickupTime,
      Value<String?> endTime,
      Value<String?> orderType,
      Value<String?> orderName,
      Value<String?> incompleteReason,
      Value<String?> incompleteNotes,
      required String cachedAt,
    });
typedef $$CachedRouteLinesTableUpdateCompanionBuilder =
    CachedRouteLinesCompanion Function({
      Value<int> id,
      Value<int> routeId,
      Value<int> driverId,
      Value<int> partnerId,
      Value<String> partnerName,
      Value<String?> street,
      Value<String?> city,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int> sequence,
      Value<String?> notes,
      Value<String?> obra,
      Value<String?> priority,
      Value<String> state,
      Value<String?> scheduledTime,
      Value<String?> startTime,
      Value<String?> pickupTime,
      Value<String?> endTime,
      Value<String?> orderType,
      Value<String?> orderName,
      Value<String?> incompleteReason,
      Value<String?> incompleteNotes,
      Value<String> cachedAt,
    });

class $$CachedRouteLinesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedRouteLinesTable> {
  $$CachedRouteLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get routeId => $composableBuilder(
    column: $table.routeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get driverId => $composableBuilder(
    column: $table.driverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get partnerId => $composableBuilder(
    column: $table.partnerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get obra => $composableBuilder(
    column: $table.obra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pickupTime => $composableBuilder(
    column: $table.pickupTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderType => $composableBuilder(
    column: $table.orderType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderName => $composableBuilder(
    column: $table.orderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get incompleteReason => $composableBuilder(
    column: $table.incompleteReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get incompleteNotes => $composableBuilder(
    column: $table.incompleteNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedRouteLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedRouteLinesTable> {
  $$CachedRouteLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get routeId => $composableBuilder(
    column: $table.routeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get driverId => $composableBuilder(
    column: $table.driverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get partnerId => $composableBuilder(
    column: $table.partnerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get obra => $composableBuilder(
    column: $table.obra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pickupTime => $composableBuilder(
    column: $table.pickupTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderType => $composableBuilder(
    column: $table.orderType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderName => $composableBuilder(
    column: $table.orderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get incompleteReason => $composableBuilder(
    column: $table.incompleteReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get incompleteNotes => $composableBuilder(
    column: $table.incompleteNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedRouteLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedRouteLinesTable> {
  $$CachedRouteLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get routeId =>
      $composableBuilder(column: $table.routeId, builder: (column) => column);

  GeneratedColumn<int> get driverId =>
      $composableBuilder(column: $table.driverId, builder: (column) => column);

  GeneratedColumn<int> get partnerId =>
      $composableBuilder(column: $table.partnerId, builder: (column) => column);

  GeneratedColumn<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get street =>
      $composableBuilder(column: $table.street, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get obra =>
      $composableBuilder(column: $table.obra, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get pickupTime => $composableBuilder(
    column: $table.pickupTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get orderType =>
      $composableBuilder(column: $table.orderType, builder: (column) => column);

  GeneratedColumn<String> get orderName =>
      $composableBuilder(column: $table.orderName, builder: (column) => column);

  GeneratedColumn<String> get incompleteReason => $composableBuilder(
    column: $table.incompleteReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get incompleteNotes => $composableBuilder(
    column: $table.incompleteNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedRouteLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedRouteLinesTable,
          CachedRouteLine,
          $$CachedRouteLinesTableFilterComposer,
          $$CachedRouteLinesTableOrderingComposer,
          $$CachedRouteLinesTableAnnotationComposer,
          $$CachedRouteLinesTableCreateCompanionBuilder,
          $$CachedRouteLinesTableUpdateCompanionBuilder,
          (
            CachedRouteLine,
            BaseReferences<
              _$AppDatabase,
              $CachedRouteLinesTable,
              CachedRouteLine
            >,
          ),
          CachedRouteLine,
          PrefetchHooks Function()
        > {
  $$CachedRouteLinesTableTableManager(
    _$AppDatabase db,
    $CachedRouteLinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedRouteLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedRouteLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedRouteLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> routeId = const Value.absent(),
                Value<int> driverId = const Value.absent(),
                Value<int> partnerId = const Value.absent(),
                Value<String> partnerName = const Value.absent(),
                Value<String?> street = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> obra = const Value.absent(),
                Value<String?> priority = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> scheduledTime = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<String?> pickupTime = const Value.absent(),
                Value<String?> endTime = const Value.absent(),
                Value<String?> orderType = const Value.absent(),
                Value<String?> orderName = const Value.absent(),
                Value<String?> incompleteReason = const Value.absent(),
                Value<String?> incompleteNotes = const Value.absent(),
                Value<String> cachedAt = const Value.absent(),
              }) => CachedRouteLinesCompanion(
                id: id,
                routeId: routeId,
                driverId: driverId,
                partnerId: partnerId,
                partnerName: partnerName,
                street: street,
                city: city,
                latitude: latitude,
                longitude: longitude,
                sequence: sequence,
                notes: notes,
                obra: obra,
                priority: priority,
                state: state,
                scheduledTime: scheduledTime,
                startTime: startTime,
                pickupTime: pickupTime,
                endTime: endTime,
                orderType: orderType,
                orderName: orderName,
                incompleteReason: incompleteReason,
                incompleteNotes: incompleteNotes,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int routeId,
                required int driverId,
                required int partnerId,
                Value<String> partnerName = const Value.absent(),
                Value<String?> street = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> obra = const Value.absent(),
                Value<String?> priority = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> scheduledTime = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<String?> pickupTime = const Value.absent(),
                Value<String?> endTime = const Value.absent(),
                Value<String?> orderType = const Value.absent(),
                Value<String?> orderName = const Value.absent(),
                Value<String?> incompleteReason = const Value.absent(),
                Value<String?> incompleteNotes = const Value.absent(),
                required String cachedAt,
              }) => CachedRouteLinesCompanion.insert(
                id: id,
                routeId: routeId,
                driverId: driverId,
                partnerId: partnerId,
                partnerName: partnerName,
                street: street,
                city: city,
                latitude: latitude,
                longitude: longitude,
                sequence: sequence,
                notes: notes,
                obra: obra,
                priority: priority,
                state: state,
                scheduledTime: scheduledTime,
                startTime: startTime,
                pickupTime: pickupTime,
                endTime: endTime,
                orderType: orderType,
                orderName: orderName,
                incompleteReason: incompleteReason,
                incompleteNotes: incompleteNotes,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedRouteLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedRouteLinesTable,
      CachedRouteLine,
      $$CachedRouteLinesTableFilterComposer,
      $$CachedRouteLinesTableOrderingComposer,
      $$CachedRouteLinesTableAnnotationComposer,
      $$CachedRouteLinesTableCreateCompanionBuilder,
      $$CachedRouteLinesTableUpdateCompanionBuilder,
      (
        CachedRouteLine,
        BaseReferences<_$AppDatabase, $CachedRouteLinesTable, CachedRouteLine>,
      ),
      CachedRouteLine,
      PrefetchHooks Function()
    >;
typedef $$CachedOrderLinesTableCreateCompanionBuilder =
    CachedOrderLinesCompanion Function({
      Value<int> id,
      required int lineId,
      Value<String> productName,
      Value<double> quantity,
      Value<String> uom,
      Value<double> priceUnit,
    });
typedef $$CachedOrderLinesTableUpdateCompanionBuilder =
    CachedOrderLinesCompanion Function({
      Value<int> id,
      Value<int> lineId,
      Value<String> productName,
      Value<double> quantity,
      Value<String> uom,
      Value<double> priceUnit,
    });

class $$CachedOrderLinesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedOrderLinesTable> {
  $$CachedOrderLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineId => $composableBuilder(
    column: $table.lineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uom => $composableBuilder(
    column: $table.uom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get priceUnit => $composableBuilder(
    column: $table.priceUnit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedOrderLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedOrderLinesTable> {
  $$CachedOrderLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineId => $composableBuilder(
    column: $table.lineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uom => $composableBuilder(
    column: $table.uom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get priceUnit => $composableBuilder(
    column: $table.priceUnit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedOrderLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedOrderLinesTable> {
  $$CachedOrderLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lineId =>
      $composableBuilder(column: $table.lineId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get uom =>
      $composableBuilder(column: $table.uom, builder: (column) => column);

  GeneratedColumn<double> get priceUnit =>
      $composableBuilder(column: $table.priceUnit, builder: (column) => column);
}

class $$CachedOrderLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedOrderLinesTable,
          CachedOrderLine,
          $$CachedOrderLinesTableFilterComposer,
          $$CachedOrderLinesTableOrderingComposer,
          $$CachedOrderLinesTableAnnotationComposer,
          $$CachedOrderLinesTableCreateCompanionBuilder,
          $$CachedOrderLinesTableUpdateCompanionBuilder,
          (
            CachedOrderLine,
            BaseReferences<
              _$AppDatabase,
              $CachedOrderLinesTable,
              CachedOrderLine
            >,
          ),
          CachedOrderLine,
          PrefetchHooks Function()
        > {
  $$CachedOrderLinesTableTableManager(
    _$AppDatabase db,
    $CachedOrderLinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedOrderLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedOrderLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedOrderLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> lineId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> uom = const Value.absent(),
                Value<double> priceUnit = const Value.absent(),
              }) => CachedOrderLinesCompanion(
                id: id,
                lineId: lineId,
                productName: productName,
                quantity: quantity,
                uom: uom,
                priceUnit: priceUnit,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int lineId,
                Value<String> productName = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> uom = const Value.absent(),
                Value<double> priceUnit = const Value.absent(),
              }) => CachedOrderLinesCompanion.insert(
                id: id,
                lineId: lineId,
                productName: productName,
                quantity: quantity,
                uom: uom,
                priceUnit: priceUnit,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedOrderLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedOrderLinesTable,
      CachedOrderLine,
      $$CachedOrderLinesTableFilterComposer,
      $$CachedOrderLinesTableOrderingComposer,
      $$CachedOrderLinesTableAnnotationComposer,
      $$CachedOrderLinesTableCreateCompanionBuilder,
      $$CachedOrderLinesTableUpdateCompanionBuilder,
      (
        CachedOrderLine,
        BaseReferences<_$AppDatabase, $CachedOrderLinesTable, CachedOrderLine>,
      ),
      CachedOrderLine,
      PrefetchHooks Function()
    >;
typedef $$CachedAttachmentsTableCreateCompanionBuilder =
    CachedAttachmentsCompanion Function({
      Value<int> id,
      required int lineId,
      Value<String> name,
      Value<String?> filename,
      Value<String?> mimetype,
      Value<int?> fileSize,
      Value<String?> createDate,
      Value<String?> downloadUrl,
    });
typedef $$CachedAttachmentsTableUpdateCompanionBuilder =
    CachedAttachmentsCompanion Function({
      Value<int> id,
      Value<int> lineId,
      Value<String> name,
      Value<String?> filename,
      Value<String?> mimetype,
      Value<int?> fileSize,
      Value<String?> createDate,
      Value<String?> downloadUrl,
    });

class $$CachedAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedAttachmentsTable> {
  $$CachedAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineId => $composableBuilder(
    column: $table.lineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimetype => $composableBuilder(
    column: $table.mimetype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createDate => $composableBuilder(
    column: $table.createDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadUrl => $composableBuilder(
    column: $table.downloadUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedAttachmentsTable> {
  $$CachedAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineId => $composableBuilder(
    column: $table.lineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimetype => $composableBuilder(
    column: $table.mimetype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createDate => $composableBuilder(
    column: $table.createDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadUrl => $composableBuilder(
    column: $table.downloadUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedAttachmentsTable> {
  $$CachedAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lineId =>
      $composableBuilder(column: $table.lineId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get mimetype =>
      $composableBuilder(column: $table.mimetype, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get createDate => $composableBuilder(
    column: $table.createDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get downloadUrl => $composableBuilder(
    column: $table.downloadUrl,
    builder: (column) => column,
  );
}

class $$CachedAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedAttachmentsTable,
          CachedAttachment,
          $$CachedAttachmentsTableFilterComposer,
          $$CachedAttachmentsTableOrderingComposer,
          $$CachedAttachmentsTableAnnotationComposer,
          $$CachedAttachmentsTableCreateCompanionBuilder,
          $$CachedAttachmentsTableUpdateCompanionBuilder,
          (
            CachedAttachment,
            BaseReferences<
              _$AppDatabase,
              $CachedAttachmentsTable,
              CachedAttachment
            >,
          ),
          CachedAttachment,
          PrefetchHooks Function()
        > {
  $$CachedAttachmentsTableTableManager(
    _$AppDatabase db,
    $CachedAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> lineId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> filename = const Value.absent(),
                Value<String?> mimetype = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<String?> createDate = const Value.absent(),
                Value<String?> downloadUrl = const Value.absent(),
              }) => CachedAttachmentsCompanion(
                id: id,
                lineId: lineId,
                name: name,
                filename: filename,
                mimetype: mimetype,
                fileSize: fileSize,
                createDate: createDate,
                downloadUrl: downloadUrl,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int lineId,
                Value<String> name = const Value.absent(),
                Value<String?> filename = const Value.absent(),
                Value<String?> mimetype = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<String?> createDate = const Value.absent(),
                Value<String?> downloadUrl = const Value.absent(),
              }) => CachedAttachmentsCompanion.insert(
                id: id,
                lineId: lineId,
                name: name,
                filename: filename,
                mimetype: mimetype,
                fileSize: fileSize,
                createDate: createDate,
                downloadUrl: downloadUrl,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedAttachmentsTable,
      CachedAttachment,
      $$CachedAttachmentsTableFilterComposer,
      $$CachedAttachmentsTableOrderingComposer,
      $$CachedAttachmentsTableAnnotationComposer,
      $$CachedAttachmentsTableCreateCompanionBuilder,
      $$CachedAttachmentsTableUpdateCompanionBuilder,
      (
        CachedAttachment,
        BaseReferences<
          _$AppDatabase,
          $CachedAttachmentsTable,
          CachedAttachment
        >,
      ),
      CachedAttachment,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedRoutesTableTableManager get cachedRoutes =>
      $$CachedRoutesTableTableManager(_db, _db.cachedRoutes);
  $$CachedRouteLinesTableTableManager get cachedRouteLines =>
      $$CachedRouteLinesTableTableManager(_db, _db.cachedRouteLines);
  $$CachedOrderLinesTableTableManager get cachedOrderLines =>
      $$CachedOrderLinesTableTableManager(_db, _db.cachedOrderLines);
  $$CachedAttachmentsTableTableManager get cachedAttachments =>
      $$CachedAttachmentsTableTableManager(_db, _db.cachedAttachments);
}
