import 'package:file_selector/file_selector.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanner/app/logger.dart';
import 'package:scanner/src/rust/api/project_api.dart';
import 'package:scanner/src/rust/project.dart';

class ProjectViewState {
  final String path;
  final bool isDone;
  final List<ProjectDetail> details;
  final String? sizeCondition;
  final String? current;

  ProjectViewState(
      {this.path = "",
      this.isDone = false,
      this.details = const [],
      this.sizeCondition,
      this.current});

  ProjectViewState copyWith(
      {String? path,
      bool? isDone,
      List<ProjectDetail>? details,
      String? sizeCondition,
      String? current}) {
    return ProjectViewState(
        path: path ?? this.path,
        isDone: isDone ?? this.isDone,
        details: details ?? this.details,
        sizeCondition: sizeCondition ?? this.sizeCondition,
        current: current ?? this.current);
  }
}

extension Condition on List<ProjectDetail> {
  List<ProjectDetail> getBySizeCondition(String? condition) {
    if (condition == null) {
      return this;
    }

    final p = parseFilesize(condition);
    final result = where((element) => element.size.toInt() > p).toList();
    logger.info("condition: $condition, result: ${result.length}");
    return result;
  }
}

extension ProjectDetailExtension on ProjectViewState {
  List<ProjectDetail> getDetails() {
    return details.getBySizeCondition(sizeCondition);
  }
}

class ProjectViewNotifier extends AutoDisposeNotifier<ProjectViewState> {
  @override
  ProjectViewState build() {
    return ProjectViewState();
  }

  changeCurrent(String s) {
    if (s != "last") {
      state = state.copyWith(current: s);
    } else {
      state = state.copyWith(current: "");
    }
  }

  startScan(TextEditingController controller) async {
    final String? directoryPath = await getDirectoryPath();
    if (directoryPath == null) {
      return;
    }
    refresh();

    controller.text = directoryPath;

    state = state.copyWith(path: directoryPath, isDone: false);
    projectScan(p: directoryPath);
  }

  refresh() {
    state = ProjectViewState();
  }

  refreshWithSizeCondition(String? condition) {
    if (condition == null) {
      return;
    }
    condition = condition.replaceAll(">=", "").trim();
    state = state.copyWith(sizeCondition: condition);
  }

  done() {
    state = state.copyWith(isDone: true);
  }

  addDetails(ProjectDetail d) {
    state = state.copyWith(
        current: d.path,
        details: [...state.details, d],
        isDone: d.count.toInt() == 0 && d.path == "last");
  }

  inspect(String s) {
    refresh();

    state = state.copyWith(path: s, isDone: false);
    projectScan(p: s);
  }
}

final projectViewNotifierProvider =
    AutoDisposeNotifierProvider<ProjectViewNotifier, ProjectViewState>(
        ProjectViewNotifier.new);
