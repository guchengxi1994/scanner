import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanner/src/rust/api/project_api.dart';
import 'package:scanner/src/rust/api/tools_api.dart';
import 'package:scanner/src/rust/project.dart';

import '../cleanup/cleanup_rule.dart';
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
          if (state.cleanupCandidates.isNotEmpty) ...[
            const SizedBox(height: 16),
            _CleanupSuggestions(candidates: state.cleanupCandidates),
          ],
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

class _CleanupSuggestions extends ConsumerWidget {
  const _CleanupSuggestions({required this.candidates});

  final List<CleanupCandidate> candidates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reclaimable = candidates.fold<BigInt>(
      BigInt.zero,
      (sum, candidate) => sum + candidate.size,
    );
    return SurfacePanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 14, 17, 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.greenSoft,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.cleaning_services_outlined,
                    color: AppColors.green,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '清理建议',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${candidates.length} 项候选，可释放约 ${formatBytes(reclaimable)}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Tooltip(
                  message: '建议项来自启用的清理规则，删除前仍需确认。',
                  child: Icon(
                    Icons.info_outline,
                    size: 17,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.line),
          for (var index = 0; index < candidates.length; index++) ...[
            _CleanupCandidateRow(candidate: candidates[index]),
            if (index != candidates.length - 1)
              const Divider(height: 1, color: AppColors.line),
          ],
        ],
      ),
    );
  }
}

class _CleanupCandidateRow extends ConsumerWidget {
  const _CleanupCandidateRow({required this.candidate});

  final CleanupCandidate candidate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riskColor = switch (candidate.rule.risk) {
      CleanupRisk.safe => AppColors.green,
      CleanupRisk.rebuildable => AppColors.blue,
      CleanupRisk.caution => AppColors.amber,
      CleanupRisk.protected => AppColors.red,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 10, 8, 10),
      child: Row(
        children: [
          Icon(Icons.auto_delete_outlined, color: riskColor, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.rule.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${candidate.itemCount} 个文件 · ${candidate.path}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            formatBytes(candidate.size),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          StatusChip(
            label: cleanupRiskLabel(candidate.rule.risk),
            color: riskColor,
          ),
          if (candidate.canExecute)
            IconButton(
              tooltip: '移到回收站',
              onPressed: () => _confirmCleanup(context, ref),
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.red,
                size: 19,
              ),
            )
          else if (candidate.rule.action ==
              CleanupActionType.externalInstructions)
            IconButton(
              tooltip: '查看清理说明',
              onPressed: () => _showCleanupSuggestion(context),
              icon: const Icon(Icons.terminal_outlined, size: 18),
            )
          else
            IconButton(
              tooltip: '查看处理建议',
              onPressed: () => _showCleanupSuggestion(context),
              icon: const Icon(Icons.info_outline, size: 18),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmCleanup(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: '移到回收站？',
        subtitle: candidate.path,
        icon: Icons.delete_outline,
        accent: AppColors.red,
        content: Text(
          candidate.rule.description,
          style: const TextStyle(color: AppColors.muted, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.delete_outline, size: 17),
            label: const Text('移到回收站'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result = await removeFile(s: candidate.path);
    if (!context.mounted) return;
    if (result.success) {
      ref
          .read(projectViewNotifierProvider.notifier)
          .removeCleanupCandidate(candidate.path);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已移到回收站')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('清理失败，文件可能正在使用或没有权限')));
    }
  }

  Future<void> _showCleanupSuggestion(BuildContext context) async {
    final command = candidate.rule.externalCommand;
    final hasCommand = command != null && command.trim().isNotEmpty;
    await showAppDialog<void>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: candidate.rule.name,
        subtitle: hasCommand ? '可以复制命令，或打开终端执行。' : '这是一个查看建议，不会自动修改文件。',
        icon: hasCommand ? Icons.terminal_outlined : Icons.info_outline,
        accent: hasCommand ? AppColors.blue : AppColors.amber,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              candidate.rule.description,
              style: const TextStyle(color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 14),
            if (hasCommand) ...[
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        command,
                        style: const TextStyle(
                          fontFamily: 'Consolas',
                          fontSize: 13,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: '复制命令',
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: command));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('命令已复制')));
                      },
                      icon: const Icon(Icons.copy_outlined, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('关闭'),
          ),
          if (hasCommand)
            FilledButton.icon(
              onPressed: () async {
                final launched = await _openTerminal(command);
                if (!context.mounted) return;
                if (launched) {
                  Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('未找到可用终端，请复制命令后手动执行')),
                  );
                }
              },
              icon: const Icon(Icons.play_arrow_outlined, size: 18),
              label: const Text('打开终端执行'),
            ),
        ],
      ),
    );
  }

  Future<bool> _openTerminal(String command) async {
    try {
      if (Platform.isWindows) {
        final shell = Platform.environment['ComSpec'] ?? 'cmd.exe';
        await Process.start(shell, [
          '/K',
          command,
        ], mode: ProcessStartMode.detached);
        return true;
      }
      if (Platform.isMacOS) {
        final escaped = command.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
        await Process.start('osascript', [
          '-e',
          'tell application "Terminal" to do script "$escaped"',
        ], mode: ProcessStartMode.detached);
        return true;
      }
      for (final executable in ['x-terminal-emulator', 'gnome-terminal']) {
        try {
          final args = executable == 'gnome-terminal'
              ? ['--', 'bash', '-lc', command]
              : ['-e', 'bash', '-lc', command];
          await Process.start(
            executable,
            args,
            mode: ProcessStartMode.detached,
          );
          return true;
        } on ProcessException {
          continue;
        }
      }
    } on ProcessException {
      return false;
    }
    return false;
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
                  state.error != null
                      ? Icons.error_outline
                      : state.isScanning
                      ? Icons.radar_outlined
                      : Icons.storage_outlined,
                  color: state.error != null
                      ? AppColors.red
                      : state.isScanning
                      ? AppColors.blue
                      : AppColors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.error != null
                          ? '扫描失败'
                          : state.isScanning
                          ? '正在扫描'
                          : ready
                          ? '扫描完成'
                          : '等待选择位置',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      state.error != null
                          ? state.error!
                          : state.isScanning
                          ? state.currentPath
                          : (ready ? state.path : '未选择文件夹'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (state.isScanning)
                const StatusChip(label: '运行中', color: AppColors.amber),
              if (state.error != null)
                const StatusChip(label: '失败', color: AppColors.red),
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
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
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
            isFolder ? Icons.folder_outlined : Icons.insert_drive_file_outlined,
            color: AppColors.blue,
          ),
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
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
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
            child: Text(
              formatBytes(detail.size),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 22),
          SizedBox(
            width: 76,
            child: Text(
              '${detail.count} 个文件',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
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
