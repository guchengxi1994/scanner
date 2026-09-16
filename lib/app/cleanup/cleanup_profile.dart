import 'cleanup_rule.dart';

class CleanupProfile {
  const CleanupProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.platform,
  });

  final String id;
  final String name;
  final String description;
  final CleanupPlatform platform;

  bool get supported => platform == currentCleanupPlatform;
}

const builtinCleanupProfiles = <CleanupProfile>[
  CleanupProfile(
    id: 'windows-system',
    name: '系统临时文件',
    description: '清理系统和应用生成的可重建临时文件。',
    platform: CleanupPlatform.windows,
  ),
  CleanupProfile(
    id: 'windows-development',
    name: '开发工具缓存',
    description: '清理 npm、VS Code 等开发工具缓存。',
    platform: CleanupPlatform.windows,
  ),
  CleanupProfile(
    id: 'macos-user-cache',
    name: 'macOS 用户缓存',
    description: '仅展示用户缓存，暂不自动执行。',
    platform: CleanupPlatform.macos,
  ),
  CleanupProfile(
    id: 'linux-user-cache',
    name: 'Linux 用户缓存',
    description: '仅展示用户缓存，暂不自动执行。',
    platform: CleanupPlatform.linux,
  ),
];
