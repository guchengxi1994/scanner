import 'dart:io';

/// Returns the platform-appropriate directory for app-owned local data.
///
/// The directory is created lazily so callers can use this for settings and
/// Isar without duplicating platform-specific path rules.
Future<Directory> appDataDirectory() async {
  final String root;
  if (Platform.isWindows) {
    root = Platform.environment['LOCALAPPDATA'] ??
        Platform.environment['APPDATA'] ??
        Directory.current.path;
  } else if (Platform.isMacOS) {
    root = '${Platform.environment['HOME'] ?? Directory.current.path}'
        '${Platform.pathSeparator}Library${Platform.pathSeparator}Application Support';
  } else {
    root = Platform.environment['XDG_CONFIG_HOME'] ??
        '${Platform.environment['HOME'] ?? Directory.current.path}'
            '${Platform.pathSeparator}.config';
  }

  final directory = Directory(
    '$root${Platform.pathSeparator}LargeFileScanner',
  );
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  return directory;
}

Future<File> appDataFile(String fileName) async {
  final directory = await appDataDirectory();
  return File('${directory.path}${Platform.pathSeparator}$fileName');
}
