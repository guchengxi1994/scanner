// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.2.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'file.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

class CompareResult {
  final BigInt index;
  final BigInt fileSize;
  final List<List<File>> allSameFiles;
  final BigInt count;

  const CompareResult({
    required this.index,
    required this.fileSize,
    required this.allSameFiles,
    required this.count,
  });

  @override
  int get hashCode =>
      index.hashCode ^
      fileSize.hashCode ^
      allSameFiles.hashCode ^
      count.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompareResult &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          fileSize == other.fileSize &&
          allSameFiles == other.allSameFiles &&
          count == other.count;
}

class CompareResults {
  final List<CompareResult> field0;

  const CompareResults({
    required this.field0,
  });

  @override
  int get hashCode => field0.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompareResults &&
          runtimeType == other.runtimeType &&
          field0 == other.field0;
}
