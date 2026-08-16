import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

part 'scan_history.g.dart';

enum ScanHistoryKind { largeFiles, duplicates }

class ScanHistoryItem {
  ScanHistoryItem({
    required this.id,
    required this.kind,
    required this.path,
    required this.startedAt,
    required this.completed,
    this.fileCount = 0,
    BigInt? bytes,
    this.resultCount = 0,
  }) : bytes = bytes ?? BigInt.zero;

  final String id;
  final ScanHistoryKind kind;
  final String path;
  final DateTime startedAt;
  final bool completed;
  final int fileCount;
  final BigInt bytes;
  final int resultCount;

  ScanHistoryItem copyWith({
    bool? completed,
    int? fileCount,
    BigInt? bytes,
    int? resultCount,
  }) {
    return ScanHistoryItem(
      id: id,
      kind: kind,
      path: path,
      startedAt: startedAt,
      completed: completed ?? this.completed,
      fileCount: fileCount ?? this.fileCount,
      bytes: bytes ?? this.bytes,
      resultCount: resultCount ?? this.resultCount,
    );
  }

  Map<String, Object> toJson() => {
        'id': id,
        'kind': kind.name,
        'path': path,
        'startedAt': startedAt.toIso8601String(),
        'completed': completed,
        'fileCount': fileCount,
        'bytes': bytes.toString(),
        'resultCount': resultCount,
      };

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      id: json['id'] as String,
      kind: ScanHistoryKind.values.byName(json['kind'] as String),
      path: json['path'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completed: json['completed'] as bool? ?? false,
      fileCount: json['fileCount'] as int? ?? 0,
      bytes: BigInt.tryParse(json['bytes'] as String? ?? '0') ?? BigInt.zero,
      resultCount: json['resultCount'] as int? ?? 0,
    );
  }
}

@collection
class ScanHistoryRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String taskId;

  @enumerated
  late ScanHistoryKind kind;

  late String path;

  @Index()
  late DateTime startedAt;

  late bool completed;
  late int fileCount;
  late String bytes;
  late int resultCount;

  ScanHistoryItem toItem() => ScanHistoryItem(
        id: taskId,
        kind: kind,
        path: path,
        startedAt: startedAt,
        completed: completed,
        fileCount: fileCount,
        bytes: BigInt.tryParse(bytes) ?? BigInt.zero,
        resultCount: resultCount,
      );

  static ScanHistoryRecord fromItem(ScanHistoryItem item) {
    return ScanHistoryRecord()
      ..taskId = item.id
      ..kind = item.kind
      ..path = item.path
      ..startedAt = item.startedAt
      ..completed = item.completed
      ..fileCount = item.fileCount
      ..bytes = item.bytes.toString()
      ..resultCount = item.resultCount;
  }
}

class ScanHistoryNotifier extends Notifier<List<ScanHistoryItem>> {
  Isar? _database;

  @override
  List<ScanHistoryItem> build() {
    unawaited(_load());
    return const [];
  }

  String start(ScanHistoryKind kind, String path) {
    final item = ScanHistoryItem(
      id: '${kind.name}-${DateTime.now().microsecondsSinceEpoch}',
      kind: kind,
      path: path,
      startedAt: DateTime.now(),
      completed: false,
    );
    state = _sorted([item, ...state]).take(30).toList();
    unawaited(_upsert(item));
    return item.id;
  }

  void complete(
    String id, {
    required int fileCount,
    required BigInt bytes,
    required int resultCount,
  }) {
    ScanHistoryItem? completedItem;
    state = state.map((item) {
      if (item.id != id) return item;
      completedItem = item.copyWith(
        completed: true,
        fileCount: fileCount,
        bytes: bytes,
        resultCount: resultCount,
      );
      return completedItem!;
    }).toList();
    if (completedItem != null) unawaited(_upsert(completedItem!));
  }

  Future<void> _load() async {
    try {
      final database = await _getDatabase();
      final stored = await database.scanHistoryRecords
          .where()
          .sortByStartedAtDesc()
          .findAll();
      final merged = <String, ScanHistoryItem>{
        for (final item in stored) item.taskId: item.toItem(),
        for (final item in state) item.id: item,
      };
      state = _sorted(merged.values).take(30).toList();
    } catch (_) {
      // A history database error should never block a scan.
    }
  }

  Future<void> _upsert(ScanHistoryItem item) async {
    try {
      final database = await _getDatabase();
      await database.writeTxn(() async {
        await database.scanHistoryRecords.put(ScanHistoryRecord.fromItem(item));
      });
    } catch (_) {
      // The scan result remains usable even if local history cannot be saved.
    }
  }

  Future<Isar> _getDatabase() async {
    if (_database != null) return _database!;
    final root = Platform.environment['LOCALAPPDATA'] ?? Directory.current.path;
    final folder = Directory('$root${Platform.pathSeparator}LargeFileScanner');
    if (!await folder.exists()) await folder.create(recursive: true);
    _database = await Isar.open(
      [ScanHistoryRecordSchema],
      directory: folder.path,
      name: 'scan_history',
      inspector: false,
    );
    return _database!;
  }

  List<ScanHistoryItem> _sorted(Iterable<ScanHistoryItem> items) {
    final sorted = items.toList()
      ..sort((left, right) => right.startedAt.compareTo(left.startedAt));
    return sorted;
  }
}

final scanHistoryProvider =
    NotifierProvider<ScanHistoryNotifier, List<ScanHistoryItem>>(
  ScanHistoryNotifier.new,
);
