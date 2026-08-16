import 'package:scanner/src/rust/api/hybrid_search_api.dart';
import 'package:scanner/src/rust/hybrid_search.dart';

const _scanExclusionsSyncPrefix = '__scanner_exclusions_sync__';

Future<void> syncScanExclusions(List<String> encodedRules) async {
  try {
    await hybridSearchSync(
      p: '',
      caseSensitive: false,
      startsWith: const [],
      endsWith: const [],
      includes: const [],
      excludes: encodedRules,
      regex: const [_scanExclusionsSyncPrefix],
      searchType: SearchType.and,
    );
  } catch (_) {
    // Scans remain available when the native library is still restarting.
  }
}
