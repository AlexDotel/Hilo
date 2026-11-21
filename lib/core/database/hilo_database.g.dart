// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hilo_database.dart';

// ignore_for_file: type=lint
class $HabitsTableTable extends HabitsTable
    with TableInfo<$HabitsTableTable, HabitsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('check'),
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#158052'),
  );
  static const VerificationMeta _habitTypeMeta = const VerificationMeta(
    'habitType',
  );
  @override
  late final GeneratedColumn<String> habitType = GeneratedColumn<String>(
    'habit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('binary'),
  );
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  @override
  late final GeneratedColumn<double> targetValue = GeneratedColumn<double>(
    'target_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduleTypeMeta = const VerificationMeta(
    'scheduleType',
  );
  @override
  late final GeneratedColumn<String> scheduleType = GeneratedColumn<String>(
    'schedule_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('daily'),
  );
  static const VerificationMeta _scheduleConfigJsonMeta =
      const VerificationMeta('scheduleConfigJson');
  @override
  late final GeneratedColumn<String> scheduleConfigJson =
      GeneratedColumn<String>(
        'schedule_config_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _allowShieldsMeta = const VerificationMeta(
    'allowShields',
  );
  @override
  late final GeneratedColumn<bool> allowShields = GeneratedColumn<bool>(
    'allow_shields',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allow_shields" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<String> reminderTime = GeneratedColumn<String>(
    'reminder_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtDateMeta = const VerificationMeta(
    'createdAtDate',
  );
  @override
  late final GeneratedColumn<String> createdAtDate = GeneratedColumn<String>(
    'created_at_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconKey,
    colorHex,
    habitType,
    targetValue,
    unit,
    scheduleType,
    scheduleConfigJson,
    allowShields,
    reminderTime,
    sortOrder,
    isArchived,
    createdAtDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('habit_type')) {
      context.handle(
        _habitTypeMeta,
        habitType.isAcceptableOrUnknown(data['habit_type']!, _habitTypeMeta),
      );
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('schedule_type')) {
      context.handle(
        _scheduleTypeMeta,
        scheduleType.isAcceptableOrUnknown(
          data['schedule_type']!,
          _scheduleTypeMeta,
        ),
      );
    }
    if (data.containsKey('schedule_config_json')) {
      context.handle(
        _scheduleConfigJsonMeta,
        scheduleConfigJson.isAcceptableOrUnknown(
          data['schedule_config_json']!,
          _scheduleConfigJsonMeta,
        ),
      );
    }
    if (data.containsKey('allow_shields')) {
      context.handle(
        _allowShieldsMeta,
        allowShields.isAcceptableOrUnknown(
          data['allow_shields']!,
          _allowShieldsMeta,
        ),
      );
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at_date')) {
      context.handle(
        _createdAtDateMeta,
        createdAtDate.isAcceptableOrUnknown(
          data['created_at_date']!,
          _createdAtDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      habitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_type'],
      )!,
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_value'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      scheduleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_type'],
      )!,
      scheduleConfigJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_config_json'],
      )!,
      allowShields: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_shields'],
      )!,
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_time'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAtDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_date'],
      )!,
    );
  }

  @override
  $HabitsTableTable createAlias(String alias) {
    return $HabitsTableTable(attachedDatabase, alias);
  }
}

class HabitsTableData extends DataClass implements Insertable<HabitsTableData> {
  final String id;
  final String name;
  final String iconKey;
  final String colorHex;
  final String habitType;
  final double targetValue;
  final String? unit;
  final String scheduleType;
  final String scheduleConfigJson;
  final bool allowShields;
  final String? reminderTime;
  final int sortOrder;
  final bool isArchived;
  final String createdAtDate;
  const HabitsTableData({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorHex,
    required this.habitType,
    required this.targetValue,
    this.unit,
    required this.scheduleType,
    required this.scheduleConfigJson,
    required this.allowShields,
    this.reminderTime,
    required this.sortOrder,
    required this.isArchived,
    required this.createdAtDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_key'] = Variable<String>(iconKey);
    map['color_hex'] = Variable<String>(colorHex);
    map['habit_type'] = Variable<String>(habitType);
    map['target_value'] = Variable<double>(targetValue);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['schedule_type'] = Variable<String>(scheduleType);
    map['schedule_config_json'] = Variable<String>(scheduleConfigJson);
    map['allow_shields'] = Variable<bool>(allowShields);
    if (!nullToAbsent || reminderTime != null) {
      map['reminder_time'] = Variable<String>(reminderTime);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at_date'] = Variable<String>(createdAtDate);
    return map;
  }

  HabitsTableCompanion toCompanion(bool nullToAbsent) {
    return HabitsTableCompanion(
      id: Value(id),
      name: Value(name),
      iconKey: Value(iconKey),
      colorHex: Value(colorHex),
      habitType: Value(habitType),
      targetValue: Value(targetValue),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      scheduleType: Value(scheduleType),
      scheduleConfigJson: Value(scheduleConfigJson),
      allowShields: Value(allowShields),
      reminderTime: reminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTime),
      sortOrder: Value(sortOrder),
      isArchived: Value(isArchived),
      createdAtDate: Value(createdAtDate),
    );
  }

  factory HabitsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      habitType: serializer.fromJson<String>(json['habitType']),
      targetValue: serializer.fromJson<double>(json['targetValue']),
      unit: serializer.fromJson<String?>(json['unit']),
      scheduleType: serializer.fromJson<String>(json['scheduleType']),
      scheduleConfigJson: serializer.fromJson<String>(
        json['scheduleConfigJson'],
      ),
      allowShields: serializer.fromJson<bool>(json['allowShields']),
      reminderTime: serializer.fromJson<String?>(json['reminderTime']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAtDate: serializer.fromJson<String>(json['createdAtDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconKey': serializer.toJson<String>(iconKey),
      'colorHex': serializer.toJson<String>(colorHex),
      'habitType': serializer.toJson<String>(habitType),
      'targetValue': serializer.toJson<double>(targetValue),
      'unit': serializer.toJson<String?>(unit),
      'scheduleType': serializer.toJson<String>(scheduleType),
      'scheduleConfigJson': serializer.toJson<String>(scheduleConfigJson),
      'allowShields': serializer.toJson<bool>(allowShields),
      'reminderTime': serializer.toJson<String?>(reminderTime),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAtDate': serializer.toJson<String>(createdAtDate),
    };
  }

  HabitsTableData copyWith({
    String? id,
    String? name,
    String? iconKey,
    String? colorHex,
    String? habitType,
    double? targetValue,
    Value<String?> unit = const Value.absent(),
    String? scheduleType,
    String? scheduleConfigJson,
    bool? allowShields,
    Value<String?> reminderTime = const Value.absent(),
    int? sortOrder,
    bool? isArchived,
    String? createdAtDate,
  }) => HabitsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    iconKey: iconKey ?? this.iconKey,
    colorHex: colorHex ?? this.colorHex,
    habitType: habitType ?? this.habitType,
    targetValue: targetValue ?? this.targetValue,
    unit: unit.present ? unit.value : this.unit,
    scheduleType: scheduleType ?? this.scheduleType,
    scheduleConfigJson: scheduleConfigJson ?? this.scheduleConfigJson,
    allowShields: allowShields ?? this.allowShields,
    reminderTime: reminderTime.present ? reminderTime.value : this.reminderTime,
    sortOrder: sortOrder ?? this.sortOrder,
    isArchived: isArchived ?? this.isArchived,
    createdAtDate: createdAtDate ?? this.createdAtDate,
  );
  HabitsTableData copyWithCompanion(HabitsTableCompanion data) {
    return HabitsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      habitType: data.habitType.present ? data.habitType.value : this.habitType,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
      unit: data.unit.present ? data.unit.value : this.unit,
      scheduleType: data.scheduleType.present
          ? data.scheduleType.value
          : this.scheduleType,
      scheduleConfigJson: data.scheduleConfigJson.present
          ? data.scheduleConfigJson.value
          : this.scheduleConfigJson,
      allowShields: data.allowShields.present
          ? data.allowShields.value
          : this.allowShields,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAtDate: data.createdAtDate.present
          ? data.createdAtDate.value
          : this.createdAtDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorHex: $colorHex, ')
          ..write('habitType: $habitType, ')
          ..write('targetValue: $targetValue, ')
          ..write('unit: $unit, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('scheduleConfigJson: $scheduleConfigJson, ')
          ..write('allowShields: $allowShields, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAtDate: $createdAtDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    iconKey,
    colorHex,
    habitType,
    targetValue,
    unit,
    scheduleType,
    scheduleConfigJson,
    allowShields,
    reminderTime,
    sortOrder,
    isArchived,
    createdAtDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconKey == this.iconKey &&
          other.colorHex == this.colorHex &&
          other.habitType == this.habitType &&
          other.targetValue == this.targetValue &&
          other.unit == this.unit &&
          other.scheduleType == this.scheduleType &&
          other.scheduleConfigJson == this.scheduleConfigJson &&
          other.allowShields == this.allowShields &&
          other.reminderTime == this.reminderTime &&
          other.sortOrder == this.sortOrder &&
          other.isArchived == this.isArchived &&
          other.createdAtDate == this.createdAtDate);
}

class HabitsTableCompanion extends UpdateCompanion<HabitsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconKey;
  final Value<String> colorHex;
  final Value<String> habitType;
  final Value<double> targetValue;
  final Value<String?> unit;
  final Value<String> scheduleType;
  final Value<String> scheduleConfigJson;
  final Value<bool> allowShields;
  final Value<String?> reminderTime;
  final Value<int> sortOrder;
  final Value<bool> isArchived;
  final Value<String> createdAtDate;
  final Value<int> rowid;
  const HabitsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.habitType = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.scheduleConfigJson = const Value.absent(),
    this.allowShields = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAtDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsTableCompanion.insert({
    required String id,
    required String name,
    this.iconKey = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.habitType = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.unit = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.scheduleConfigJson = const Value.absent(),
    this.allowShields = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    required String createdAtDate,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAtDate = Value(createdAtDate);
  static Insertable<HabitsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconKey,
    Expression<String>? colorHex,
    Expression<String>? habitType,
    Expression<double>? targetValue,
    Expression<String>? unit,
    Expression<String>? scheduleType,
    Expression<String>? scheduleConfigJson,
    Expression<bool>? allowShields,
    Expression<String>? reminderTime,
    Expression<int>? sortOrder,
    Expression<bool>? isArchived,
    Expression<String>? createdAtDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconKey != null) 'icon_key': iconKey,
      if (colorHex != null) 'color_hex': colorHex,
      if (habitType != null) 'habit_type': habitType,
      if (targetValue != null) 'target_value': targetValue,
      if (unit != null) 'unit': unit,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (scheduleConfigJson != null)
        'schedule_config_json': scheduleConfigJson,
      if (allowShields != null) 'allow_shields': allowShields,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAtDate != null) 'created_at_date': createdAtDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? iconKey,
    Value<String>? colorHex,
    Value<String>? habitType,
    Value<double>? targetValue,
    Value<String?>? unit,
    Value<String>? scheduleType,
    Value<String>? scheduleConfigJson,
    Value<bool>? allowShields,
    Value<String?>? reminderTime,
    Value<int>? sortOrder,
    Value<bool>? isArchived,
    Value<String>? createdAtDate,
    Value<int>? rowid,
  }) {
    return HabitsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorHex: colorHex ?? this.colorHex,
      habitType: habitType ?? this.habitType,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      scheduleType: scheduleType ?? this.scheduleType,
      scheduleConfigJson: scheduleConfigJson ?? this.scheduleConfigJson,
      allowShields: allowShields ?? this.allowShields,
      reminderTime: reminderTime ?? this.reminderTime,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      createdAtDate: createdAtDate ?? this.createdAtDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (habitType.present) {
      map['habit_type'] = Variable<String>(habitType.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<double>(targetValue.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (scheduleType.present) {
      map['schedule_type'] = Variable<String>(scheduleType.value);
    }
    if (scheduleConfigJson.present) {
      map['schedule_config_json'] = Variable<String>(scheduleConfigJson.value);
    }
    if (allowShields.present) {
      map['allow_shields'] = Variable<bool>(allowShields.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<String>(reminderTime.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAtDate.present) {
      map['created_at_date'] = Variable<String>(createdAtDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorHex: $colorHex, ')
          ..write('habitType: $habitType, ')
          ..write('targetValue: $targetValue, ')
          ..write('unit: $unit, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('scheduleConfigJson: $scheduleConfigJson, ')
          ..write('allowShields: $allowShields, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAtDate: $createdAtDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitLogsTableTable extends HabitLogsTable
    with TableInfo<$HabitLogsTableTable, HabitLogsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitLogsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtEpochMsMeta = const VerificationMeta(
    'updatedAtEpochMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtEpochMs = GeneratedColumn<int>(
    'updated_at_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    localDate,
    status,
    value,
    note,
    updatedAtEpochMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitLogsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('updated_at_epoch_ms')) {
      context.handle(
        _updatedAtEpochMsMeta,
        updatedAtEpochMs.isAcceptableOrUnknown(
          data['updated_at_epoch_ms']!,
          _updatedAtEpochMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtEpochMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {habitId, localDate},
  ];
  @override
  HabitLogsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitLogsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      updatedAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_epoch_ms'],
      )!,
    );
  }

  @override
  $HabitLogsTableTable createAlias(String alias) {
    return $HabitLogsTableTable(attachedDatabase, alias);
  }
}

class HabitLogsTableData extends DataClass
    implements Insertable<HabitLogsTableData> {
  final String id;
  final String habitId;
  final String localDate;
  final String status;
  final double value;
  final String? note;
  final int updatedAtEpochMs;
  const HabitLogsTableData({
    required this.id,
    required this.habitId,
    required this.localDate,
    required this.status,
    required this.value,
    this.note,
    required this.updatedAtEpochMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['local_date'] = Variable<String>(localDate);
    map['status'] = Variable<String>(status);
    map['value'] = Variable<double>(value);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['updated_at_epoch_ms'] = Variable<int>(updatedAtEpochMs);
    return map;
  }

  HabitLogsTableCompanion toCompanion(bool nullToAbsent) {
    return HabitLogsTableCompanion(
      id: Value(id),
      habitId: Value(habitId),
      localDate: Value(localDate),
      status: Value(status),
      value: Value(value),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      updatedAtEpochMs: Value(updatedAtEpochMs),
    );
  }

  factory HabitLogsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitLogsTableData(
      id: serializer.fromJson<String>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      localDate: serializer.fromJson<String>(json['localDate']),
      status: serializer.fromJson<String>(json['status']),
      value: serializer.fromJson<double>(json['value']),
      note: serializer.fromJson<String?>(json['note']),
      updatedAtEpochMs: serializer.fromJson<int>(json['updatedAtEpochMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'habitId': serializer.toJson<String>(habitId),
      'localDate': serializer.toJson<String>(localDate),
      'status': serializer.toJson<String>(status),
      'value': serializer.toJson<double>(value),
      'note': serializer.toJson<String?>(note),
      'updatedAtEpochMs': serializer.toJson<int>(updatedAtEpochMs),
    };
  }

  HabitLogsTableData copyWith({
    String? id,
    String? habitId,
    String? localDate,
    String? status,
    double? value,
    Value<String?> note = const Value.absent(),
    int? updatedAtEpochMs,
  }) => HabitLogsTableData(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    localDate: localDate ?? this.localDate,
    status: status ?? this.status,
    value: value ?? this.value,
    note: note.present ? note.value : this.note,
    updatedAtEpochMs: updatedAtEpochMs ?? this.updatedAtEpochMs,
  );
  HabitLogsTableData copyWithCompanion(HabitLogsTableCompanion data) {
    return HabitLogsTableData(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      status: data.status.present ? data.status.value : this.status,
      value: data.value.present ? data.value.value : this.value,
      note: data.note.present ? data.note.value : this.note,
      updatedAtEpochMs: data.updatedAtEpochMs.present
          ? data.updatedAtEpochMs.value
          : this.updatedAtEpochMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitLogsTableData(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('localDate: $localDate, ')
          ..write('status: $status, ')
          ..write('value: $value, ')
          ..write('note: $note, ')
          ..write('updatedAtEpochMs: $updatedAtEpochMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    habitId,
    localDate,
    status,
    value,
    note,
    updatedAtEpochMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitLogsTableData &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.localDate == this.localDate &&
          other.status == this.status &&
          other.value == this.value &&
          other.note == this.note &&
          other.updatedAtEpochMs == this.updatedAtEpochMs);
}

class HabitLogsTableCompanion extends UpdateCompanion<HabitLogsTableData> {
  final Value<String> id;
  final Value<String> habitId;
  final Value<String> localDate;
  final Value<String> status;
  final Value<double> value;
  final Value<String?> note;
  final Value<int> updatedAtEpochMs;
  final Value<int> rowid;
  const HabitLogsTableCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.localDate = const Value.absent(),
    this.status = const Value.absent(),
    this.value = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAtEpochMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitLogsTableCompanion.insert({
    required String id,
    required String habitId,
    required String localDate,
    required String status,
    this.value = const Value.absent(),
    this.note = const Value.absent(),
    required int updatedAtEpochMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       habitId = Value(habitId),
       localDate = Value(localDate),
       status = Value(status),
       updatedAtEpochMs = Value(updatedAtEpochMs);
  static Insertable<HabitLogsTableData> custom({
    Expression<String>? id,
    Expression<String>? habitId,
    Expression<String>? localDate,
    Expression<String>? status,
    Expression<double>? value,
    Expression<String>? note,
    Expression<int>? updatedAtEpochMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (localDate != null) 'local_date': localDate,
      if (status != null) 'status': status,
      if (value != null) 'value': value,
      if (note != null) 'note': note,
      if (updatedAtEpochMs != null) 'updated_at_epoch_ms': updatedAtEpochMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitLogsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? habitId,
    Value<String>? localDate,
    Value<String>? status,
    Value<double>? value,
    Value<String?>? note,
    Value<int>? updatedAtEpochMs,
    Value<int>? rowid,
  }) {
    return HabitLogsTableCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      localDate: localDate ?? this.localDate,
      status: status ?? this.status,
      value: value ?? this.value,
      note: note ?? this.note,
      updatedAtEpochMs: updatedAtEpochMs ?? this.updatedAtEpochMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedAtEpochMs.present) {
      map['updated_at_epoch_ms'] = Variable<int>(updatedAtEpochMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitLogsTableCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('localDate: $localDate, ')
          ..write('status: $status, ')
          ..write('value: $value, ')
          ..write('note: $note, ')
          ..write('updatedAtEpochMs: $updatedAtEpochMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$HiloDatabase extends GeneratedDatabase {
  _$HiloDatabase(QueryExecutor e) : super(e);
  $HiloDatabaseManager get managers => $HiloDatabaseManager(this);
  late final $HabitsTableTable habitsTable = $HabitsTableTable(this);
  late final $HabitLogsTableTable habitLogsTable = $HabitLogsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    habitsTable,
    habitLogsTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('habit_logs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$HabitsTableTableCreateCompanionBuilder =
    HabitsTableCompanion Function({
      required String id,
      required String name,
      Value<String> iconKey,
      Value<String> colorHex,
      Value<String> habitType,
      Value<double> targetValue,
      Value<String?> unit,
      Value<String> scheduleType,
      Value<String> scheduleConfigJson,
      Value<bool> allowShields,
      Value<String?> reminderTime,
      Value<int> sortOrder,
      Value<bool> isArchived,
      required String createdAtDate,
      Value<int> rowid,
    });
typedef $$HabitsTableTableUpdateCompanionBuilder =
    HabitsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> iconKey,
      Value<String> colorHex,
      Value<String> habitType,
      Value<double> targetValue,
      Value<String?> unit,
      Value<String> scheduleType,
      Value<String> scheduleConfigJson,
      Value<bool> allowShields,
      Value<String?> reminderTime,
      Value<int> sortOrder,
      Value<bool> isArchived,
      Value<String> createdAtDate,
      Value<int> rowid,
    });

final class $$HabitsTableTableReferences
    extends BaseReferences<_$HiloDatabase, $HabitsTableTable, HabitsTableData> {
  $$HabitsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HabitLogsTableTable, List<HabitLogsTableData>>
  _habitLogsTableRefsTable(_$HiloDatabase db) => MultiTypedResultKey.fromTable(
    db.habitLogsTable,
    aliasName: 'habits__id__habit_logs__habit_id',
  );

  $$HabitLogsTableTableProcessedTableManager get habitLogsTableRefs {
    final manager = $$HabitLogsTableTableTableManager(
      $_db,
      $_db.habitLogsTable,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitLogsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HabitsTableTableFilterComposer
    extends Composer<_$HiloDatabase, $HabitsTableTable> {
  $$HabitsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitType => $composableBuilder(
    column: $table.habitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleConfigJson => $composableBuilder(
    column: $table.scheduleConfigJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowShields => $composableBuilder(
    column: $table.allowShields,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAtDate => $composableBuilder(
    column: $table.createdAtDate,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> habitLogsTableRefs(
    Expression<bool> Function($$HabitLogsTableTableFilterComposer f) f,
  ) {
    final $$HabitLogsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogsTable,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableTableFilterComposer(
            $db: $db,
            $table: $db.habitLogsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableTableOrderingComposer
    extends Composer<_$HiloDatabase, $HabitsTableTable> {
  $$HabitsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitType => $composableBuilder(
    column: $table.habitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleConfigJson => $composableBuilder(
    column: $table.scheduleConfigJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowShields => $composableBuilder(
    column: $table.allowShields,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAtDate => $composableBuilder(
    column: $table.createdAtDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableTableAnnotationComposer
    extends Composer<_$HiloDatabase, $HabitsTableTable> {
  $$HabitsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<String> get habitType =>
      $composableBuilder(column: $table.habitType, builder: (column) => column);

  GeneratedColumn<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleConfigJson => $composableBuilder(
    column: $table.scheduleConfigJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowShields => $composableBuilder(
    column: $table.allowShields,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAtDate => $composableBuilder(
    column: $table.createdAtDate,
    builder: (column) => column,
  );

  Expression<T> habitLogsTableRefs<T extends Object>(
    Expression<T> Function($$HabitLogsTableTableAnnotationComposer a) f,
  ) {
    final $$HabitLogsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogsTable,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.habitLogsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableTableTableManager
    extends
        RootTableManager<
          _$HiloDatabase,
          $HabitsTableTable,
          HabitsTableData,
          $$HabitsTableTableFilterComposer,
          $$HabitsTableTableOrderingComposer,
          $$HabitsTableTableAnnotationComposer,
          $$HabitsTableTableCreateCompanionBuilder,
          $$HabitsTableTableUpdateCompanionBuilder,
          (HabitsTableData, $$HabitsTableTableReferences),
          HabitsTableData,
          PrefetchHooks Function({bool habitLogsTableRefs})
        > {
  $$HabitsTableTableTableManager(_$HiloDatabase db, $HabitsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<String> habitType = const Value.absent(),
                Value<double> targetValue = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String> scheduleType = const Value.absent(),
                Value<String> scheduleConfigJson = const Value.absent(),
                Value<bool> allowShields = const Value.absent(),
                Value<String?> reminderTime = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String> createdAtDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsTableCompanion(
                id: id,
                name: name,
                iconKey: iconKey,
                colorHex: colorHex,
                habitType: habitType,
                targetValue: targetValue,
                unit: unit,
                scheduleType: scheduleType,
                scheduleConfigJson: scheduleConfigJson,
                allowShields: allowShields,
                reminderTime: reminderTime,
                sortOrder: sortOrder,
                isArchived: isArchived,
                createdAtDate: createdAtDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> iconKey = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<String> habitType = const Value.absent(),
                Value<double> targetValue = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String> scheduleType = const Value.absent(),
                Value<String> scheduleConfigJson = const Value.absent(),
                Value<bool> allowShields = const Value.absent(),
                Value<String?> reminderTime = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required String createdAtDate,
                Value<int> rowid = const Value.absent(),
              }) => HabitsTableCompanion.insert(
                id: id,
                name: name,
                iconKey: iconKey,
                colorHex: colorHex,
                habitType: habitType,
                targetValue: targetValue,
                unit: unit,
                scheduleType: scheduleType,
                scheduleConfigJson: scheduleConfigJson,
                allowShields: allowShields,
                reminderTime: reminderTime,
                sortOrder: sortOrder,
                isArchived: isArchived,
                createdAtDate: createdAtDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitsTableTable, HabitsTableData>(table),
                  $$HabitsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitLogsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (habitLogsTableRefs) db.habitLogsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (habitLogsTableRefs)
                    await $_getPrefetchedDataByColumns<
                      HabitsTableData,
                      $HabitsTableTable,
                      HabitLogsTableData,
                      $HabitLogsTableTable
                    >(
                      currentTable: table,
                      referencedTable: $$HabitsTableTableReferences
                          ._habitLogsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$HabitsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).habitLogsTableRefs,
                      currentColumn: 'id',
                      referencedColumn: 'habit_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HabitsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$HiloDatabase,
      $HabitsTableTable,
      HabitsTableData,
      $$HabitsTableTableFilterComposer,
      $$HabitsTableTableOrderingComposer,
      $$HabitsTableTableAnnotationComposer,
      $$HabitsTableTableCreateCompanionBuilder,
      $$HabitsTableTableUpdateCompanionBuilder,
      (HabitsTableData, $$HabitsTableTableReferences),
      HabitsTableData,
      PrefetchHooks Function({bool habitLogsTableRefs})
    >;
typedef $$HabitLogsTableTableCreateCompanionBuilder =
    HabitLogsTableCompanion Function({
      required String id,
      required String habitId,
      required String localDate,
      required String status,
      Value<double> value,
      Value<String?> note,
      required int updatedAtEpochMs,
      Value<int> rowid,
    });
typedef $$HabitLogsTableTableUpdateCompanionBuilder =
    HabitLogsTableCompanion Function({
      Value<String> id,
      Value<String> habitId,
      Value<String> localDate,
      Value<String> status,
      Value<double> value,
      Value<String?> note,
      Value<int> updatedAtEpochMs,
      Value<int> rowid,
    });

final class $$HabitLogsTableTableReferences
    extends
        BaseReferences<
          _$HiloDatabase,
          $HabitLogsTableTable,
          HabitLogsTableData
        > {
  $$HabitLogsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HabitsTableTable _habitIdTable(_$HiloDatabase db) =>
      db.habitsTable.createAlias('habit_logs__habit_id__habits__id');

  $$HabitsTableTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<String>('habit_id')!;

    final manager = $$HabitsTableTableTableManager(
      $_db,
      $_db.habitsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitLogsTableTableFilterComposer
    extends Composer<_$HiloDatabase, $HabitLogsTableTable> {
  $$HabitLogsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtEpochMs => $composableBuilder(
    column: $table.updatedAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableTableFilterComposer get habitId {
    final $$HabitsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habitsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableTableFilterComposer(
            $db: $db,
            $table: $db.habitsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableTableOrderingComposer
    extends Composer<_$HiloDatabase, $HabitLogsTableTable> {
  $$HabitLogsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtEpochMs => $composableBuilder(
    column: $table.updatedAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableTableOrderingComposer get habitId {
    final $$HabitsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habitsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableTableOrderingComposer(
            $db: $db,
            $table: $db.habitsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableTableAnnotationComposer
    extends Composer<_$HiloDatabase, $HabitLogsTableTable> {
  $$HabitLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get updatedAtEpochMs => $composableBuilder(
    column: $table.updatedAtEpochMs,
    builder: (column) => column,
  );

  $$HabitsTableTableAnnotationComposer get habitId {
    final $$HabitsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habitsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.habitsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableTableTableManager
    extends
        RootTableManager<
          _$HiloDatabase,
          $HabitLogsTableTable,
          HabitLogsTableData,
          $$HabitLogsTableTableFilterComposer,
          $$HabitLogsTableTableOrderingComposer,
          $$HabitLogsTableTableAnnotationComposer,
          $$HabitLogsTableTableCreateCompanionBuilder,
          $$HabitLogsTableTableUpdateCompanionBuilder,
          (HabitLogsTableData, $$HabitLogsTableTableReferences),
          HabitLogsTableData,
          PrefetchHooks Function({bool habitId})
        > {
  $$HabitLogsTableTableTableManager(
    _$HiloDatabase db,
    $HabitLogsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitLogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitLogsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitLogsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> updatedAtEpochMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitLogsTableCompanion(
                id: id,
                habitId: habitId,
                localDate: localDate,
                status: status,
                value: value,
                note: note,
                updatedAtEpochMs: updatedAtEpochMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String habitId,
                required String localDate,
                required String status,
                Value<double> value = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int updatedAtEpochMs,
                Value<int> rowid = const Value.absent(),
              }) => HabitLogsTableCompanion.insert(
                id: id,
                habitId: habitId,
                localDate: localDate,
                status: status,
                value: value,
                note: note,
                updatedAtEpochMs: updatedAtEpochMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitLogsTableTable, HabitLogsTableData>(table),
                  $$HabitLogsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.habitId,
                        referencedTable: $$HabitLogsTableTableReferences
                            ._habitIdTable(db),
                        referencedColumn: $$HabitLogsTableTableReferences
                            ._habitIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HabitLogsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$HiloDatabase,
      $HabitLogsTableTable,
      HabitLogsTableData,
      $$HabitLogsTableTableFilterComposer,
      $$HabitLogsTableTableOrderingComposer,
      $$HabitLogsTableTableAnnotationComposer,
      $$HabitLogsTableTableCreateCompanionBuilder,
      $$HabitLogsTableTableUpdateCompanionBuilder,
      (HabitLogsTableData, $$HabitLogsTableTableReferences),
      HabitLogsTableData,
      PrefetchHooks Function({bool habitId})
    >;

class $HiloDatabaseManager {
  final _$HiloDatabase _db;
  $HiloDatabaseManager(this._db);
  $$HabitsTableTableTableManager get habitsTable =>
      $$HabitsTableTableTableManager(_db, _db.habitsTable);
  $$HabitLogsTableTableTableManager get habitLogsTable =>
      $$HabitLogsTableTableTableManager(_db, _db.habitLogsTable);
}
