import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../duplicate_finder/notifier.dart';
import '../navigation.dart';
import '../project_view/notifier.dart';
import '../ui/app_ui.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duplicate = ref.watch(scannerNotifierProvider);
    final largeScan = ref.watch(projectViewNotifierProvider);
    final duplicateBytes = duplicate.results.fold<BigInt>(
      BigInt.zero,
      (sum, result) => sum + result.fileSize * (result.count - BigInt.one),
    );

    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: '存储概览'),
              const SizedBox(height: 10),
              SurfacePanel(
                padding: EdgeInsets.zero,
                child: SizedBox(
                  height: 116,
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryStat(
                          label: '已扫描大小',
                          value: formatBytes(largeScan.scannedBytes),
                          note: largeScan.hasCompleted ? '最近一次大文件扫描' : '尚未完成扫描',
                        ),
                      ),
                      const VerticalDivider(
                          width: 1, indent: 20, endIndent: 20),
                      Expanded(
                        child: _SummaryStat(
                          label: '大文件夹',
                          value: '${largeScan.details.length}',
                          note: '已识别的一级目录',
                        ),
                      ),
                      const VerticalDivider(
                          width: 1, indent: 20, endIndent: 20),
                      Expanded(
                        child: _SummaryStat(
                          label: '重复文件组',
                          value: '${duplicate.results.length}',
                          note: duplicate.scanning ? '正在验证内容' : '内容完全相同',
                        ),
                      ),
                      const VerticalDivider(
                          width: 1, indent: 20, endIndent: 20),
                      Expanded(
                        child: _SummaryStat(
                          label: '可释放空间',
                          value: formatBytes(duplicateBytes),
                          note: '保留每组一个文件',
                          valueColor: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const SectionTitle(title: '快速操作'),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth < 600
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 12) / 2;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _QuickAction(
                          icon: Icons.folder_open_outlined,
                          iconColor: AppColors.amber,
                          title: '大文件扫描',
                          detail: '定位占用空间较多的文件和文件夹',
                          buttonLabel: '开始扫描',
                          onPressed: () =>
                              ref.read(appNavigationProvider.notifier).goTo(1),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _QuickAction(
                          icon: Icons.copy_outlined,
                          iconColor: AppColors.blue,
                          title: '重复文件扫描',
                          detail: '找出内容完全相同的重复文件',
                          buttonLabel: '开始扫描',
                          onPressed: () =>
                              ref.read(appNavigationProvider.notifier).goTo(2),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 25),
              SectionTitle(
                title: '最近扫描任务',
                trailing: TextButton(
                  onPressed: () =>
                      ref.read(appNavigationProvider.notifier).goTo(3),
                  child: const Text('查看全部'),
                ),
              ),
              const SizedBox(height: 7),
              SurfacePanel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _TaskLine(
                      icon: Icons.folder_outlined,
                      title: '大文件扫描',
                      path: largeScan.path,
                      result: largeScan.path.isEmpty
                          ? '尚未运行'
                          : '${largeScan.details.length} 个一级条目',
                      isRunning: largeScan.isScanning,
                    ),
                    const Divider(height: 1, color: AppColors.line),
                    _TaskLine(
                      icon: Icons.copy_outlined,
                      title: '重复文件扫描',
                      path: duplicate.path,
                      result: duplicate.path.isEmpty
                          ? '尚未运行'
                          : '${duplicate.results.length} 个重复组',
                      isRunning: duplicate.scanning,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.note,
    this.valueColor = AppColors.text,
  });

  final String label;
  final String value;
  final String note;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: valueColor, fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.detail,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String detail;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SurfacePanel(
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 3),
                Text(detail,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 11)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 29,
                  child: FilledButton(
                    onPressed: onPressed,
                    child: Text(buttonLabel),
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

class _TaskLine extends StatelessWidget {
  const _TaskLine({
    required this.icon,
    required this.title,
    required this.path,
    required this.result,
    required this.isRunning,
  });

  final IconData icon;
  final String title;
  final String path;
  final String result;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      child: Row(
        children: [
          Icon(icon, color: AppColors.blue, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                if (path.isNotEmpty)
                  Text(
                    path,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 10),
                  ),
              ],
            ),
          ),
          if (isRunning)
            const StatusChip(label: '扫描中', color: AppColors.amber)
          else
            Text(result,
                style: const TextStyle(color: AppColors.green, fontSize: 11)),
        ],
      ),
    );
  }
}
