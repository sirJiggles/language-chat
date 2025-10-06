// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_metrics_db.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMessageMetricsDBCollection on Isar {
  IsarCollection<MessageMetricsDB> get messageMetricsDBs => this.collection();
}

const MessageMetricsDBSchema = CollectionSchema(
  name: r'MessageMetricsDB',
  id: -8409328521467672040,
  properties: {
    r'aiResponse': PropertySchema(
      id: 0,
      name: r'aiResponse',
      type: IsarType.string,
    ),
    r'avgWordLength': PropertySchema(
      id: 1,
      name: r'avgWordLength',
      type: IsarType.double,
    ),
    r'errorCount': PropertySchema(
      id: 2,
      name: r'errorCount',
      type: IsarType.long,
    ),
    r'errorTypes': PropertySchema(
      id: 3,
      name: r'errorTypes',
      type: IsarType.stringList,
    ),
    r'grammarStructures': PropertySchema(
      id: 4,
      name: r'grammarStructures',
      type: IsarType.stringList,
    ),
    r'sentenceCount': PropertySchema(
      id: 5,
      name: r'sentenceCount',
      type: IsarType.long,
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
    ),
    r'uniqueWordCount': PropertySchema(
      id: 8,
      name: r'uniqueWordCount',
      type: IsarType.long,
    ),
    r'userMessage': PropertySchema(
      id: 9,
      name: r'userMessage',
      type: IsarType.string,
    ),
    r'vocabularyUsed': PropertySchema(
      id: 10,
      name: r'vocabularyUsed',
      type: IsarType.stringList,
    ),
    r'wordCount': PropertySchema(
      id: 11,
      name: r'wordCount',
      type: IsarType.long,
    )
  },
  estimateSize: _messageMetricsDBEstimateSize,
  serialize: _messageMetricsDBSerialize,
  deserialize: _messageMetricsDBDeserialize,
  deserializeProp: _messageMetricsDBDeserializeProp,
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
    r'sessionId': IndexSchema(
      id: 6949518585047923839,
      name: r'sessionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _messageMetricsDBGetId,
  getLinks: _messageMetricsDBGetLinks,
  attach: _messageMetricsDBAttach,
  version: '3.1.0+1',
);

int _messageMetricsDBEstimateSize(
  MessageMetricsDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.aiResponse;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.errorTypes.length * 3;
  {
    for (var i = 0; i < object.errorTypes.length; i++) {
      final value = object.errorTypes[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.grammarStructures.length * 3;
  {
    for (var i = 0; i < object.grammarStructures.length; i++) {
      final value = object.grammarStructures[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.sessionId.length * 3;
  bytesCount += 3 + object.userMessage.length * 3;
  bytesCount += 3 + object.vocabularyUsed.length * 3;
  {
    for (var i = 0; i < object.vocabularyUsed.length; i++) {
      final value = object.vocabularyUsed[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _messageMetricsDBSerialize(
  MessageMetricsDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aiResponse);
  writer.writeDouble(offsets[1], object.avgWordLength);
  writer.writeLong(offsets[2], object.errorCount);
  writer.writeStringList(offsets[3], object.errorTypes);
  writer.writeStringList(offsets[4], object.grammarStructures);
  writer.writeLong(offsets[5], object.sentenceCount);
  writer.writeString(offsets[6], object.sessionId);
  writer.writeDateTime(offsets[7], object.timestamp);
  writer.writeLong(offsets[8], object.uniqueWordCount);
  writer.writeString(offsets[9], object.userMessage);
  writer.writeStringList(offsets[10], object.vocabularyUsed);
  writer.writeLong(offsets[11], object.wordCount);
}

MessageMetricsDB _messageMetricsDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MessageMetricsDB();
  object.aiResponse = reader.readStringOrNull(offsets[0]);
  object.avgWordLength = reader.readDouble(offsets[1]);
  object.errorCount = reader.readLong(offsets[2]);
  object.errorTypes = reader.readStringList(offsets[3]) ?? [];
  object.grammarStructures = reader.readStringList(offsets[4]) ?? [];
  object.id = id;
  object.sentenceCount = reader.readLong(offsets[5]);
  object.sessionId = reader.readString(offsets[6]);
  object.timestamp = reader.readDateTime(offsets[7]);
  object.uniqueWordCount = reader.readLong(offsets[8]);
  object.userMessage = reader.readString(offsets[9]);
  object.vocabularyUsed = reader.readStringList(offsets[10]) ?? [];
  object.wordCount = reader.readLong(offsets[11]);
  return object;
}

P _messageMetricsDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringList(offset) ?? []) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _messageMetricsDBGetId(MessageMetricsDB object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _messageMetricsDBGetLinks(MessageMetricsDB object) {
  return [];
}

void _messageMetricsDBAttach(
    IsarCollection<dynamic> col, Id id, MessageMetricsDB object) {
  object.id = id;
}

extension MessageMetricsDBQueryWhereSort
    on QueryBuilder<MessageMetricsDB, MessageMetricsDB, QWhere> {
  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension MessageMetricsDBQueryWhere
    on QueryBuilder<MessageMetricsDB, MessageMetricsDB, QWhereClause> {
  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterWhereClause>
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterWhereClause> idBetween(
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterWhereClause>
      timestampEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterWhereClause>
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterWhereClause>
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterWhereClause>
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterWhereClause>
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterWhereClause>
      sessionIdEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionId',
        value: [sessionId],
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterWhereClause>
      sessionIdNotEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MessageMetricsDBQueryFilter
    on QueryBuilder<MessageMetricsDB, MessageMetricsDB, QFilterCondition> {
  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      aiResponseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiResponse',
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      aiResponseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiResponse',
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      aiResponseEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiResponse',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      aiResponseGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiResponse',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      aiResponseLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiResponse',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      aiResponseBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiResponse',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      aiResponseStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiResponse',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      aiResponseEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiResponse',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      aiResponseContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiResponse',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      aiResponseMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiResponse',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      aiResponseIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiResponse',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      aiResponseIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiResponse',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      avgWordLengthEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgWordLength',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      avgWordLengthGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgWordLength',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      avgWordLengthLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgWordLength',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      avgWordLengthBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgWordLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorTypesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorTypesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorTypesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorTypesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorTypes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorTypesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'errorTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorTypesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'errorTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorTypesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'errorTypes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorTypesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'errorTypes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorTypesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorTypes',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorTypesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'errorTypes',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorTypesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'errorTypes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorTypesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'errorTypes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorTypesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'errorTypes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorTypesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'errorTypes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorTypesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'errorTypes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      errorTypesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'errorTypes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      grammarStructuresElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grammarStructures',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      grammarStructuresElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'grammarStructures',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      grammarStructuresElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'grammarStructures',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      grammarStructuresElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'grammarStructures',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      grammarStructuresElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'grammarStructures',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      grammarStructuresElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'grammarStructures',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      grammarStructuresElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'grammarStructures',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      grammarStructuresElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'grammarStructures',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      grammarStructuresElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grammarStructures',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      grammarStructuresElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'grammarStructures',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      grammarStructuresLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'grammarStructures',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      grammarStructuresIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'grammarStructures',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      grammarStructuresIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'grammarStructures',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      grammarStructuresLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'grammarStructures',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      grammarStructuresLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'grammarStructures',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      grammarStructuresLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'grammarStructures',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      sentenceCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sentenceCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      sentenceCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sentenceCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      sentenceCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sentenceCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      sentenceCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sentenceCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      sessionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      sessionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sessionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      sessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      sessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
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

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      uniqueWordCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uniqueWordCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      uniqueWordCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uniqueWordCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      uniqueWordCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uniqueWordCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      uniqueWordCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uniqueWordCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      userMessageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      userMessageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      userMessageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      userMessageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      userMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      userMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      userMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      userMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      userMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      userMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      vocabularyUsedElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vocabularyUsed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      vocabularyUsedElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vocabularyUsed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      vocabularyUsedElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vocabularyUsed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      vocabularyUsedElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vocabularyUsed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      vocabularyUsedElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'vocabularyUsed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      vocabularyUsedElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'vocabularyUsed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      vocabularyUsedElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vocabularyUsed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      vocabularyUsedElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vocabularyUsed',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      vocabularyUsedElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vocabularyUsed',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      vocabularyUsedElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vocabularyUsed',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      vocabularyUsedLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vocabularyUsed',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      vocabularyUsedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vocabularyUsed',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      vocabularyUsedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vocabularyUsed',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      vocabularyUsedLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vocabularyUsed',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      vocabularyUsedLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vocabularyUsed',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      vocabularyUsedLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vocabularyUsed',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      wordCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wordCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      wordCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wordCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      wordCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wordCount',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterFilterCondition>
      wordCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wordCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MessageMetricsDBQueryObject
    on QueryBuilder<MessageMetricsDB, MessageMetricsDB, QFilterCondition> {}

extension MessageMetricsDBQueryLinks
    on QueryBuilder<MessageMetricsDB, MessageMetricsDB, QFilterCondition> {}

extension MessageMetricsDBQuerySortBy
    on QueryBuilder<MessageMetricsDB, MessageMetricsDB, QSortBy> {
  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortByAiResponse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiResponse', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortByAiResponseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiResponse', Sort.desc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortByAvgWordLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgWordLength', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortByAvgWordLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgWordLength', Sort.desc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortByErrorCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorCount', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortByErrorCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorCount', Sort.desc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortBySentenceCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentenceCount', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortBySentenceCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentenceCount', Sort.desc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortByUniqueWordCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueWordCount', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortByUniqueWordCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueWordCount', Sort.desc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortByUserMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userMessage', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortByUserMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userMessage', Sort.desc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortByWordCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordCount', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      sortByWordCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordCount', Sort.desc);
    });
  }
}

extension MessageMetricsDBQuerySortThenBy
    on QueryBuilder<MessageMetricsDB, MessageMetricsDB, QSortThenBy> {
  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenByAiResponse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiResponse', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenByAiResponseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiResponse', Sort.desc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenByAvgWordLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgWordLength', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenByAvgWordLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgWordLength', Sort.desc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenByErrorCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorCount', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenByErrorCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorCount', Sort.desc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenBySentenceCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentenceCount', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenBySentenceCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentenceCount', Sort.desc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenByUniqueWordCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueWordCount', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenByUniqueWordCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueWordCount', Sort.desc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenByUserMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userMessage', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenByUserMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userMessage', Sort.desc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenByWordCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordCount', Sort.asc);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QAfterSortBy>
      thenByWordCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordCount', Sort.desc);
    });
  }
}

extension MessageMetricsDBQueryWhereDistinct
    on QueryBuilder<MessageMetricsDB, MessageMetricsDB, QDistinct> {
  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QDistinct>
      distinctByAiResponse({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiResponse', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QDistinct>
      distinctByAvgWordLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgWordLength');
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QDistinct>
      distinctByErrorCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorCount');
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QDistinct>
      distinctByErrorTypes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorTypes');
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QDistinct>
      distinctByGrammarStructures() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'grammarStructures');
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QDistinct>
      distinctBySentenceCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sentenceCount');
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QDistinct>
      distinctBySessionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QDistinct>
      distinctByUniqueWordCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uniqueWordCount');
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QDistinct>
      distinctByUserMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QDistinct>
      distinctByVocabularyUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vocabularyUsed');
    });
  }

  QueryBuilder<MessageMetricsDB, MessageMetricsDB, QDistinct>
      distinctByWordCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wordCount');
    });
  }
}

extension MessageMetricsDBQueryProperty
    on QueryBuilder<MessageMetricsDB, MessageMetricsDB, QQueryProperty> {
  QueryBuilder<MessageMetricsDB, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MessageMetricsDB, String?, QQueryOperations>
      aiResponseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiResponse');
    });
  }

  QueryBuilder<MessageMetricsDB, double, QQueryOperations>
      avgWordLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgWordLength');
    });
  }

  QueryBuilder<MessageMetricsDB, int, QQueryOperations> errorCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorCount');
    });
  }

  QueryBuilder<MessageMetricsDB, List<String>, QQueryOperations>
      errorTypesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorTypes');
    });
  }

  QueryBuilder<MessageMetricsDB, List<String>, QQueryOperations>
      grammarStructuresProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'grammarStructures');
    });
  }

  QueryBuilder<MessageMetricsDB, int, QQueryOperations>
      sentenceCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sentenceCount');
    });
  }

  QueryBuilder<MessageMetricsDB, String, QQueryOperations> sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<MessageMetricsDB, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<MessageMetricsDB, int, QQueryOperations>
      uniqueWordCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uniqueWordCount');
    });
  }

  QueryBuilder<MessageMetricsDB, String, QQueryOperations>
      userMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userMessage');
    });
  }

  QueryBuilder<MessageMetricsDB, List<String>, QQueryOperations>
      vocabularyUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vocabularyUsed');
    });
  }

  QueryBuilder<MessageMetricsDB, int, QQueryOperations> wordCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wordCount');
    });
  }
}
