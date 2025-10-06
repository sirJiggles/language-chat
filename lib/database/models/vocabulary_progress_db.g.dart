// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_progress_db.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVocabularyProgressDBCollection on Isar {
  IsarCollection<VocabularyProgressDB> get vocabularyProgressDBs =>
      this.collection();
}

const VocabularyProgressDBSchema = CollectionSchema(
  name: r'VocabularyProgressDB',
  id: -3931021766420875573,
  properties: {
    r'contextExamples': PropertySchema(
      id: 0,
      name: r'contextExamples',
      type: IsarType.stringList,
    ),
    r'correctUsageCount': PropertySchema(
      id: 1,
      name: r'correctUsageCount',
      type: IsarType.long,
    ),
    r'firstUsed': PropertySchema(
      id: 2,
      name: r'firstUsed',
      type: IsarType.dateTime,
    ),
    r'incorrectUsageCount': PropertySchema(
      id: 3,
      name: r'incorrectUsageCount',
      type: IsarType.long,
    ),
    r'lastUsed': PropertySchema(
      id: 4,
      name: r'lastUsed',
      type: IsarType.dateTime,
    ),
    r'level': PropertySchema(
      id: 5,
      name: r'level',
      type: IsarType.string,
    ),
    r'mastered': PropertySchema(
      id: 6,
      name: r'mastered',
      type: IsarType.bool,
    ),
    r'translationOrMeaning': PropertySchema(
      id: 7,
      name: r'translationOrMeaning',
      type: IsarType.string,
    ),
    r'usageCount': PropertySchema(
      id: 8,
      name: r'usageCount',
      type: IsarType.long,
    ),
    r'word': PropertySchema(
      id: 9,
      name: r'word',
      type: IsarType.string,
    )
  },
  estimateSize: _vocabularyProgressDBEstimateSize,
  serialize: _vocabularyProgressDBSerialize,
  deserialize: _vocabularyProgressDBDeserialize,
  deserializeProp: _vocabularyProgressDBDeserializeProp,
  idName: r'id',
  indexes: {
    r'word': IndexSchema(
      id: -2031626334120420267,
      name: r'word',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'word',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'level': IndexSchema(
      id: -730704511986726349,
      name: r'level',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'level',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _vocabularyProgressDBGetId,
  getLinks: _vocabularyProgressDBGetLinks,
  attach: _vocabularyProgressDBAttach,
  version: '3.1.0+1',
);

int _vocabularyProgressDBEstimateSize(
  VocabularyProgressDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.contextExamples.length * 3;
  {
    for (var i = 0; i < object.contextExamples.length; i++) {
      final value = object.contextExamples[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.level.length * 3;
  {
    final value = object.translationOrMeaning;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.word.length * 3;
  return bytesCount;
}

void _vocabularyProgressDBSerialize(
  VocabularyProgressDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.contextExamples);
  writer.writeLong(offsets[1], object.correctUsageCount);
  writer.writeDateTime(offsets[2], object.firstUsed);
  writer.writeLong(offsets[3], object.incorrectUsageCount);
  writer.writeDateTime(offsets[4], object.lastUsed);
  writer.writeString(offsets[5], object.level);
  writer.writeBool(offsets[6], object.mastered);
  writer.writeString(offsets[7], object.translationOrMeaning);
  writer.writeLong(offsets[8], object.usageCount);
  writer.writeString(offsets[9], object.word);
}

VocabularyProgressDB _vocabularyProgressDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VocabularyProgressDB();
  object.contextExamples = reader.readStringList(offsets[0]) ?? [];
  object.correctUsageCount = reader.readLong(offsets[1]);
  object.firstUsed = reader.readDateTime(offsets[2]);
  object.id = id;
  object.incorrectUsageCount = reader.readLong(offsets[3]);
  object.lastUsed = reader.readDateTime(offsets[4]);
  object.level = reader.readString(offsets[5]);
  object.mastered = reader.readBool(offsets[6]);
  object.translationOrMeaning = reader.readStringOrNull(offsets[7]);
  object.usageCount = reader.readLong(offsets[8]);
  object.word = reader.readString(offsets[9]);
  return object;
}

P _vocabularyProgressDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _vocabularyProgressDBGetId(VocabularyProgressDB object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _vocabularyProgressDBGetLinks(
    VocabularyProgressDB object) {
  return [];
}

void _vocabularyProgressDBAttach(
    IsarCollection<dynamic> col, Id id, VocabularyProgressDB object) {
  object.id = id;
}

extension VocabularyProgressDBByIndex on IsarCollection<VocabularyProgressDB> {
  Future<VocabularyProgressDB?> getByWord(String word) {
    return getByIndex(r'word', [word]);
  }

  VocabularyProgressDB? getByWordSync(String word) {
    return getByIndexSync(r'word', [word]);
  }

  Future<bool> deleteByWord(String word) {
    return deleteByIndex(r'word', [word]);
  }

  bool deleteByWordSync(String word) {
    return deleteByIndexSync(r'word', [word]);
  }

  Future<List<VocabularyProgressDB?>> getAllByWord(List<String> wordValues) {
    final values = wordValues.map((e) => [e]).toList();
    return getAllByIndex(r'word', values);
  }

  List<VocabularyProgressDB?> getAllByWordSync(List<String> wordValues) {
    final values = wordValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'word', values);
  }

  Future<int> deleteAllByWord(List<String> wordValues) {
    final values = wordValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'word', values);
  }

  int deleteAllByWordSync(List<String> wordValues) {
    final values = wordValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'word', values);
  }

  Future<Id> putByWord(VocabularyProgressDB object) {
    return putByIndex(r'word', object);
  }

  Id putByWordSync(VocabularyProgressDB object, {bool saveLinks = true}) {
    return putByIndexSync(r'word', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByWord(List<VocabularyProgressDB> objects) {
    return putAllByIndex(r'word', objects);
  }

  List<Id> putAllByWordSync(List<VocabularyProgressDB> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'word', objects, saveLinks: saveLinks);
  }
}

extension VocabularyProgressDBQueryWhereSort
    on QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QWhere> {
  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VocabularyProgressDBQueryWhere
    on QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QWhereClause> {
  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterWhereClause>
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

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterWhereClause>
      wordEqualTo(String word) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'word',
        value: [word],
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterWhereClause>
      wordNotEqualTo(String word) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'word',
              lower: [],
              upper: [word],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'word',
              lower: [word],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'word',
              lower: [word],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'word',
              lower: [],
              upper: [word],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterWhereClause>
      levelEqualTo(String level) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'level',
        value: [level],
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterWhereClause>
      levelNotEqualTo(String level) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'level',
              lower: [],
              upper: [level],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'level',
              lower: [level],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'level',
              lower: [level],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'level',
              lower: [],
              upper: [level],
              includeUpper: false,
            ));
      }
    });
  }
}

extension VocabularyProgressDBQueryFilter on QueryBuilder<VocabularyProgressDB,
    VocabularyProgressDB, QFilterCondition> {
  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> contextExamplesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contextExamples',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> contextExamplesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contextExamples',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> contextExamplesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contextExamples',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> contextExamplesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contextExamples',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> contextExamplesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contextExamples',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> contextExamplesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contextExamples',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
          QAfterFilterCondition>
      contextExamplesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contextExamples',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
          QAfterFilterCondition>
      contextExamplesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contextExamples',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> contextExamplesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contextExamples',
        value: '',
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> contextExamplesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contextExamples',
        value: '',
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> contextExamplesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contextExamples',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> contextExamplesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contextExamples',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> contextExamplesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contextExamples',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> contextExamplesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contextExamples',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> contextExamplesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contextExamples',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> contextExamplesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'contextExamples',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> correctUsageCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctUsageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> correctUsageCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correctUsageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> correctUsageCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correctUsageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> correctUsageCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correctUsageCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> firstUsedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firstUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> firstUsedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'firstUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> firstUsedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'firstUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> firstUsedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'firstUsed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> incorrectUsageCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'incorrectUsageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> incorrectUsageCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'incorrectUsageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> incorrectUsageCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'incorrectUsageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> incorrectUsageCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'incorrectUsageCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> lastUsedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> lastUsedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> lastUsedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> lastUsedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUsed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> levelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> levelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> levelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> levelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'level',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> levelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> levelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
          QAfterFilterCondition>
      levelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
          QAfterFilterCondition>
      levelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'level',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> levelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'level',
        value: '',
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> levelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'level',
        value: '',
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> masteredEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mastered',
        value: value,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> translationOrMeaningIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'translationOrMeaning',
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> translationOrMeaningIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'translationOrMeaning',
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> translationOrMeaningEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'translationOrMeaning',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> translationOrMeaningGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'translationOrMeaning',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> translationOrMeaningLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'translationOrMeaning',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> translationOrMeaningBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'translationOrMeaning',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> translationOrMeaningStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'translationOrMeaning',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> translationOrMeaningEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'translationOrMeaning',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
          QAfterFilterCondition>
      translationOrMeaningContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'translationOrMeaning',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
          QAfterFilterCondition>
      translationOrMeaningMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'translationOrMeaning',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> translationOrMeaningIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'translationOrMeaning',
        value: '',
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> translationOrMeaningIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'translationOrMeaning',
        value: '',
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> usageCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> usageCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> usageCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usageCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> usageCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usageCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> wordEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'word',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> wordGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'word',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> wordLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'word',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> wordBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'word',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> wordStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'word',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> wordEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'word',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
          QAfterFilterCondition>
      wordContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'word',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
          QAfterFilterCondition>
      wordMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'word',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> wordIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'word',
        value: '',
      ));
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB,
      QAfterFilterCondition> wordIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'word',
        value: '',
      ));
    });
  }
}

extension VocabularyProgressDBQueryObject on QueryBuilder<VocabularyProgressDB,
    VocabularyProgressDB, QFilterCondition> {}

extension VocabularyProgressDBQueryLinks on QueryBuilder<VocabularyProgressDB,
    VocabularyProgressDB, QFilterCondition> {}

extension VocabularyProgressDBQuerySortBy
    on QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QSortBy> {
  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByCorrectUsageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctUsageCount', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByCorrectUsageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctUsageCount', Sort.desc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByFirstUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstUsed', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByFirstUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstUsed', Sort.desc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByIncorrectUsageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incorrectUsageCount', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByIncorrectUsageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incorrectUsageCount', Sort.desc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByLastUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.desc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByMastered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mastered', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByMasteredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mastered', Sort.desc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByTranslationOrMeaning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translationOrMeaning', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByTranslationOrMeaningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translationOrMeaning', Sort.desc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByUsageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usageCount', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByUsageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usageCount', Sort.desc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByWord() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'word', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      sortByWordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'word', Sort.desc);
    });
  }
}

extension VocabularyProgressDBQuerySortThenBy
    on QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QSortThenBy> {
  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByCorrectUsageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctUsageCount', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByCorrectUsageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctUsageCount', Sort.desc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByFirstUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstUsed', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByFirstUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstUsed', Sort.desc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByIncorrectUsageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incorrectUsageCount', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByIncorrectUsageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incorrectUsageCount', Sort.desc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByLastUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.desc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByMastered() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mastered', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByMasteredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mastered', Sort.desc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByTranslationOrMeaning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translationOrMeaning', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByTranslationOrMeaningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'translationOrMeaning', Sort.desc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByUsageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usageCount', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByUsageCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usageCount', Sort.desc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByWord() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'word', Sort.asc);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QAfterSortBy>
      thenByWordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'word', Sort.desc);
    });
  }
}

extension VocabularyProgressDBQueryWhereDistinct
    on QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QDistinct> {
  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QDistinct>
      distinctByContextExamples() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contextExamples');
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QDistinct>
      distinctByCorrectUsageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctUsageCount');
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QDistinct>
      distinctByFirstUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firstUsed');
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QDistinct>
      distinctByIncorrectUsageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'incorrectUsageCount');
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QDistinct>
      distinctByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUsed');
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QDistinct>
      distinctByLevel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'level', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QDistinct>
      distinctByMastered() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mastered');
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QDistinct>
      distinctByTranslationOrMeaning({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'translationOrMeaning',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QDistinct>
      distinctByUsageCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usageCount');
    });
  }

  QueryBuilder<VocabularyProgressDB, VocabularyProgressDB, QDistinct>
      distinctByWord({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'word', caseSensitive: caseSensitive);
    });
  }
}

extension VocabularyProgressDBQueryProperty on QueryBuilder<
    VocabularyProgressDB, VocabularyProgressDB, QQueryProperty> {
  QueryBuilder<VocabularyProgressDB, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VocabularyProgressDB, List<String>, QQueryOperations>
      contextExamplesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contextExamples');
    });
  }

  QueryBuilder<VocabularyProgressDB, int, QQueryOperations>
      correctUsageCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctUsageCount');
    });
  }

  QueryBuilder<VocabularyProgressDB, DateTime, QQueryOperations>
      firstUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstUsed');
    });
  }

  QueryBuilder<VocabularyProgressDB, int, QQueryOperations>
      incorrectUsageCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'incorrectUsageCount');
    });
  }

  QueryBuilder<VocabularyProgressDB, DateTime, QQueryOperations>
      lastUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUsed');
    });
  }

  QueryBuilder<VocabularyProgressDB, String, QQueryOperations> levelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'level');
    });
  }

  QueryBuilder<VocabularyProgressDB, bool, QQueryOperations>
      masteredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mastered');
    });
  }

  QueryBuilder<VocabularyProgressDB, String?, QQueryOperations>
      translationOrMeaningProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'translationOrMeaning');
    });
  }

  QueryBuilder<VocabularyProgressDB, int, QQueryOperations>
      usageCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usageCount');
    });
  }

  QueryBuilder<VocabularyProgressDB, String, QQueryOperations> wordProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'word');
    });
  }
}
