import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../duplicate_finder/notifier.dart';
import '../project_view/notifier.dart';
import '../ui/app_ui.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duplicate = ref.watch(scannerNotifierProvider);
    final large = ref.watch(projectViewNotifierProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 28, 30, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeading(title: '扫描任务', subtitle: '当前会话中的任务和最近结果'),
          const SizedBox(height: 24),
          _TaskRow(
            icon: Icons.folder_open_outlined,
            iconColor: AppColors.blue,
            title: '大文件扫描',
            path: large.path,
            status: large.isScanning
                ? '扫描中'
                : large.hasCompleted
                    ? '已完成'
                    : '未开始',
            statusColor: large.isScanning ? AppColors.amber : AppColors.green,
            detail: large.path.isEmpty
                ? '尚未选择扫描位置'
                : '${large.scannedFiles} 个文件，${formatBytes(large.scannedBytes)}',
            progress: large.isScanning && large.totalRoots > 0
                ? large.completedRoots / large.totalRoots
                : null,
          ),
          const SizedBox(height: 12),
          _TaskRow(
            icon: Icons.copy_outlined,
            iconColor: AppColors.amber,
            title: '重复文件扫描',
            path: duplicate.path,
            status: duplicate.scanning
                ? '扫描中'
                : duplicate.path.isNotEmpty
                    ? '已完成'
                    : '未开始',
            statusColor: duplicate.scanning ? AppColors.amber : AppColors.green,
            detail: duplicate.path.isEmpty
                ? '尚未选择扫描位置'
                : '${duplicate.totalFileCount} 个文件，发现 ${duplicate.results.length} 个重复组',
            progress: duplicate.scanning ? null : null,
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: '状态说明'),
          const SizedBox(height: 11),
          const SurfacePanel(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.blue),
                SizedBox(width: 11),
                Expanded(
                  child: Text(
                    '扫描计算在 Rust 工作线程中运行。大文件夹任务仅按固定间隔推送进度，重复文件任务只会为同大小文件读取采样内容。',
                    style: TextStyle(
                        color: AppColors.muted, height: 1.5, fontSize: 13),
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

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.path,
    required this.status,
    required this.statusColor,
    required this.detail,
    this.progress,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String path;
  final String status;
  final Color statusColor;
  final String detail;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return SurfacePanel(
      padding: const EdgeInsets.all(17),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(7)),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(
                  path.isEmpty ? detail : path,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 7),
                Text(detail,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12)),
                if (progress != null) ...[
                  const SizedBox(height: 9),
                  LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 14),
          StatusChip(label: status, color: statusColor),
        ],
      ),
    );
  }
}
