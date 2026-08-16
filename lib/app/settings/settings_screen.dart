import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../navigation.dart';
import '../ui/app_ui.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _showPaths = true;
  bool _confirmTrash = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 28, 30, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeading(title: '设置', subtitle: '本次会话的显示和文件操作偏好'),
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
                const SectionTitle(title: '默认排除位置'),
                const SizedBox(height: 10),
                const SurfacePanel(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ExcludeChip(label: '.git'),
                      _ExcludeChip(label: 'node_modules'),
                      _ExcludeChip(label: 'System Volume Information'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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

class _ExcludeChip extends StatelessWidget {
  const _ExcludeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
          color: AppColors.canvas, borderRadius: BorderRadius.circular(5)),
      child: Text(label,
          style: const TextStyle(color: AppColors.muted, fontSize: 12)),
    );
  }
}
