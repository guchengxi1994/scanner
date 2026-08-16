import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'scan_rule_runtime.dart';

enum ScanExclusionKind { directory, glob, regex }

class ScanExclusionRule {
  const ScanExclusionRule({
    required this.id,
    required this.kind,
    required this.pattern,
  });

  final String id;
  final ScanExclusionKind kind;
  final String pattern;

  String get backendValue => '${kind.name}:$pattern';

  Map<String, String> toJson() => {
        'id': id,
        'kind': kind.name,
        'pattern': pattern,
      };

  factory ScanExclusionRule.fromJson(Map<String, dynamic> json) {
    return ScanExclusionRule(
      id: json['id'] as String,
      kind: ScanExclusionKind.values.byName(json['kind'] as String),
      pattern: json['pattern'] as String,
    );
  }
}

const _defaultRules = [
  ScanExclusionRule(
    id: 'default-git',
    kind: ScanExclusionKind.directory,
    pattern: '.git',
  ),
  ScanExclusionRule(
    id: 'default-node-modules',
    kind: ScanExclusionKind.directory,
    pattern: 'node_modules',
  ),
  ScanExclusionRule(
    id: 'default-system-volume-information',
    kind: ScanExclusionKind.directory,
    pattern: 'System Volume Information',
  ),
];

class ScanExclusionsNotifier extends Notifier<List<ScanExclusionRule>> {
  Future<void>? _loadFuture;
  bool _hasLocalChanges = false;

  @override
  List<ScanExclusionRule> build() {
    _loadFuture = _load();
    unawaited(_syncRules(_defaultRules));
    return _defaultRules;
  }

  Future<List<ScanExclusionRule>> ensureLoaded() async {
    await _loadFuture;
    return state;
  }

  void add(ScanExclusionKind kind, String rawPattern) {
    final pattern = rawPattern.trim();
    if (pattern.isEmpty ||
        state.any((rule) => rule.kind == kind && rule.pattern == pattern)) {
      return;
    }
    _hasLocalChanges = true;
    state = [
      ...state,
      ScanExclusionRule(
        id: '${kind.name}-${DateTime.now().microsecondsSinceEpoch}',
        kind: kind,
        pattern: pattern,
      ),
    ];
    unawaited(_persist());
    unawaited(_syncRules(state));
  }

  void remove(String id) {
    _hasLocalChanges = true;
    state = state.where((rule) => rule.id != id).toList();
    unawaited(_persist());
    unawaited(_syncRules(state));
  }

  Future<void> _load() async {
    try {
      final file = await _settingsFile();
      if (!await file.exists() || _hasLocalChanges) return;
      final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
      final rules = raw
          .whereType<Map<String, dynamic>>()
          .map(ScanExclusionRule.fromJson)
          .where((rule) => rule.pattern.isNotEmpty)
          .toList();
      if (!_hasLocalChanges) {
        state = rules;
        await _syncRules(rules);
      }
    } catch (_) {
      // Defaults remain usable when local preferences cannot be read.
    }
  }

  Future<void> _persist() async {
    try {
      final file = await _settingsFile();
      await file.writeAsString(
        jsonEncode(state.map((rule) => rule.toJson()).toList()),
      );
    } catch (_) {
      // A persistence failure must not block the next scan.
    }
  }

  Future<void> _syncRules(List<ScanExclusionRule> rules) {
    return syncScanExclusions(
      rules.map((rule) => rule.backendValue).toList(),
    );
  }

  Future<File> _settingsFile() async {
    final root = Platform.environment['LOCALAPPDATA'] ?? Directory.current.path;
    final folder = Directory('$root${Platform.pathSeparator}LargeFileScanner');
    if (!await folder.exists()) await folder.create(recursive: true);
    return File('${folder.path}${Platform.pathSeparator}scan-exclusions.json');
  }
}

final scanExclusionsProvider =
    NotifierProvider<ScanExclusionsNotifier, List<ScanExclusionRule>>(
  ScanExclusionsNotifier.new,
);
