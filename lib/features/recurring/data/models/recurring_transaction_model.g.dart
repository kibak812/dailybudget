// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRecurringTransactionModelCollection on Isar {
  IsarCollection<RecurringTransactionModel> get recurringTransactionModels =>
      this.collection();
}

const RecurringTransactionModelSchema = CollectionSchema(
  name: r'RecurringTransactionModel',
  id: 6130514885703977993,
  properties: {
    r'amount': PropertySchema(id: 0, name: r'amount', type: IsarType.long),
    r'category': PropertySchema(
      id: 1,
      name: r'category',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dayOfMonth': PropertySchema(
      id: 3,
      name: r'dayOfMonth',
      type: IsarType.long,
    ),
    r'endMonth': PropertySchema(
      id: 4,
      name: r'endMonth',
      type: IsarType.string,
    ),
    r'endMonthNumber': PropertySchema(
      id: 5,
      name: r'endMonthNumber',
      type: IsarType.long,
    ),
    r'endYear': PropertySchema(id: 6, name: r'endYear', type: IsarType.long),
    r'isActive': PropertySchema(id: 7, name: r'isActive', type: IsarType.bool),
    r'memo': PropertySchema(id: 8, name: r'memo', type: IsarType.string),
    r'startMonth': PropertySchema(
      id: 9,
      name: r'startMonth',
      type: IsarType.string,
    ),
    r'startMonthNumber': PropertySchema(
      id: 10,
      name: r'startMonthNumber',
      type: IsarType.long,
    ),
    r'startYear': PropertySchema(
      id: 11,
      name: r'startYear',
      type: IsarType.long,
    ),
    r'type': PropertySchema(
      id: 12,
      name: r'type',
      type: IsarType.string,
      enumMap: _RecurringTransactionModeltypeEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 13,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _recurringTransactionModelEstimateSize,
  serialize: _recurringTransactionModelSerialize,
  deserialize: _recurringTransactionModelDeserialize,
  deserializeProp: _recurringTransactionModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _recurringTransactionModelGetId,
  getLinks: _recurringTransactionModelGetLinks,
  attach: _recurringTransactionModelAttach,
  version: '3.3.0',
);

int _recurringTransactionModelEstimateSize(
  RecurringTransactionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.category;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.endMonth;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.memo;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.startMonth.length * 3;
  bytesCount += 3 + object.type.name.length * 3;
  return bytesCount;
}

void _recurringTransactionModelSerialize(
  RecurringTransactionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.amount);
  writer.writeString(offsets[1], object.category);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeLong(offsets[3], object.dayOfMonth);
  writer.writeString(offsets[4], object.endMonth);
  writer.writeLong(offsets[5], object.endMonthNumber);
  writer.writeLong(offsets[6], object.endYear);
  writer.writeBool(offsets[7], object.isActive);
  writer.writeString(offsets[8], object.memo);
  writer.writeString(offsets[9], object.startMonth);
  writer.writeLong(offsets[10], object.startMonthNumber);
  writer.writeLong(offsets[11], object.startYear);
  writer.writeString(offsets[12], object.type.name);
  writer.writeDateTime(offsets[13], object.updatedAt);
}

RecurringTransactionModel _recurringTransactionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RecurringTransactionModel(
    amount: reader.readLong(offsets[0]),
    category: reader.readStringOrNull(offsets[1]),
    createdAt: reader.readDateTime(offsets[2]),
    dayOfMonth: reader.readLong(offsets[3]),
    endMonth: reader.readStringOrNull(offsets[4]),
    isActive: reader.readBool(offsets[7]),
    memo: reader.readStringOrNull(offsets[8]),
    startMonth: reader.readString(offsets[9]),
    type:
        _RecurringTransactionModeltypeValueEnumMap[reader.readStringOrNull(
          offsets[12],
        )] ??
        RecurringTransactionType.expense,
    updatedAt: reader.readDateTime(offsets[13]),
  );
  object.id = id;
  return object;
}

P _recurringTransactionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (_RecurringTransactionModeltypeValueEnumMap[reader
                  .readStringOrNull(offset)] ??
              RecurringTransactionType.expense)
          as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _RecurringTransactionModeltypeEnumValueMap = {
  r'expense': r'expense',
  r'income': r'income',
};
const _RecurringTransactionModeltypeValueEnumMap = {
  r'expense': RecurringTransactionType.expense,
  r'income': RecurringTransactionType.income,
};

Id _recurringTransactionModelGetId(RecurringTransactionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _recurringTransactionModelGetLinks(
  RecurringTransactionModel object,
) {
  return [];
}

void _recurringTransactionModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  RecurringTransactionModel object,
) {
  object.id = id;
}

extension RecurringTransactionModelQueryWhereSort
    on
        QueryBuilder<
          RecurringTransactionModel,
          RecurringTransactionModel,
          QWhere
        > {
  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterWhere
  >
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RecurringTransactionModelQueryWhere
    on
        QueryBuilder<
          RecurringTransactionModel,
          RecurringTransactionModel,
          QWhereClause
        > {
  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterWhereClause
  >
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterWhereClause
  >
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension RecurringTransactionModelQueryFilter
    on
        QueryBuilder<
          RecurringTransactionModel,
          RecurringTransactionModel,
          QFilterCondition
        > {
  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  amountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'amount', value: value),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  amountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'amount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  amountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'amount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  amountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'amount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  categoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'category'),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  categoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'category'),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  categoryEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  categoryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  categoryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  categoryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'category',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  categoryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  categoryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'category',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  dayOfMonthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dayOfMonth', value: value),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  dayOfMonthGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dayOfMonth',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  dayOfMonthLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dayOfMonth',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  dayOfMonthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dayOfMonth',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'endMonth'),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'endMonth'),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'endMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'endMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'endMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endMonth',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'endMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'endMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'endMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'endMonth',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endMonth', value: ''),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'endMonth', value: ''),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'endMonthNumber'),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'endMonthNumber'),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthNumberEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endMonthNumber', value: value),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthNumberGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'endMonthNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthNumberLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'endMonthNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endMonthNumberBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endMonthNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endYearIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'endYear'),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endYearIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'endYear'),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endYearEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endYear', value: value),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endYearGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'endYear',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endYearLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'endYear',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  endYearBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endYear',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isActive', value: value),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  memoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'memo'),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  memoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'memo'),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  memoEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'memo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  memoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'memo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  memoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'memo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  memoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'memo',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  memoStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'memo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  memoEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'memo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  memoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'memo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  memoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'memo',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  memoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'memo', value: ''),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  memoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'memo', value: ''),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startMonthEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'startMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startMonthGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startMonthLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startMonthBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startMonth',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startMonthStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'startMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startMonthEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'startMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startMonthContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'startMonth',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startMonthMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'startMonth',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startMonthIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startMonth', value: ''),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startMonthIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'startMonth', value: ''),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startMonthNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startMonthNumber', value: value),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startMonthNumberGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startMonthNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startMonthNumberLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startMonthNumber',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startMonthNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startMonthNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startYearEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startYear', value: value),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startYearGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startYear',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startYearLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startYear',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  startYearBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startYear',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  typeEqualTo(RecurringTransactionType value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  typeGreaterThan(
    RecurringTransactionType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  typeLessThan(
    RecurringTransactionType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  typeBetween(
    RecurringTransactionType lower,
    RecurringTransactionType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  typeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  typeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'type',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterFilterCondition
  >
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension RecurringTransactionModelQueryObject
    on
        QueryBuilder<
          RecurringTransactionModel,
          RecurringTransactionModel,
          QFilterCondition
        > {}

extension RecurringTransactionModelQueryLinks
    on
        QueryBuilder<
          RecurringTransactionModel,
          RecurringTransactionModel,
          QFilterCondition
        > {}

extension RecurringTransactionModelQuerySortBy
    on
        QueryBuilder<
          RecurringTransactionModel,
          RecurringTransactionModel,
          QSortBy
        > {
  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByDayOfMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayOfMonth', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByDayOfMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayOfMonth', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByEndMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMonth', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByEndMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMonth', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByEndMonthNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMonthNumber', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByEndMonthNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMonthNumber', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByEndYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endYear', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByEndYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endYear', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByMemo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memo', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByMemoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memo', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByStartMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMonth', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByStartMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMonth', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByStartMonthNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMonthNumber', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByStartMonthNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMonthNumber', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByStartYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startYear', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByStartYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startYear', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension RecurringTransactionModelQuerySortThenBy
    on
        QueryBuilder<
          RecurringTransactionModel,
          RecurringTransactionModel,
          QSortThenBy
        > {
  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByDayOfMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayOfMonth', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByDayOfMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dayOfMonth', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByEndMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMonth', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByEndMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMonth', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByEndMonthNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMonthNumber', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByEndMonthNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endMonthNumber', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByEndYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endYear', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByEndYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endYear', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByMemo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memo', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByMemoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memo', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByStartMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMonth', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByStartMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMonth', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByStartMonthNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMonthNumber', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByStartMonthNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startMonthNumber', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByStartYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startYear', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByStartYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startYear', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionModel,
    QAfterSortBy
  >
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension RecurringTransactionModelQueryWhereDistinct
    on
        QueryBuilder<
          RecurringTransactionModel,
          RecurringTransactionModel,
          QDistinct
        > {
  QueryBuilder<RecurringTransactionModel, RecurringTransactionModel, QDistinct>
  distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<RecurringTransactionModel, RecurringTransactionModel, QDistinct>
  distinctByCategory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTransactionModel, RecurringTransactionModel, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<RecurringTransactionModel, RecurringTransactionModel, QDistinct>
  distinctByDayOfMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dayOfMonth');
    });
  }

  QueryBuilder<RecurringTransactionModel, RecurringTransactionModel, QDistinct>
  distinctByEndMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endMonth', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTransactionModel, RecurringTransactionModel, QDistinct>
  distinctByEndMonthNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endMonthNumber');
    });
  }

  QueryBuilder<RecurringTransactionModel, RecurringTransactionModel, QDistinct>
  distinctByEndYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endYear');
    });
  }

  QueryBuilder<RecurringTransactionModel, RecurringTransactionModel, QDistinct>
  distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<RecurringTransactionModel, RecurringTransactionModel, QDistinct>
  distinctByMemo({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'memo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTransactionModel, RecurringTransactionModel, QDistinct>
  distinctByStartMonth({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startMonth', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTransactionModel, RecurringTransactionModel, QDistinct>
  distinctByStartMonthNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startMonthNumber');
    });
  }

  QueryBuilder<RecurringTransactionModel, RecurringTransactionModel, QDistinct>
  distinctByStartYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startYear');
    });
  }

  QueryBuilder<RecurringTransactionModel, RecurringTransactionModel, QDistinct>
  distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTransactionModel, RecurringTransactionModel, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension RecurringTransactionModelQueryProperty
    on
        QueryBuilder<
          RecurringTransactionModel,
          RecurringTransactionModel,
          QQueryProperty
        > {
  QueryBuilder<RecurringTransactionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RecurringTransactionModel, int, QQueryOperations>
  amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<RecurringTransactionModel, String?, QQueryOperations>
  categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<RecurringTransactionModel, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<RecurringTransactionModel, int, QQueryOperations>
  dayOfMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dayOfMonth');
    });
  }

  QueryBuilder<RecurringTransactionModel, String?, QQueryOperations>
  endMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endMonth');
    });
  }

  QueryBuilder<RecurringTransactionModel, int?, QQueryOperations>
  endMonthNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endMonthNumber');
    });
  }

  QueryBuilder<RecurringTransactionModel, int?, QQueryOperations>
  endYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endYear');
    });
  }

  QueryBuilder<RecurringTransactionModel, bool, QQueryOperations>
  isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<RecurringTransactionModel, String?, QQueryOperations>
  memoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'memo');
    });
  }

  QueryBuilder<RecurringTransactionModel, String, QQueryOperations>
  startMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startMonth');
    });
  }

  QueryBuilder<RecurringTransactionModel, int, QQueryOperations>
  startMonthNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startMonthNumber');
    });
  }

  QueryBuilder<RecurringTransactionModel, int, QQueryOperations>
  startYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startYear');
    });
  }

  QueryBuilder<
    RecurringTransactionModel,
    RecurringTransactionType,
    QQueryOperations
  >
  typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<RecurringTransactionModel, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
