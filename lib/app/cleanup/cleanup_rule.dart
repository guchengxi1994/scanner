import 'dart:io';

enum CleanupPlatform { windows, macos, linux }

enum CleanupRisk { safe, rebuildable, caution, protected }

enum CleanupMatcherType { exactPath, directoryName, pathContains }

enum CleanupActionType { moveToTrash, reportOnly, externalInstructions }

CleanupPlatform get currentCleanupPlatform {
  if (Platform.isWindows) return CleanupPlatform.windows;
  if (Platform.isMacOS) return CleanupPlatform.macos;
  return CleanupPlatform.linux;
}

class CleanupRule {
  const CleanupRule({
    required this.id,
    required this.name,
    required this.description,
    required this.platform,
    required this.scope,
    required this.matcherType,
    required this.matcherValue,
    required this.risk,
    required this.action,
    this.profileId = 'custom',
    this.externalCommand,
    this.enabled = true,
    this.builtIn = false,
    this.defaultSelected = false,
  });

  final String id;
  final String name;
  final String description;
  final CleanupPlatform platform;
  final String scope;
  final CleanupMatcherType matcherType;
  final String matcherValue;
  final CleanupRisk risk;
  final CleanupActionType action;
  final String profileId;
  final String? externalCommand;
  final bool enabled;
  final bool builtIn;
  final bool defaultSelected;

  bool get supported => platform == currentCleanupPlatform;

  CleanupRule copyWith({
    String? name,
    String? description,
    CleanupPlatform? platform,
    String? scope,
    CleanupMatcherType? matcherType,
    String? matcherValue,
    CleanupRisk? risk,
    CleanupActionType? action,
    String? profileId,
    String? externalCommand,
    bool? enabled,
    bool? builtIn,
    bool? defaultSelected,
  }) {
    return CleanupRule(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      platform: platform ?? this.platform,
      scope: scope ?? this.scope,
      matcherType: matcherType ?? this.matcherType,
      matcherValue: matcherValue ?? this.matcherValue,
      risk: risk ?? this.risk,
      action: action ?? this.action,
      profileId: profileId ?? this.profileId,
      externalCommand: externalCommand ?? this.externalCommand,
      enabled: enabled ?? this.enabled,
      builtIn: builtIn ?? this.builtIn,
      defaultSelected: defaultSelected ?? this.defaultSelected,
    );
  }

  Map<String, Object> toJson() {
    final command = externalCommand;
    return {
      'id': id,
      'name': name,
      'description': description,
      'platform': platform.name,
      'scope': scope,
      'matcherType': matcherType.name,
      'matcherValue': matcherValue,
      'risk': risk.name,
      'action': action.name,
      'profileId': profileId,
      if (command != null) 'externalCommand': command,
      'enabled': enabled,
      'builtIn': builtIn,
      'defaultSelected': defaultSelected,
    };
  }

  factory CleanupRule.fromJson(Map<String, dynamic> json) {
    return CleanupRule(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      platform: CleanupPlatform.values.byName(json['platform'] as String),
      scope: json['scope'] as String,
      matcherType: CleanupMatcherType.values.byName(
        json['matcherType'] as String,
      ),
      matcherValue: json['matcherValue'] as String,
      risk: CleanupRisk.values.byName(json['risk'] as String),
      action: CleanupActionType.values.byName(json['action'] as String),
      profileId: json['profileId'] as String? ?? 'custom',
      externalCommand: json['externalCommand'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      builtIn: json['builtIn'] as bool? ?? false,
      defaultSelected: json['defaultSelected'] as bool? ?? false,
    );
  }
}

class CleanupCandidate {
  const CleanupCandidate({
    required this.rule,
    required this.path,
    required this.size,
    required this.itemCount,
  });

  final CleanupRule rule;
  final String path;
  final BigInt size;
  final BigInt itemCount;

  bool get canExecute =>
      rule.supported &&
      rule.action == CleanupActionType.moveToTrash &&
      rule.risk == CleanupRisk.safe;
}

String expandCleanupPath(String value) {
  var path = value;
  final variables = <String, String>{
    '%TEMP%': Platform.environment['TEMP'] ?? '',
    '%TMP%': Platform.environment['TMP'] ?? '',
    '%LOCALAPPDATA%': Platform.environment['LOCALAPPDATA'] ?? '',
    '%APPDATA%': Platform.environment['APPDATA'] ?? '',
    '%USERPROFILE%': Platform.environment['USERPROFILE'] ?? '',
    '%HOME%': Platform.environment['HOME'] ?? '',
    r'$HOME': Platform.environment['HOME'] ?? '',
  };
  for (final entry in variables.entries) {
    if (entry.value.isNotEmpty) path = path.replaceAll(entry.key, entry.value);
  }
  return path;
}

String normalizeCleanupPath(String value) {
  final normalized = value
      .replaceAll('\\', '/')
      .replaceAll(RegExp(r'/+'), '/')
      .replaceFirst(RegExp(r'/$'), '');
  return currentCleanupPlatform == CleanupPlatform.linux
      ? normalized
      : normalized.toLowerCase();
}

bool cleanupRuleMatches(CleanupRule rule, String candidatePath) {
  if (!rule.enabled || !rule.supported) return false;
  final candidate = normalizeCleanupPath(candidatePath);
  final scope = normalizeCleanupPath(expandCleanupPath(rule.scope));
  if (scope.isNotEmpty &&
      candidate != scope &&
      !candidate.startsWith('$scope/')) {
    return false;
  }

  final value = normalizeCleanupPath(expandCleanupPath(rule.matcherValue));
  switch (rule.matcherType) {
    case CleanupMatcherType.exactPath:
      return candidate == value;
    case CleanupMatcherType.directoryName:
      return candidate.split('/').last == value;
    case CleanupMatcherType.pathContains:
      return candidate.contains(value);
  }
}

String cleanupRiskLabel(CleanupRisk risk) {
  return switch (risk) {
    CleanupRisk.safe => '安全缓存',
    CleanupRisk.rebuildable => '可重建',
    CleanupRisk.caution => '谨慎处理',
    CleanupRisk.protected => '受保护',
  };
}

String cleanupPlatformLabel(CleanupPlatform platform) {
  return switch (platform) {
    CleanupPlatform.windows => 'Windows',
    CleanupPlatform.macos => 'macOS',
    CleanupPlatform.linux => 'Linux',
  };
}

String cleanupActionLabel(CleanupActionType action) {
  return switch (action) {
    CleanupActionType.moveToTrash => '移到回收站',
    CleanupActionType.reportOnly => '仅显示建议',
    CleanupActionType.externalInstructions => '显示命令并允许执行',
  };
}
