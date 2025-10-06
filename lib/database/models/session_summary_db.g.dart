// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_summary_db.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSessionSummaryDBCollection on Isar {
  IsarCollection<SessionSummaryDB> get sessionSummaryDBs => this.collection();
}

const SessionSummaryDBSchema = CollectionSchema(
  name: r'SessionSummaryDB',
  id: -7637214465357854752,
  properties: {
    r'assessedLevel': PropertySchema(
      id: 0,
      name: r'assessedLevel',
      type: IsarType.string,
    ),
    r'avgMessageLength': PropertySchema(
      id: 1,
      name: r'avgMessageLength',
      type: IsarType.double,
    ),
    r'endTime': PropertySchema(
      id: 2,
      name: r'endTime',
      type: IsarType.dateTime,
    ),
    r'errorRate': PropertySchema(
      id: 3,
      name: r'errorRate',
      type: IsarType.double,
    ),
    r'grammarPointsUsed': PropertySchema(
      id: 4,
      name: r'grammarPointsUsed',
      type: IsarType.stringList,
    ),
    r'lastAssessmentTime': PropertySchema(
      id: 5,
      name: r'lastAssessmentTime',
      type: IsarType.dateTime,
    ),
    r'newVocabulary': PropertySchema(
      id: 6,
      name: r'newVocabulary',
      type: IsarType.stringList,
    ),
    r'sessionId': PropertySchema(
      id: 7,
      name: r'sessionId',
      type: IsarType.string,
    ),
    r'startTime': PropertySchema(
      id: 8,
      name: r'startTime',
      type: IsarType.dateTime,
    ),
    r'topicsDiscussed': PropertySchema(
      id: 9,
      name: r'topicsDiscussed',
      type: IsarType.stringList,
    ),
    r'totalErrors': PropertySchema(
      id: 10,
      name: r'totalErrors',
      type: IsarType.long,
    ),
    r'totalMessages': PropertySchema(
      id: 11,
      name: r'totalMessages',
      type: IsarType.long,
    ),
    r'totalWords': PropertySchema(
      id: 12,
      name: r'totalWords',
      type: IsarType.long,
    ),
    r'uniqueWordsUsed': PropertySchema(
      id: 13,
      name: r'uniqueWordsUsed',
      type: IsarType.long,
    ),
    r'vocabularyDiversity': PropertySchema(
      id: 14,
      name: r'vocabularyDiversity',
      type: IsarType.double,
    )
  },
  estimateSize: _sessionSummaryDBEstimateSize,
  serialize: _sessionSummaryDBSerialize,
  deserialize: _sessionSummaryDBDeserialize,
  deserializeProp: _sessionSummaryDBDeserializeProp,
  idName: r'id',
  indexes: {
    r'sessionId': IndexSchema(
      id: 6949518585047923839,
      name: r'sessionId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'startTime': IndexSchema(
      id: -3870335341264752872,
      name: r'startTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startTime',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _sessionSummaryDBGetId,
  getLinks: _sessionSummaryDBGetLinks,
  attach: _sessionSummaryDBAttach,
  version: '3.1.0+1',
);

int _sessionSummaryDBEstimateSize(
  SessionSummaryDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.assessedLevel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.grammarPointsUsed.length * 3;
  {
    for (var i = 0; i < object.grammarPointsUsed.length; i++) {
      final value = object.grammarPointsUsed[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.newVocabulary.length * 3;
  {
    for (var i = 0; i < object.newVocabulary.length; i++) {
      final value = object.newVocabulary[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.sessionId.length * 3;
  bytesCount += 3 + object.topicsDiscussed.length * 3;
  {
    for (var i = 0; i < object.topicsDiscussed.length; i++) {
      final value = object.topicsDiscussed[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _sessionSummaryDBSerialize(
  SessionSummaryDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.assessedLevel);
  writer.writeDouble(offsets[1], object.avgMessageLength);
  writer.writeDateTime(offsets[2], object.endTime);
  writer.writeDouble(offsets[3], object.errorRate);
  writer.writeStringList(offsets[4], object.grammarPointsUsed);
  writer.writeDateTime(offsets[5], object.lastAssessmentTime);
  writer.writeStringList(offsets[6], object.newVocabulary);
  writer.writeString(offsets[7], object.sessionId);
  writer.writeDateTime(offsets[8], object.startTime);
  writer.writeStringList(offsets[9], object.topicsDiscussed);
  writer.writeLong(offsets[10], object.totalErrors);
  writer.writeLong(offsets[11], object.totalMessages);
  writer.writeLong(offsets[12], object.totalWords);
  writer.writeLong(offsets[13], object.uniqueWordsUsed);
  writer.writeDouble(offsets[14], object.vocabularyDiversity);
}

SessionSummaryDB _sessionSummaryDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SessionSummaryDB();
  object.assessedLevel = reader.readStringOrNull(offsets[0]);
  object.avgMessageLength = reader.readDouble(offsets[1]);
  object.endTime = reader.readDateTimeOrNull(offsets[2]);
  object.errorRate = reader.readDouble(offsets[3]);
  object.grammarPointsUsed = reader.readStringList(offsets[4]) ?? [];
  object.id = id;
  object.lastAssessmentTime = reader.readDateTimeOrNull(offsets[5]);
  object.newVocabulary = reader.readStringList(offsets[6]) ?? [];
  object.sessionId = reader.readString(offsets[7]);
  object.startTime = reader.readDateTime(offsets[8]);
  object.topicsDiscussed = reader.readStringList(offsets[9]) ?? [];
  object.totalErrors = reader.readLong(offsets[10]);
  object.totalMessages = reader.readLong(offsets[11]);
  object.totalWords = reader.readLong(offsets[12]);
  object.uniqueWordsUsed = reader.readLong(offsets[13]);
  object.vocabularyDiversity = reader.readDouble(offsets[14]);
  return object;
}

P _sessionSummaryDBDeserializeProp<P>(
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
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readStringList(offset) ?? []) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sessionSummaryDBGetId(SessionSummaryDB object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sessionSummaryDBGetLinks(SessionSummaryDB object) {
  return [];
}

void _sessionSummaryDBAttach(
    IsarCollection<dynamic> col, Id id, SessionSummaryDB object) {
  object.id = id;
}

extension SessionSummaryDBByIndex on IsarCollection<SessionSummaryDB> {
  Future<SessionSummaryDB?> getBySessionId(String sessionId) {
    return getByIndex(r'sessionId', [sessionId]);
  }

  SessionSummaryDB? getBySessionIdSync(String sessionId) {
    return getByIndexSync(r'sessionId', [sessionId]);
  }

  Future<bool> deleteBySessionId(String sessionId) {
    return deleteByIndex(r'sessionId', [sessionId]);
  }

  bool deleteBySessionIdSync(String sessionId) {
    return deleteByIndexSync(r'sessionId', [sessionId]);
  }

  Future<List<SessionSummaryDB?>> getAllBySessionId(
      List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'sessionId', values);
  }

  List<SessionSummaryDB?> getAllBySessionIdSync(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'sessionId', values);
  }

  Future<int> deleteAllBySessionId(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'sessionId', values);
  }

  int deleteAllBySessionIdSync(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'sessionId', values);
  }

  Future<Id> putBySessionId(SessionSummaryDB object) {
    return putByIndex(r'sessionId', object);
  }

  Id putBySessionIdSync(SessionSummaryDB object, {bool saveLinks = true}) {
    return putByIndexSync(r'sessionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySessionId(List<SessionSummaryDB> objects) {
    return putAllByIndex(r'sessionId', objects);
  }

  List<Id> putAllBySessionIdSync(List<SessionSummaryDB> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'sessionId', objects, saveLinks: saveLinks);
  }
}

extension SessionSummaryDBQueryWhereSort
    on QueryBuilder<SessionSummaryDB, SessionSummaryDB, QWhere> {
  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterWhere> anyStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startTime'),
      );
    });
  }
}

extension SessionSummaryDBQueryWhere
    on QueryBuilder<SessionSummaryDB, SessionSummaryDB, QWhereClause> {
  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterWhereClause>
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

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterWhereClause> idBetween(
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

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterWhereClause>
      sessionIdEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionId',
        value: [sessionId],
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterWhereClause>
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

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterWhereClause>
      startTimeEqualTo(DateTime startTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'startTime',
        value: [startTime],
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterWhereClause>
      startTimeNotEqualTo(DateTime startTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startTime',
              lower: [],
              upper: [startTime],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startTime',
              lower: [startTime],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startTime',
              lower: [startTime],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startTime',
              lower: [],
              upper: [startTime],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterWhereClause>
      startTimeGreaterThan(
    DateTime startTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startTime',
        lower: [startTime],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterWhereClause>
      startTimeLessThan(
    DateTime startTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startTime',
        lower: [],
        upper: [startTime],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterWhereClause>
      startTimeBetween(
    DateTime lowerStartTime,
    DateTime upperStartTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startTime',
        lower: [lowerStartTime],
        includeLower: includeLower,
        upper: [upperStartTime],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SessionSummaryDBQueryFilter
    on QueryBuilder<SessionSummaryDB, SessionSummaryDB, QFilterCondition> {
  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      assessedLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'assessedLevel',
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      assessedLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'assessedLevel',
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      assessedLevelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assessedLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      assessedLevelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assessedLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      assessedLevelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assessedLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      assessedLevelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assessedLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      assessedLevelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assessedLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      assessedLevelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assessedLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      assessedLevelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assessedLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      assessedLevelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assessedLevel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      assessedLevelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assessedLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      assessedLevelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assessedLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      avgMessageLengthEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgMessageLength',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      avgMessageLengthGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgMessageLength',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      avgMessageLengthLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgMessageLength',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      avgMessageLengthBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgMessageLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      endTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      endTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      endTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      endTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      endTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      endTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      errorRateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      errorRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      errorRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      errorRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      grammarPointsUsedElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grammarPointsUsed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      grammarPointsUsedElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'grammarPointsUsed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      grammarPointsUsedElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'grammarPointsUsed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      grammarPointsUsedElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'grammarPointsUsed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      grammarPointsUsedElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'grammarPointsUsed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      grammarPointsUsedElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'grammarPointsUsed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      grammarPointsUsedElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'grammarPointsUsed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      grammarPointsUsedElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'grammarPointsUsed',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      grammarPointsUsedElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grammarPointsUsed',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      grammarPointsUsedElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'grammarPointsUsed',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      grammarPointsUsedLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'grammarPointsUsed',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      grammarPointsUsedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'grammarPointsUsed',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      grammarPointsUsedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'grammarPointsUsed',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      grammarPointsUsedLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'grammarPointsUsed',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      grammarPointsUsedLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'grammarPointsUsed',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      grammarPointsUsedLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'grammarPointsUsed',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
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

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
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

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
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

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      lastAssessmentTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastAssessmentTime',
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      lastAssessmentTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastAssessmentTime',
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      lastAssessmentTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastAssessmentTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      lastAssessmentTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastAssessmentTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      lastAssessmentTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastAssessmentTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      lastAssessmentTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastAssessmentTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      newVocabularyElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newVocabulary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      newVocabularyElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'newVocabulary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      newVocabularyElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'newVocabulary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      newVocabularyElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'newVocabulary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      newVocabularyElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'newVocabulary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      newVocabularyElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'newVocabulary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      newVocabularyElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'newVocabulary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      newVocabularyElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'newVocabulary',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      newVocabularyElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newVocabulary',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      newVocabularyElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'newVocabulary',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      newVocabularyLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'newVocabulary',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      newVocabularyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'newVocabulary',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      newVocabularyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'newVocabulary',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      newVocabularyLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'newVocabulary',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      newVocabularyLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'newVocabulary',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      newVocabularyLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'newVocabulary',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
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

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
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

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
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

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
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

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
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

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
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

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      sessionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      sessionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sessionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      sessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      sessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      startTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      startTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      startTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      startTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      topicsDiscussedElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topicsDiscussed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      topicsDiscussedElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topicsDiscussed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      topicsDiscussedElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topicsDiscussed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      topicsDiscussedElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topicsDiscussed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      topicsDiscussedElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'topicsDiscussed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      topicsDiscussedElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'topicsDiscussed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      topicsDiscussedElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'topicsDiscussed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      topicsDiscussedElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'topicsDiscussed',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      topicsDiscussedElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topicsDiscussed',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      topicsDiscussedElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'topicsDiscussed',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      topicsDiscussedLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topicsDiscussed',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      topicsDiscussedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topicsDiscussed',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      topicsDiscussedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topicsDiscussed',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      topicsDiscussedLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topicsDiscussed',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      topicsDiscussedLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topicsDiscussed',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      topicsDiscussedLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topicsDiscussed',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      totalErrorsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalErrors',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      totalErrorsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalErrors',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      totalErrorsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalErrors',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      totalErrorsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalErrors',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      totalMessagesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalMessages',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      totalMessagesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalMessages',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      totalMessagesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalMessages',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      totalMessagesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalMessages',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      totalWordsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalWords',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      totalWordsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalWords',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      totalWordsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalWords',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      totalWordsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalWords',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      uniqueWordsUsedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uniqueWordsUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      uniqueWordsUsedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uniqueWordsUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      uniqueWordsUsedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uniqueWordsUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      uniqueWordsUsedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uniqueWordsUsed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      vocabularyDiversityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vocabularyDiversity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      vocabularyDiversityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vocabularyDiversity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      vocabularyDiversityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vocabularyDiversity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterFilterCondition>
      vocabularyDiversityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vocabularyDiversity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension SessionSummaryDBQueryObject
    on QueryBuilder<SessionSummaryDB, SessionSummaryDB, QFilterCondition> {}

extension SessionSummaryDBQueryLinks
    on QueryBuilder<SessionSummaryDB, SessionSummaryDB, QFilterCondition> {}

extension SessionSummaryDBQuerySortBy
    on QueryBuilder<SessionSummaryDB, SessionSummaryDB, QSortBy> {
  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByAssessedLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assessedLevel', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByAssessedLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assessedLevel', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByAvgMessageLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgMessageLength', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByAvgMessageLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgMessageLength', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByErrorRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorRate', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByErrorRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorRate', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByLastAssessmentTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAssessmentTime', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByLastAssessmentTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAssessmentTime', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByTotalErrors() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalErrors', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByTotalErrorsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalErrors', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByTotalMessages() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMessages', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByTotalMessagesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMessages', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByTotalWords() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWords', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByTotalWordsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWords', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByUniqueWordsUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueWordsUsed', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByUniqueWordsUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueWordsUsed', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByVocabularyDiversity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vocabularyDiversity', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      sortByVocabularyDiversityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vocabularyDiversity', Sort.desc);
    });
  }
}

extension SessionSummaryDBQuerySortThenBy
    on QueryBuilder<SessionSummaryDB, SessionSummaryDB, QSortThenBy> {
  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByAssessedLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assessedLevel', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByAssessedLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assessedLevel', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByAvgMessageLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgMessageLength', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByAvgMessageLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgMessageLength', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByErrorRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorRate', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByErrorRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorRate', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByLastAssessmentTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAssessmentTime', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByLastAssessmentTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAssessmentTime', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByTotalErrors() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalErrors', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByTotalErrorsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalErrors', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByTotalMessages() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMessages', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByTotalMessagesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMessages', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByTotalWords() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWords', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByTotalWordsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWords', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByUniqueWordsUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueWordsUsed', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByUniqueWordsUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueWordsUsed', Sort.desc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByVocabularyDiversity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vocabularyDiversity', Sort.asc);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QAfterSortBy>
      thenByVocabularyDiversityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vocabularyDiversity', Sort.desc);
    });
  }
}

extension SessionSummaryDBQueryWhereDistinct
    on QueryBuilder<SessionSummaryDB, SessionSummaryDB, QDistinct> {
  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QDistinct>
      distinctByAssessedLevel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assessedLevel',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QDistinct>
      distinctByAvgMessageLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgMessageLength');
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QDistinct>
      distinctByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endTime');
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QDistinct>
      distinctByErrorRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorRate');
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QDistinct>
      distinctByGrammarPointsUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'grammarPointsUsed');
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QDistinct>
      distinctByLastAssessmentTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAssessmentTime');
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QDistinct>
      distinctByNewVocabulary() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'newVocabulary');
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QDistinct>
      distinctBySessionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QDistinct>
      distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QDistinct>
      distinctByTopicsDiscussed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topicsDiscussed');
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QDistinct>
      distinctByTotalErrors() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalErrors');
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QDistinct>
      distinctByTotalMessages() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalMessages');
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QDistinct>
      distinctByTotalWords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalWords');
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QDistinct>
      distinctByUniqueWordsUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uniqueWordsUsed');
    });
  }

  QueryBuilder<SessionSummaryDB, SessionSummaryDB, QDistinct>
      distinctByVocabularyDiversity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vocabularyDiversity');
    });
  }
}

extension SessionSummaryDBQueryProperty
    on QueryBuilder<SessionSummaryDB, SessionSummaryDB, QQueryProperty> {
  QueryBuilder<SessionSummaryDB, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SessionSummaryDB, String?, QQueryOperations>
      assessedLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assessedLevel');
    });
  }

  QueryBuilder<SessionSummaryDB, double, QQueryOperations>
      avgMessageLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgMessageLength');
    });
  }

  QueryBuilder<SessionSummaryDB, DateTime?, QQueryOperations>
      endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endTime');
    });
  }

  QueryBuilder<SessionSummaryDB, double, QQueryOperations> errorRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorRate');
    });
  }

  QueryBuilder<SessionSummaryDB, List<String>, QQueryOperations>
      grammarPointsUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'grammarPointsUsed');
    });
  }

  QueryBuilder<SessionSummaryDB, DateTime?, QQueryOperations>
      lastAssessmentTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAssessmentTime');
    });
  }

  QueryBuilder<SessionSummaryDB, List<String>, QQueryOperations>
      newVocabularyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'newVocabulary');
    });
  }

  QueryBuilder<SessionSummaryDB, String, QQueryOperations> sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<SessionSummaryDB, DateTime, QQueryOperations>
      startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }

  QueryBuilder<SessionSummaryDB, List<String>, QQueryOperations>
      topicsDiscussedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topicsDiscussed');
    });
  }

  QueryBuilder<SessionSummaryDB, int, QQueryOperations> totalErrorsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalErrors');
    });
  }

  QueryBuilder<SessionSummaryDB, int, QQueryOperations>
      totalMessagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalMessages');
    });
  }

  QueryBuilder<SessionSummaryDB, int, QQueryOperations> totalWordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalWords');
    });
  }

  QueryBuilder<SessionSummaryDB, int, QQueryOperations>
      uniqueWordsUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uniqueWordsUsed');
    });
  }

  QueryBuilder<SessionSummaryDB, double, QQueryOperations>
      vocabularyDiversityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vocabularyDiversity');
    });
  }
}
