import 'dart:async';
import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanner/src/rust/api/project_api.dart';
import 'package:scanner/src/rust/project.dart';

import '../cleanup/cleanup_repository.dart';
import '../cleanup/cleanup_rule.dart';
import '../cleanup/cleanup_runtime.dart';
import '../history/scan_history.dart';
import '../settings/scan_exclusions.dart';
import '../settings/scan_rule_runtime.dart';

enum ProjectViewScanningStatus { idle, scanning, completed }

class ProjectViewState {
  ProjectViewState({
    this.path = '',
    this.status = ProjectViewScanningStatus.idle,
    this.details = const [],
    this.currentPath = '',
    this.scannedFiles = 0,
    BigInt? scannedBytes,
    this.completedRoots = 0,
    this.totalRoots = 0,
    this.cleanupCandidates = const [],
    this.historyId,
    this.error,
  }) : scannedBytes = scannedBytes ?? BigInt.zero;

  final String path;
  final ProjectViewScanningStatus status;
  final List<ProjectDetail> details;
  final String currentPath;
  final int scannedFiles;
  final BigInt scannedBytes;
  final int completedRoots;
  final int totalRoots;
  final List<CleanupCandidate> cleanupCandidates;
  final String? historyId;
  final String? error;

  bool get isScanning => status == ProjectViewScanningStatus.scanning;
  bool get hasCompleted => status == ProjectViewScanningStatus.completed;

  ProjectViewState copyWith({
    String? path,
    ProjectViewScanningStatus? status,
    List<ProjectDetail>? details,
    String? currentPath,
    int? scannedFiles,
    BigInt? scannedBytes,
    int? completedRoots,
    int? totalRoots,
    List<CleanupCandidate>? cleanupCandidates,
    String? historyId,
    String? error,
  }) {
    return ProjectViewState(
      path: path ?? this.path,
      status: status ?? this.status,
      details: details ?? this.details,
      currentPath: currentPath ?? this.currentPath,
      scannedFiles: scannedFiles ?? this.scannedFiles,
      scannedBytes: scannedBytes ?? this.scannedBytes,
      completedRoots: completedRoots ?? this.completedRoots,
      totalRoots: totalRoots ?? this.totalRoots,
      cleanupCandidates: cleanupCandidates ?? this.cleanupCandidates,
      historyId: historyId ?? this.historyId,
      error: error ?? this.error,
    );
  }
}

class ProjectViewNotifier extends Notifier<ProjectViewState> {
  @override
  ProjectViewState build() {
    ref.listen<List<CleanupRule>>(cleanupRulesProvider, (_, __) {
      _refreshCandidates(state.details);
    });
    return ProjectViewState();
  }

  Future<void> startScan() async {
    if (state.isScanning) return;
    final directoryPath = await getDirectoryPath();
    if (directoryPath == null) return;
    final exclusions =
        await ref.read(scanExclusionsProvider.notifier).ensureLoaded();
    await syncScanExclusions(
        exclusions.map((rule) => rule.backendValue).toList());
    final cleanupRules =
        await ref.read(cleanupRulesProvider.notifier).ensureLoaded();
    await syncCleanupRules(cleanupRules);

    final historyId = ref.read(scanHistoryProvider.notifier).start(
          ScanHistoryKind.largeFiles,
          directoryPath,
        );
    state = ProjectViewState(
      path: directoryPath,
      status: ProjectViewScanningStatus.scanning,
      currentPath: directoryPath,
      cleanupCandidates: const [],
      historyId: historyId,
      error: null,
    );
    unawaited(_runScan(directoryPath));
  }

  Future<void> _runScan(String directoryPath) async {
    try {
      await projectScan(p: directoryPath);
    } catch (error) {
      _handleError(error.toString());
    }
  }

  void handleEvent(ProjectDetail detail) {
    if (detail.path.startsWith(cleanupCandidatePrefix)) {
      _handleCleanupCandidate(detail);
      return;
    }
    if (detail.path.startsWith('__scanner_progress__:')) {
      _handleProgress(detail);
      return;
    }
    if (detail.path.startsWith('__scanner_error__:')) {
      _handleError(detail.path.substring('__scanner_error__:'.length));
      return;
    }

    final details = [...state.details, detail];
    final candidates = [
      ...state.cleanupCandidates,
      ..._candidatesFor(details),
    ];
    final uniqueCandidates = <String, CleanupCandidate>{
      for (final candidate in candidates)
        '${candidate.rule.id}:${candidate.path}': candidate,
    };
    state = state.copyWith(
      details: details,
      cleanupCandidates: uniqueCandidates.values.toList()
        ..sort((left, right) => right.size.compareTo(left.size)),
    );
  }

  void _handleCleanupCandidate(ProjectDetail detail) {
    try {
      final payload = jsonDecode(
        detail.path.substring(cleanupCandidatePrefix.length),
      );
      if (payload is! Map<String, dynamic>) return;
      final ruleId = payload['ruleId'] as String?;
      final path = payload['path'] as String?;
      if (ruleId == null || path == null) return;
      final matchingRules =
          ref.read(cleanupRulesProvider).where((item) => item.id == ruleId);
      final rule = matchingRules.isEmpty ? null : matchingRules.first;
      if (rule == null || state.cleanupCandidates.any(
            (candidate) =>
                candidate.path == path && candidate.rule.id == rule.id,
          )) {
        return;
      }
      state = state.copyWith(
        cleanupCandidates: [
          ...state.cleanupCandidates,
          CleanupCandidate(
            rule: rule,
            path: path,
            size: detail.size,
            itemCount: detail.count,
          ),
        ]..sort((left, right) => right.size.compareTo(left.size)),
      );
    } catch (_) {
      // Optional cleanup events must not interrupt the scan.
    }
  }

  List<CleanupCandidate> _candidatesFor(List<ProjectDetail> details) {
    final rules = ref.read(cleanupRulesProvider);
    final candidates = <CleanupCandidate>[];
    for (final detail in details) {
      for (final rule in rules) {
        if (!cleanupRuleMatches(rule, detail.path)) continue;
        if (candidates.any((candidate) =>
            candidate.path == detail.path && candidate.rule.id == rule.id)) {
          continue;
        }
        candidates.add(
          CleanupCandidate(
            rule: rule,
            path: detail.path,
            size: detail.size,
            itemCount: detail.count,
          ),
        );
      }
    }
    candidates.sort((left, right) => right.size.compareTo(left.size));
    return candidates;
  }

  void _refreshCandidates(List<ProjectDetail> details) {
    state = state.copyWith(cleanupCandidates: _candidatesFor(details));
  }

  void removeCleanupCandidate(String path) {
    state = state.copyWith(
      cleanupCandidates: state.cleanupCandidates
          .where((candidate) => candidate.path != path)
          .toList(growable: false),
      details: state.details
          .where((detail) => detail.path != path)
          .toList(growable: false),
    );
  }

  void _handleProgress(ProjectDetail detail) {
    final pieces = detail.path.split(':');
    if (pieces.length < 5) return;

    final completed = int.tryParse(pieces[1]) ?? state.completedRoots;
    final total = int.tryParse(pieces[2]) ?? state.totalRoots;
    final done = pieces[3] == 'true';
    final currentPath = pieces.sublist(4).join(':');
    state = state.copyWith(
      status: done
          ? ProjectViewScanningStatus.completed
          : ProjectViewScanningStatus.scanning,
      currentPath: currentPath,
      scannedFiles: detail.count.toInt(),
      scannedBytes: detail.size,
      completedRoots: completed,
      totalRoots: total,
    );
    if (done && state.historyId != null) {
      ref.read(scanHistoryProvider.notifier).complete(
            state.historyId!,
            fileCount: state.scannedFiles,
            bytes: state.scannedBytes,
            resultCount: state.details.length,
          );
    }
  }

  void _handleError(String message) {
    if (state.historyId != null) {
      ref.read(scanHistoryProvider.notifier).markInterrupted(state.historyId!);
    }
    state = state.copyWith(
      status: ProjectViewScanningStatus.idle,
      currentPath: message,
      error: message,
    );
  }
}

final projectViewNotifierProvider =
    NotifierProvider<ProjectViewNotifier, ProjectViewState>(
        ProjectViewNotifier.new);
