import 'package:scanner/src/rust/api/scanner_api.dart';
import 'package:scanner/src/rust/scanner/compare_result.dart';
import 'package:scanner/src/rust/scanner/event.dart';
import 'package:scanner/src/rust/scanner/file.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notifier_state.dart';

class ScannerNotifier extends Notifier<ScannerState> {
  @override
  ScannerState build() {
    return const ScannerState();
  }

  double get progress => state.totalFileCount == 0
      ? 0
      : state.comparedFileCount / state.totalFileCount;

  void refresh() {
    state = state.copyWith(
        compareResults: [],
        stage: "",
        path: "",
        scanning: false,
        totalFileCount: 0,
        comparedFileCount: 0);
  }

  void done() {
    state = state.copyWith(scanning: false);
  }

  Future<void> startScan() async {
    if (state.scanning) return;
    refresh();
    final String? directoryPath = await getDirectoryPath();
    if (directoryPath == null) {
      return;
    }

    state = state.copyWith(
        path: directoryPath, scanning: true, compareResults: [], results: []);
    scan(p: directoryPath);
  }

  void changeAsc() {
    bool b = !state.asc;
    if (b) {
      state = state.copyWith(
          asc: b,
          results: state.results
            ..sort((a, b) => a.fileSize.compareTo(b.fileSize)));
    } else {
      state = state.copyWith(
          asc: b,
          results: state.results
            ..sort((a, b) => -a.fileSize.compareTo(b.fileSize)));
    }
  }

  void refreshList() {
    state = state.copyWith(
        asc: true,
        results: state.results..sort((a, b) => a.index.compareTo(b.index)));
  }

  void changeShowAll() {
    bool b = !state.showAll;

    if (b) {
      state = state.copyWith(results: state.compareResults, showAll: b);
      return;
    } else {
      state = state.copyWith(
          showAll: b,
          results: state.results.where((v) {
            for (final i in v.allSameFiles) {
              if (i.length > 1) {
                return true;
              }
            }
            return false;
          }).toList());
    }
  }

  void changeStage(ResEvent s) {
    if (s is ResEvent_ScannerEvent) {
      state = state.copyWith(
        totalFileCount: s.field0.count.toInt(),
        stage: s.field0.eventType,
      );
    } else if (s is ResEvent_CompareEvent) {
      state = state.copyWith(stage: '正在验证文件内容');
    } else if (s is ResEvent_DoneEvent) {
      done();
    }
  }

  void addItem(CompareResult result) {
    final nextResults = [...state.compareResults, result];
    state = state.copyWith(
        compareResults: nextResults,
        results: nextResults,
        showAll: true,
        asc: true,
        comparedFileCount: state.comparedFileCount + result.count.toInt());
  }

  void updateCompareResult(CompareResult result) {
    state = state.copyWith(
        compareResults: state.compareResults
            .map((e) => e.index == result.index ? result : e)
            .toList(),
        results: state.results
            .map((e) => e.index == result.index ? result : e)
            .toList());
  }

  void removeFileFromList(BigInt resultId, File s) {
    final result = state.compareResults.firstWhere((e) => e.index == resultId);

    final c = CompareResult(
        index: result.index,
        fileSize: result.fileSize,
        allSameFiles: result.allSameFiles
            .map((v) => v.where((e) => e.path != s.path).toList())
            .toList(),
        count: result.count);

    state = state.copyWith(
        compareResults: state.compareResults
            .map((e) => e.index == resultId ? c : e)
            .toList(),
        results:
            state.results.map((e) => e.index == resultId ? c : e).toList());
  }
}

final scannerNotifierProvider =
    NotifierProvider<ScannerNotifier, ScannerState>(ScannerNotifier.new);
