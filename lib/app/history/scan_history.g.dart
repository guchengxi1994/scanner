// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_history.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetScanHistoryRecordCollection on Isar {
  IsarCollection<ScanHistoryRecord> get scanHistoryRecords => this.collection();
}

const ScanHistoryRecordSchema = CollectionSchema(
  name: r'ScanHistoryRecord',
  id: 7782184304552915478,
  properties: {
    r'bytes': PropertySchema(
      id: 0,
      name: r'bytes',
      type: IsarType.string,
    ),
    r'completed': PropertySchema(
      id: 1,
      name: r'completed',
      type: IsarType.bool,
    ),
    r'fileCount': PropertySchema(
      id: 2,
      name: r'fileCount',
      type: IsarType.long,
    ),
    r'kind': PropertySchema(
      id: 3,
      name: r'kind',
      type: IsarType.byte,
      enumMap: _ScanHistoryRecordkindEnumValueMap,
    ),
    r'path': PropertySchema(
      id: 4,
      name: r'path',
      type: IsarType.string,
    ),
    r'resultCount': PropertySchema(
      id: 5,
      name: r'resultCount',
      type: IsarType.long,
    ),
    r'startedAt': PropertySchema(
      id: 6,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'taskId': PropertySchema(
      id: 7,
      name: r'taskId',
      type: IsarType.string,
    )
  },
  estimateSize: _scanHistoryRecordEstimateSize,
  serialize: _scanHistoryRecordSerialize,
  deserialize: _scanHistoryRecordDeserialize,
  deserializeProp: _scanHistoryRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'taskId': IndexSchema(
      id: -6391211041487498726,
      name: r'taskId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'taskId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'startedAt': IndexSchema(
      id: 8114395319341636597,
      name: r'startedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _scanHistoryRecordGetId,
  getLinks: _scanHistoryRecordGetLinks,
  attach: _scanHistoryRecordAttach,
  version: '3.3.2',
);

int _scanHistoryRecordEstimateSize(
  ScanHistoryRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bytes.length * 3;
  bytesCount += 3 + object.path.length * 3;
  bytesCount += 3 + object.taskId.length * 3;
  return bytesCount;
}

void _scanHistoryRecordSerialize(
  ScanHistoryRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bytes);
  writer.writeBool(offsets[1], object.completed);
  writer.writeLong(offsets[2], object.fileCount);
  writer.writeByte(offsets[3], object.kind.index);
  writer.writeString(offsets[4], object.path);
  writer.writeLong(offsets[5], object.resultCount);
  writer.writeDateTime(offsets[6], object.startedAt);
  writer.writeString(offsets[7], object.taskId);
}

ScanHistoryRecord _scanHistoryRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ScanHistoryRecord();
  object.bytes = reader.readString(offsets[0]);
  object.completed = reader.readBool(offsets[1]);
  object.fileCount = reader.readLong(offsets[2]);
  object.id = id;
  object.kind =
      _ScanHistoryRecordkindValueEnumMap[reader.readByteOrNull(offsets[3])] ??
          ScanHistoryKind.largeFiles;
  object.path = reader.readString(offsets[4]);
  object.resultCount = reader.readLong(offsets[5]);
  object.startedAt = reader.readDateTime(offsets[6]);
  object.taskId = reader.readString(offsets[7]);
  return object;
}

P _scanHistoryRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (_ScanHistoryRecordkindValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ScanHistoryKind.largeFiles) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ScanHistoryRecordkindEnumValueMap = {
  'largeFiles': 0,
  'duplicates': 1,
};
const _ScanHistoryRecordkindValueEnumMap = {
  0: ScanHistoryKind.largeFiles,
  1: ScanHistoryKind.duplicates,
};

Id _scanHistoryRecordGetId(ScanHistoryRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _scanHistoryRecordGetLinks(
    ScanHistoryRecord object) {
  return [];
}

void _scanHistoryRecordAttach(
    IsarCollection<dynamic> col, Id id, ScanHistoryRecord object) {
  object.id = id;
}

extension ScanHistoryRecordByIndex on IsarCollection<ScanHistoryRecord> {
  Future<ScanHistoryRecord?> getByTaskId(String taskId) {
    return getByIndex(r'taskId', [taskId]);
  }

  ScanHistoryRecord? getByTaskIdSync(String taskId) {
    return getByIndexSync(r'taskId', [taskId]);
  }

  Future<bool> deleteByTaskId(String taskId) {
    return deleteByIndex(r'taskId', [taskId]);
  }

  bool deleteByTaskIdSync(String taskId) {
    return deleteByIndexSync(r'taskId', [taskId]);
  }

  Future<List<ScanHistoryRecord?>> getAllByTaskId(List<String> taskIdValues) {
    final values = taskIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'taskId', values);
  }

  List<ScanHistoryRecord?> getAllByTaskIdSync(List<String> taskIdValues) {
    final values = taskIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'taskId', values);
  }

  Future<int> deleteAllByTaskId(List<String> taskIdValues) {
    final values = taskIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'taskId', values);
  }

  int deleteAllByTaskIdSync(List<String> taskIdValues) {
    final values = taskIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'taskId', values);
  }

  Future<Id> putByTaskId(ScanHistoryRecord object) {
    return putByIndex(r'taskId', object);
  }

  Id putByTaskIdSync(ScanHistoryRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'taskId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTaskId(List<ScanHistoryRecord> objects) {
    return putAllByIndex(r'taskId', objects);
  }

  List<Id> putAllByTaskIdSync(List<ScanHistoryRecord> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'taskId', objects, saveLinks: saveLinks);
  }
}

extension ScanHistoryRecordQueryWhereSort
    on QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QWhere> {
  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterWhere>
      anyStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startedAt'),
      );
    });
  }
}

extension ScanHistoryRecordQueryWhere
    on QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QWhereClause> {
  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterWhereClause>
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

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterWhereClause>
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

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterWhereClause>
      taskIdEqualTo(String taskId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'taskId',
        value: [taskId],
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterWhereClause>
      taskIdNotEqualTo(String taskId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskId',
              lower: [],
              upper: [taskId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskId',
              lower: [taskId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskId',
              lower: [taskId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskId',
              lower: [],
              upper: [taskId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterWhereClause>
      startedAtEqualTo(DateTime startedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'startedAt',
        value: [startedAt],
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterWhereClause>
      startedAtNotEqualTo(DateTime startedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startedAt',
              lower: [],
              upper: [startedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startedAt',
              lower: [startedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startedAt',
              lower: [startedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startedAt',
              lower: [],
              upper: [startedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterWhereClause>
      startedAtGreaterThan(
    DateTime startedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startedAt',
        lower: [startedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterWhereClause>
      startedAtLessThan(
    DateTime startedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startedAt',
        lower: [],
        upper: [startedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterWhereClause>
      startedAtBetween(
    DateTime lowerStartedAt,
    DateTime upperStartedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startedAt',
        lower: [lowerStartedAt],
        includeLower: includeLower,
        upper: [upperStartedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ScanHistoryRecordQueryFilter
    on QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QFilterCondition> {
  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      bytesEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bytes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      bytesGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bytes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      bytesLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bytes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      bytesBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      bytesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bytes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      bytesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bytes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      bytesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bytes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      bytesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bytes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      bytesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bytes',
        value: '',
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      bytesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bytes',
        value: '',
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      completedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completed',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      fileCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      fileCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      fileCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      fileCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
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

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
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

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
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

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      kindEqualTo(ScanHistoryKind value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      kindGreaterThan(
    ScanHistoryKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kind',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      kindLessThan(
    ScanHistoryKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kind',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      kindBetween(
    ScanHistoryKind lower,
    ScanHistoryKind upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kind',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      pathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      pathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      pathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      pathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'path',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      pathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      pathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      pathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'path',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      pathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'path',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      pathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      pathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'path',
        value: '',
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      resultCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resultCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      resultCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'resultCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      resultCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'resultCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      resultCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'resultCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      startedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      startedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      startedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      taskIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      taskIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      taskIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      taskIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      taskIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      taskIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      taskIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'taskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      taskIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'taskId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      taskIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskId',
        value: '',
      ));
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterFilterCondition>
      taskIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'taskId',
        value: '',
      ));
    });
  }
}

extension ScanHistoryRecordQueryObject
    on QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QFilterCondition> {}

extension ScanHistoryRecordQueryLinks
    on QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QFilterCondition> {}

extension ScanHistoryRecordQuerySortBy
    on QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QSortBy> {
  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      sortByBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bytes', Sort.asc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      sortByBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bytes', Sort.desc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      sortByCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completed', Sort.asc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      sortByCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completed', Sort.desc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      sortByFileCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileCount', Sort.asc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      sortByFileCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileCount', Sort.desc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      sortByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      sortByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      sortByResultCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultCount', Sort.asc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      sortByResultCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultCount', Sort.desc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      sortByTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.asc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      sortByTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.desc);
    });
  }
}

extension ScanHistoryRecordQuerySortThenBy
    on QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QSortThenBy> {
  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      thenByBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bytes', Sort.asc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      thenByBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bytes', Sort.desc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      thenByCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completed', Sort.asc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      thenByCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completed', Sort.desc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      thenByFileCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileCount', Sort.asc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      thenByFileCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileCount', Sort.desc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      thenByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      thenByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      thenByResultCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultCount', Sort.asc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      thenByResultCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultCount', Sort.desc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      thenByTaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.asc);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QAfterSortBy>
      thenByTaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskId', Sort.desc);
    });
  }
}

extension ScanHistoryRecordQueryWhereDistinct
    on QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QDistinct> {
  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QDistinct> distinctByBytes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bytes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QDistinct>
      distinctByCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completed');
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QDistinct>
      distinctByFileCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileCount');
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QDistinct>
      distinctByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind');
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QDistinct> distinctByPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'path', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QDistinct>
      distinctByResultCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resultCount');
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QDistinct>
      distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QDistinct>
      distinctByTaskId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskId', caseSensitive: caseSensitive);
    });
  }
}

extension ScanHistoryRecordQueryProperty
    on QueryBuilder<ScanHistoryRecord, ScanHistoryRecord, QQueryProperty> {
  QueryBuilder<ScanHistoryRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ScanHistoryRecord, String, QQueryOperations> bytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bytes');
    });
  }

  QueryBuilder<ScanHistoryRecord, bool, QQueryOperations> completedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completed');
    });
  }

  QueryBuilder<ScanHistoryRecord, int, QQueryOperations> fileCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileCount');
    });
  }

  QueryBuilder<ScanHistoryRecord, ScanHistoryKind, QQueryOperations>
      kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<ScanHistoryRecord, String, QQueryOperations> pathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'path');
    });
  }

  QueryBuilder<ScanHistoryRecord, int, QQueryOperations> resultCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resultCount');
    });
  }

  QueryBuilder<ScanHistoryRecord, DateTime, QQueryOperations>
      startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<ScanHistoryRecord, String, QQueryOperations> taskIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskId');
    });
  }
}
