// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.5.1.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'public.dart';

Future<void> openFile({required String s}) =>
    RustLib.instance.api.crateApiToolsApiOpenFile(s: s);

Future<void> openFolder({required String s}) =>
    RustLib.instance.api.crateApiToolsApiOpenFolder(s: s);

Future<OperationResult> removeFile({required String s}) =>
    RustLib.instance.api.crateApiToolsApiRemoveFile(s: s);
