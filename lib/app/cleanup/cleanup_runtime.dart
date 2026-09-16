import 'dart:convert';

import 'package:scanner/src/rust/api/hybrid_search_api.dart';
import 'package:scanner/src/rust/hybrid_search.dart';

import 'cleanup_rule.dart';

const cleanupRulesSyncPrefix = '__cleanup_rules_sync__';
const cleanupCandidatePrefix = '__cleanup_candidate__:';

Future<void> syncCleanupRules(List<CleanupRule> rules) async {
  final backendRules = rules
      .where((rule) => rule.supported && rule.enabled)
      .map((rule) => {
            'id': rule.id,
            'scope': expandCleanupPath(rule.scope),
            'matcherType': rule.matcherType.name,
            'matcherValue': expandCleanupPath(rule.matcherValue),
            'enabled': rule.enabled,
          })
      .toList(growable: false);
  try {
    await hybridSearchSync(
      p: '',
      caseSensitive: false,
      startsWith: const [],
      endsWith: const [],
      includes: const [],
      excludes: [jsonEncode(backendRules)],
      regex: const [cleanupRulesSyncPrefix],
      searchType: SearchType.and,
    );
  } catch (_) {
    // Cleanup suggestions are optional and must not block a normal scan.
  }
}

