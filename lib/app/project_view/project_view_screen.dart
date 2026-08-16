import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanner/src/rust/api/project_api.dart';
import 'package:scanner/src/rust/api/tools_api.dart';
import 'package:scanner/src/rust/project.dart';

import '../ui/app_ui.dart';
import 'notifier.dart';

class ProjectViewScreen extends ConsumerStatefulWidget {
  const ProjectViewScreen({super.key});

  @override
  ConsumerState<ProjectViewScreen> createState() => _ProjectViewScreenState();
}

class _ProjectViewScreenState extends ConsumerState<ProjectViewScreen> {
  StreamSubscription<ProjectDetail>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = projectScanStream().listen(
      (event) =>
          ref.read(projectViewNotifierProvider.notifier).handleEvent(event),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectViewNotifierProvider);
    final details = [...state.details]
      ..sort((left, right) => right.size.compareTo(left.size));
    final progress = state.totalRoots == 0
        ? null
        : (state.completedRoots / state.totalRoots).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 28, 30, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            title: '大文件扫描',
            subtitle: '按一级目录汇总体积，单次遍历避免重复磁盘读取',
            trailing: FilledButton.icon(
              onPressed: state.isScanning
                  ? null
                  : () => ref
                      .read(projectViewNotifierProvider.notifier)
                      .startScan(),
              icon: const Icon(Icons.folder_open_outlined, size: 18),
              label: Text(state.path.isEmpty ? '选择文件夹' : '重新扫描'),
            ),
          ),
          const SizedBox(height: 20),
          _ScanStatus(state: state, progress: progress),
          const SizedBox(height: 20),
          const SectionTitle(title: '空间占用排行'),
          const SizedBox(height: 10),
          Expanded(
            child: details.isEmpty
                ? EmptyState(
                    icon: Icons.folder_open_outlined,
                    title: state.isScanning ? '正在建立目录清单' : '还没有扫描结果',
                    detail: state.isScanning
                        ? '扫描完成一级目录后会逐步展示结果。'
                        : '选择一个文件夹，查看其中最占空间的文件和文件夹。',
                  )
                : SurfacePanel(
                    padding: EdgeInsets.zero,
                    child: ListView.separated(
                      itemCount: details.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.line),
                      itemBuilder: (context, index) => _ResultRow(
                        detail: details[index],
                        maxSize: details.first.size,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ScanStatus extends StatelessWidget {
  const _ScanStatus({required this.state, required this.progress});

  final ProjectViewState state;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final ready = state.path.isNotEmpty;
    return SurfacePanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: state.isScanning
                      ? AppColors.blueSoft
                      : AppColors.greenSoft,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  state.isScanning
                      ? Icons.radar_outlined
                      : Icons.storage_outlined,
                  color: state.isScanning ? AppColors.blue : AppColors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.isScanning
                          ? '正在扫描'
                          : ready
                              ? '扫描完成'
                              : '等待选择位置',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      state.isScanning
                          ? state.currentPath
                          : (ready ? state.path : '未选择文件夹'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (state.isScanning)
                const StatusChip(label: '运行中', color: AppColors.amber),
              if (state.hasCompleted)
                const StatusChip(label: '已完成', color: AppColors.green),
            ],
          ),
          if (state.isScanning) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
          const SizedBox(height: 15),
          Wrap(
            spacing: 28,
            runSpacing: 8,
            children: [
              _Fact(label: '已扫描文件', value: '${state.scannedFiles}'),
              _Fact(label: '已统计大小', value: formatBytes(state.scannedBytes)),
              _Fact(
                label: '完成条目',
                value: state.totalRoots == 0
                    ? '-'
                    : '${state.completedRoots}/${state.totalRoots}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.muted, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.detail, required this.maxSize});

  final ProjectDetail detail;
  final BigInt maxSize;

  @override
  Widget build(BuildContext context) {
    final ratio = maxSize == BigInt.zero
        ? 0.0
        : detail.size.toDouble() / maxSize.toDouble();
    final isFolder = detail.count > BigInt.one;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
      child: Row(
        children: [
          Icon(
              isFolder
                  ? Icons.folder_outlined
                  : Icons.insert_drive_file_outlined,
              color: AppColors.blue),
          const SizedBox(width: 11),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.path,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor: AppColors.blueSoft,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          SizedBox(
            width: 88,
            child: Text(formatBytes(detail.size),
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 22),
          SizedBox(
            width: 76,
            child: Text('${detail.count} 个文件',
                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ),
          IconButton(
            tooltip: '打开位置',
            onPressed: () => openFolder(s: detail.path),
            icon: const Icon(Icons.open_in_new_outlined, size: 19),
          ),
        ],
      ),
    );
  }
}
