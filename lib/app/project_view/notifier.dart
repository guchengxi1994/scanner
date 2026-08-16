import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanner/src/rust/api/project_api.dart';
import 'package:scanner/src/rust/project.dart';

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
  }) : scannedBytes = scannedBytes ?? BigInt.zero;

  final String path;
  final ProjectViewScanningStatus status;
  final List<ProjectDetail> details;
  final String currentPath;
  final int scannedFiles;
  final BigInt scannedBytes;
  final int completedRoots;
  final int totalRoots;

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
    );
  }
}

class ProjectViewNotifier extends Notifier<ProjectViewState> {
  @override
  ProjectViewState build() => ProjectViewState();

  Future<void> startScan() async {
    if (state.isScanning) return;
    final directoryPath = await getDirectoryPath();
    if (directoryPath == null) return;

    state = ProjectViewState(
      path: directoryPath,
      status: ProjectViewScanningStatus.scanning,
      currentPath: directoryPath,
    );
    projectScan(p: directoryPath);
  }

  void handleEvent(ProjectDetail detail) {
    if (detail.path.startsWith('__scanner_progress__:')) {
      _handleProgress(detail);
      return;
    }

    state = state.copyWith(details: [...state.details, detail]);
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
  }
}

final projectViewNotifierProvider =
    NotifierProvider<ProjectViewNotifier, ProjectViewState>(
        ProjectViewNotifier.new);
