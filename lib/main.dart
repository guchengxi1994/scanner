import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scanner/src/rust/frb_generated.dart';
import 'package:logging/logging.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    }
  });

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1440, 860),
    minimumSize: Size(1080, 680),
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
  );

  await windowManager.setMaximizable(true);
  await windowManager.setMinimizable(true);

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}
