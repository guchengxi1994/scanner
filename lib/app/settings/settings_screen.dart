import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../navigation.dart';
import '../ui/app_ui.dart';
import 'scan_exclusions.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _showPaths = true;
  bool _confirmTrash = true;

  Future<void> _addExclusionRule() async {
    final controller = TextEditingController();
    var kind = ScanExclusionKind.directory;
    final result = await showDialog<_NewExclusionRule>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('添加排除规则'),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<ScanExclusionKind>(
                  segments: const [
                    ButtonSegment(
                      value: ScanExclusionKind.directory,
                      label: Text('目录名'),
                      icon: Icon(Icons.folder_outlined),
                    ),
                    ButtonSegment(
                      value: ScanExclusionKind.glob,
                      label: Text('通配符'),
                      icon: Icon(Icons.data_object_outlined),
                    ),
                    ButtonSegment(
                      value: ScanExclusionKind.regex,
                      label: Text('正则'),
                      icon: Icon(Icons.code_outlined),
                    ),
                  ],
                  selected: {kind},
                  onSelectionChanged: (selected) => setDialogState(
                    () => kind = selected.first,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      Navigator.of(dialogContext).pop(
                        _NewExclusionRule(kind, value.trim()),
                      );
                    }
                  },
                  decoration: InputDecoration(
                    labelText: '规则',
                    hintText: _ruleHint(kind),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final pattern = controller.text.trim();
                if (pattern.isEmpty) return;
                Navigator.of(dialogContext).pop(
                  _NewExclusionRule(kind, pattern),
                );
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (result == null || !mounted) return;
    ref.read(scanExclusionsProvider.notifier).add(result.kind, result.pattern);
  }

  @override
  Widget build(BuildContext context) {
    final exclusions = ref.watch(scanExclusionsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 28, 30, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeading(title: '设置', subtitle: '扫描、显示和文件操作偏好'),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                const SectionTitle(title: '扫描策略'),
                const SizedBox(height: 10),
                const SurfacePanel(
                  child: Column(
                    children: [
                      _SettingInfo(
                        icon: Icons.account_tree_outlined,
                        title: '大文件夹统计',
                        detail: '单次遍历后按一级目录聚合，进度最多每 200ms 更新一次。',
                      ),
                      Divider(height: 28, color: AppColors.line),
                      _SettingInfo(
                        icon: Icons.fingerprint_outlined,
                        title: '重复文件验证',
                        detail: '先比对尺寸与前后 64KB 采样指纹，再读取完整内容计算 SHA-256。',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle(title: '显示与文件操作'),
                const SizedBox(height: 10),
                SurfacePanel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 17, vertical: 5),
                        value: _showPaths,
                        onChanged: (value) =>
                            setState(() => _showPaths = value),
                        title: const Text('显示完整路径',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: const Text('在扫描结果中保留文件的完整位置。',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.muted)),
                      ),
                      const Divider(height: 1, color: AppColors.line),
                      SwitchListTile.adaptive(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 17, vertical: 5),
                        value: _confirmTrash,
                        onChanged: (value) =>
                            setState(() => _confirmTrash = value),
                        title: const Text('删除前确认',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: const Text('将文件移到系统回收站前显示确认步骤。',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.muted)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle(title: '实验功能'),
                const SizedBox(height: 10),
                SurfacePanel(
                  child: Row(
                    children: [
                      Container(
                        width: 37,
                        height: 37,
                        decoration: BoxDecoration(
                          color: AppColors.amberSoft,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Icon(Icons.manage_search_outlined,
                            color: AppColors.amber, size: 20),
                      ),
                      const SizedBox(width: 11),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('文档内容检索',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                            SizedBox(height: 3),
                            Text('使用 AnyDoc 在本机转换并匹配支持的文档内容。',
                                style: TextStyle(
                                    color: AppColors.muted, fontSize: 12)),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () =>
                            ref.read(appNavigationProvider.notifier).goTo(5),
                        child: const Text('打开'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionTitle(
                  title: '扫描排除规则',
                  trailing: FilledButton.icon(
                    onPressed: _addExclusionRule,
                    icon: const Icon(Icons.add, size: 17),
                    label: const Text('添加规则'),
                  ),
                ),
                const SizedBox(height: 10),
                SurfacePanel(
                  padding: EdgeInsets.zero,
                  child: exclusions.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 17, vertical: 18),
                          child: Text('未排除任何位置',
                              style: TextStyle(color: AppColors.muted)),
                        )
                      : Column(
                          children: [
                            for (var index = 0;
                                index < exclusions.length;
                                index++) ...[
                              _ExclusionRuleRow(rule: exclusions[index]),
                              if (index != exclusions.length - 1)
                                const Divider(height: 1, color: AppColors.line),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewExclusionRule {
  const _NewExclusionRule(this.kind, this.pattern);

  final ScanExclusionKind kind;
  final String pattern;
}

String _ruleHint(ScanExclusionKind kind) {
  return switch (kind) {
    ScanExclusionKind.directory => '例如：.cache',
    ScanExclusionKind.glob => '例如：*.tmp 或 build/**',
    ScanExclusionKind.regex => r'例如：(^|[\\/])cache([\\/]|$)',
  };
}

class _SettingInfo extends StatelessWidget {
  const _SettingInfo(
      {required this.icon, required this.title, required this.detail});

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 2),
        Icon(icon, color: AppColors.blue, size: 20),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(detail,
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 12, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExclusionRuleRow extends ConsumerWidget {
  const _ExclusionRuleRow({required this.rule});

  final ScanExclusionRule rule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (icon, color, kindLabel) = switch (rule.kind) {
      ScanExclusionKind.directory => (
          Icons.folder_outlined,
          AppColors.blue,
          '目录名',
        ),
      ScanExclusionKind.glob => (
          Icons.data_object_outlined,
          AppColors.amber,
          '通配符',
        ),
      ScanExclusionKind.regex => (
          Icons.code_outlined,
          AppColors.green,
          '正则',
        ),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 10, 8, 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              rule.pattern,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          StatusChip(label: kindLabel, color: color),
          IconButton(
            tooltip: '删除规则',
            onPressed: () =>
                ref.read(scanExclusionsProvider.notifier).remove(rule.id),
            icon: const Icon(Icons.delete_outline,
                size: 19, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
