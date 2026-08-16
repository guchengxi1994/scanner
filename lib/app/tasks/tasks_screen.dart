import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../duplicate_finder/notifier.dart';
import '../history/scan_history.dart';
import '../project_view/notifier.dart';
import '../ui/app_ui.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duplicate = ref.watch(scannerNotifierProvider);
    final large = ref.watch(projectViewNotifierProvider);
    final history = ref.watch(scanHistoryProvider);
    final activeTaskIds = <String>{
      if (large.isScanning && large.historyId != null) large.historyId!,
      if (duplicate.scanning && duplicate.historyId != null)
        duplicate.historyId!,
    };

    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(30, 28, 30, 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeading(
                title: '扫描任务',
                subtitle: '本机保存最近 30 次扫描记录',
              ),
              const SizedBox(height: 24),
              SectionTitle(
                title: '扫描历史',
                trailing: Text(
                  '${history.length} 条记录',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
              const SizedBox(height: 10),
              if (history.isEmpty)
                const SurfacePanel(child: _HistoryEmptyState())
              else
                for (final item in history) ...[
                  _HistoryTaskRow(
                    item: item,
                    isActive: activeTaskIds.contains(item.id),
                  ),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 14),
              const SectionTitle(title: '扫描说明'),
              const SizedBox(height: 11),
              const SurfacePanel(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.storage_outlined, color: AppColors.blue),
                    SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        '历史仅保存在当前设备。扫描计算在 Rust 工作线程运行，界面按固定间隔更新进度。',
                        style: TextStyle(
                          color: AppColors.muted,
                          height: 1.5,
                          fontSize: 13,
                        ),
                      ),
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

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Icon(Icons.history_outlined, color: AppColors.muted),
          SizedBox(width: 12),
          Text('尚无扫描记录', style: TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _HistoryTaskRow extends StatelessWidget {
  const _HistoryTaskRow({required this.item, required this.isActive});

  final ScanHistoryItem item;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isLargeScan = item.kind == ScanHistoryKind.largeFiles;
    final color = isLargeScan ? AppColors.blue : AppColors.amber;
    final status = isActive
        ? '扫描中'
        : item.completed
            ? '已完成'
            : '已中断';
    final statusColor = isActive
        ? AppColors.amber
        : item.completed
            ? AppColors.green
            : AppColors.muted;
    final detail = isLargeScan
        ? '${item.fileCount} 个文件 · ${formatBytes(item.bytes)} · ${item.resultCount} 个一级条目'
        : '${item.fileCount} 个文件 · ${item.resultCount} 个重复组 · 可释放 ${formatBytes(item.bytes)}';

    return SurfacePanel(
      padding: const EdgeInsets.all(17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              isLargeScan ? Icons.folder_open_outlined : Icons.copy_outlined,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isLargeScan ? '大文件扫描' : '重复文件扫描',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      _formatTimestamp(item.startedAt),
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.path,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
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

String _formatTimestamp(DateTime value) {
  final local = value.toLocal();
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} '
      '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
}
