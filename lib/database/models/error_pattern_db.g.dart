// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_pattern_db.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetErrorPatternDBCollection on Isar {
  IsarCollection<ErrorPatternDB> get errorPatternDBs => this.collection();
}

const ErrorPatternDBSchema = CollectionSchema(
  name: r'ErrorPatternDB',
  id: 7250159111412023639,
  properties: {
    r'category': PropertySchema(
      id: 0,
      name: r'category',
      type: IsarType.string,
    ),
    r'context': PropertySchema(
      id: 1,
      name: r'context',
      type: IsarType.string,
    ),
    r'correction': PropertySchema(
      id: 2,
      name: r'correction',
      type: IsarType.string,
    ),
    r'errorType': PropertySchema(
      id: 3,
      name: r'errorType',
      type: IsarType.string,
    ),
    r'occurrenceCount': PropertySchema(
      id: 4,
      name: r'occurrenceCount',
      type: IsarType.long,
    ),
    r'recurring': PropertySchema(
      id: 5,
      name: r'recurring',
      type: IsarType.bool,
    ),
    r'sessionId': PropertySchema(
      id: 6,
      name: r'sessionId',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 7,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _errorPatternDBEstimateSize,
  serialize: _errorPatternDBSerialize,
  deserialize: _errorPatternDBDeserialize,
  deserializeProp: _errorPatternDBDeserializeProp,
  idName: r'id',
  indexes: {
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'errorType': IndexSchema(
      id: -1495321274758290662,
      name: r'errorType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'errorType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'category': IndexSchema(
      id: -7560358558326323820,
      name: r'category',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'category',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _errorPatternDBGetId,
  getLinks: _errorPatternDBGetLinks,
  attach: _errorPatternDBAttach,
  version: '3.1.0+1',
);

int _errorPatternDBEstimateSize(
  ErrorPatternDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.category.length * 3;
  bytesCount += 3 + object.context.length * 3;
  bytesCount += 3 + object.correction.length * 3;
  bytesCount += 3 + object.errorType.length * 3;
  bytesCount += 3 + object.sessionId.length * 3;
  return bytesCount;
}

void _errorPatternDBSerialize(
  ErrorPatternDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.category);
  writer.writeString(offsets[1], object.context);
  writer.writeString(offsets[2], object.correction);
  writer.writeString(offsets[3], object.errorType);
  writer.writeLong(offsets[4], object.occurrenceCount);
  writer.writeBool(offsets[5], object.recurring);
  writer.writeString(offsets[6], object.sessionId);
  writer.writeDateTime(offsets[7], object.timestamp);
}

ErrorPatternDB _errorPatternDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ErrorPatternDB();
  object.category = reader.readString(offsets[0]);
  object.context = reader.readString(offsets[1]);
  object.correction = reader.readString(offsets[2]);
  object.errorType = reader.readString(offsets[3]);
  object.id = id;
  object.occurrenceCount = reader.readLong(offsets[4]);
  object.recurring = reader.readBool(offsets[5]);
  object.sessionId = reader.readString(offsets[6]);
  object.timestamp = reader.readDateTime(offsets[7]);
  return object;
}

P _errorPatternDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _errorPatternDBGetId(ErrorPatternDB object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _errorPatternDBGetLinks(ErrorPatternDB object) {
  return [];
}

void _errorPatternDBAttach(
    IsarCollection<dynamic> col, Id id, ErrorPatternDB object) {
  object.id = id;
}

extension ErrorPatternDBQueryWhereSort
    on QueryBuilder<ErrorPatternDB, ErrorPatternDB, QWhere> {
  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension ErrorPatternDBQueryWhere
    on QueryBuilder<ErrorPatternDB, ErrorPatternDB, QWhereClause> {
  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterWhereClause>
      timestampEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterWhereClause>
      timestampNotEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterWhereClause>
      timestampGreaterThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [timestamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterWhereClause>
      timestampLessThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [],
        upper: [timestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterWhereClause>
      timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [lowerTimestamp],
        includeLower: includeLower,
        upper: [upperTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterWhereClause>
      errorTypeEqualTo(String errorType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'errorType',
        value: [errorType],
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterWhereClause>
      errorTypeNotEqualTo(String errorType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'errorType',
              lower: [],
              upper: [errorType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'errorType',
              lower: [errorType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'errorType',
              lower: [errorType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'errorType',
              lower: [],
              upper: [errorType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterWhereClause>
      categoryEqualTo(String category) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'category',
        value: [category],
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterWhereClause>
      categoryNotEqualTo(String category) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'category',
              lower: [],
              upper: [category],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'category',
              lower: [category],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'category',
              lower: [category],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'category',
              lower: [],
              upper: [category],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ErrorPatternDBQueryFilter
    on QueryBuilder<ErrorPatternDB, ErrorPatternDB, QFilterCondition> {
  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      categoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      contextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'context',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      contextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'context',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      contextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'context',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      contextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'context',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      contextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'context',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      contextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'context',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      contextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'context',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      contextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'context',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      contextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'context',
        value: '',
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      contextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'context',
        value: '',
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      correctionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      correctionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      correctionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      correctionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correction',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      correctionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'correction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      correctionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'correction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      correctionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'correction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      correctionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'correction',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      correctionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correction',
        value: '',
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      correctionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'correction',
        value: '',
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      errorTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      errorTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      errorTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      errorTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      errorTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'errorType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      errorTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'errorType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      errorTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'errorType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      errorTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'errorType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      errorTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorType',
        value: '',
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      errorTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'errorType',
        value: '',
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      occurrenceCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'occurrenceCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      occurrenceCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'occurrenceCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      occurrenceCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'occurrenceCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      occurrenceCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'occurrenceCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      recurringEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recurring',
        value: value,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      sessionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      sessionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      sessionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      sessionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      sessionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      sessionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      sessionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      sessionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sessionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      sessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      sessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ErrorPatternDBQueryObject
    on QueryBuilder<ErrorPatternDB, ErrorPatternDB, QFilterCondition> {}

extension ErrorPatternDBQueryLinks
    on QueryBuilder<ErrorPatternDB, ErrorPatternDB, QFilterCondition> {}

extension ErrorPatternDBQuerySortBy
    on QueryBuilder<ErrorPatternDB, ErrorPatternDB, QSortBy> {
  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy> sortByContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'context', Sort.asc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      sortByContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'context', Sort.desc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      sortByCorrection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correction', Sort.asc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      sortByCorrectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correction', Sort.desc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy> sortByErrorType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorType', Sort.asc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      sortByErrorTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorType', Sort.desc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      sortByOccurrenceCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceCount', Sort.asc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      sortByOccurrenceCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceCount', Sort.desc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy> sortByRecurring() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurring', Sort.asc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      sortByRecurringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurring', Sort.desc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy> sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension ErrorPatternDBQuerySortThenBy
    on QueryBuilder<ErrorPatternDB, ErrorPatternDB, QSortThenBy> {
  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy> thenByContext() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'context', Sort.asc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      thenByContextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'context', Sort.desc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      thenByCorrection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correction', Sort.asc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      thenByCorrectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correction', Sort.desc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy> thenByErrorType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorType', Sort.asc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      thenByErrorTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorType', Sort.desc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      thenByOccurrenceCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceCount', Sort.asc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      thenByOccurrenceCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'occurrenceCount', Sort.desc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy> thenByRecurring() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurring', Sort.asc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      thenByRecurringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurring', Sort.desc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy> thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension ErrorPatternDBQueryWhereDistinct
    on QueryBuilder<ErrorPatternDB, ErrorPatternDB, QDistinct> {
  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QDistinct> distinctByCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QDistinct> distinctByContext(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'context', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QDistinct> distinctByCorrection(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correction', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QDistinct> distinctByErrorType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QDistinct>
      distinctByOccurrenceCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'occurrenceCount');
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QDistinct>
      distinctByRecurring() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurring');
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QDistinct> distinctBySessionId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ErrorPatternDB, ErrorPatternDB, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension ErrorPatternDBQueryProperty
    on QueryBuilder<ErrorPatternDB, ErrorPatternDB, QQueryProperty> {
  QueryBuilder<ErrorPatternDB, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ErrorPatternDB, String, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<ErrorPatternDB, String, QQueryOperations> contextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'context');
    });
  }

  QueryBuilder<ErrorPatternDB, String, QQueryOperations> correctionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correction');
    });
  }

  QueryBuilder<ErrorPatternDB, String, QQueryOperations> errorTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorType');
    });
  }

  QueryBuilder<ErrorPatternDB, int, QQueryOperations>
      occurrenceCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'occurrenceCount');
    });
  }

  QueryBuilder<ErrorPatternDB, bool, QQueryOperations> recurringProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurring');
    });
  }

  QueryBuilder<ErrorPatternDB, String, QQueryOperations> sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<ErrorPatternDB, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
