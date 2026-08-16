import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppPackageInfo {
  const AppPackageInfo({required this.appName, required this.version});

  final String appName;
  final String version;
}

const fallbackPackageInfo = AppPackageInfo(
  appName: '大文件/重复文件扫描工具',
  version: '3.0.0',
);

final appPackageInfoProvider = FutureProvider<AppPackageInfo>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return AppPackageInfo(
      appName: info.appName.trim().isEmpty
          ? fallbackPackageInfo.appName
          : info.appName,
      version: info.version.trim().isEmpty
          ? fallbackPackageInfo.version
          : info.version,
    );
  } catch (_) {
    return fallbackPackageInfo;
  }
});
