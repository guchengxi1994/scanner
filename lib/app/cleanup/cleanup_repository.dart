import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'builtin_cleanup_rules.dart';
import 'cleanup_profile.dart';
import 'cleanup_rule.dart';
import '../storage/app_storage.dart';

class CleanupRulesNotifier extends Notifier<List<CleanupRule>> {
  Future<void>? _loadFuture;
  bool _hasLocalChanges = false;

  @override
  List<CleanupRule> build() {
    _loadFuture = _load();
    return builtinCleanupRules;
  }

  Future<List<CleanupRule>> ensureLoaded() async {
    await _loadFuture;
    return state;
  }

  void setEnabled(String id, bool enabled) {
    _hasLocalChanges = true;
    state = [
      for (final rule in state)
        rule.id == id ? rule.copyWith(enabled: enabled) : rule,
    ];
    unawaited(_persist());
  }

  void add(CleanupRule rule) {
    if (state.any((item) => item.id == rule.id)) return;
    _hasLocalChanges = true;
    state = [...state, rule.copyWith(builtIn: false)];
    unawaited(_persist());
  }

  void remove(String id) {
    final matches = state.where((rule) => rule.id == id);
    if (matches.isEmpty || matches.first.builtIn) return;
    _hasLocalChanges = true;
    state = state.where((rule) => rule.id != id).toList(growable: false);
    unawaited(_persist());
  }

  void setProfileEnabled(String profileId, bool enabled) {
    var changed = false;
    final next = state.map((rule) {
      if (rule.profileId != profileId || !rule.supported || rule.enabled == enabled) {
        return rule;
      }
      changed = true;
      return rule.copyWith(enabled: enabled);
    }).toList(growable: false);
    if (!changed) return;
    _hasLocalChanges = true;
    state = next;
    unawaited(_persist());
  }

  Future<void> _load() async {
    try {
      final file = await _settingsFile();
      if (!await file.exists() || _hasLocalChanges) return;
      final raw = jsonDecode(await file.readAsString());
      if (raw is! List) return;
      final stored = raw
          .whereType<Map<String, dynamic>>()
          .map(CleanupRule.fromJson)
          .toList(growable: false);
      final overrides = {for (final rule in stored) rule.id: rule};
      final builtins = builtinCleanupRules.map((rule) {
        final storedRule = overrides[rule.id];
        if (storedRule == null) return rule;
        // Built-in definitions are application-owned. Retain only the
        // user's toggle so safety and platform metadata can be upgraded.
        return rule.copyWith(enabled: storedRule.enabled, builtIn: true);
      });
      final custom = stored.where((rule) => !rule.builtIn);
      if (!_hasLocalChanges) state = [...builtins, ...custom];
    } catch (_) {
      // Built-in rules remain available if local settings are invalid.
    }
  }

  Future<void> _persist() async {
    try {
      final file = await _settingsFile();
      await file.writeAsString(
        jsonEncode(state.map((rule) => rule.toJson()).toList()),
      );
    } catch (_) {
      // A settings failure must not interrupt scanning.
    }
  }

  Future<File> _settingsFile() async {
    return appDataFile('cleanup-rules.json');
  }
}

final cleanupRulesProvider =
    NotifierProvider<CleanupRulesNotifier, List<CleanupRule>>(
  CleanupRulesNotifier.new,
);
