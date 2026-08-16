import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanner/src/rust/api/scanner_api.dart';
import 'package:scanner/src/rust/api/tools_api.dart';
import 'package:scanner/src/rust/scanner/compare_result.dart';
import 'package:scanner/src/rust/scanner/event.dart';
import 'package:scanner/src/rust/scanner/file.dart' show File;

import '../ui/app_ui.dart';
import 'notifier.dart';
import 'notifier_state.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  StreamSubscription<ResEvent>? _eventSubscription;
  StreamSubscription<CompareResult>? _resultSubscription;

  @override
  void initState() {
    super.initState();
    _eventSubscription = eventStream().listen(
      (event) => ref.read(scannerNotifierProvider.notifier).changeStage(event),
    );
    _resultSubscription = scannerRefreshResultsStream().listen(
      (event) => ref.read(scannerNotifierProvider.notifier).addItem(event),
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _resultSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scannerNotifierProvider);
    final results = [...state.results]
      ..sort((left, right) => right.fileSize.compareTo(left.fileSize));
    final recoverable = results.fold<BigInt>(
      BigInt.zero,
      (sum, result) => sum + result.fileSize * (result.count - BigInt.one),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 28, 30, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeading(
            title: '重复文件扫描',
            subtitle: '尺寸筛选、前后采样和完整哈希验证，减少无效磁盘读取',
            trailing: FilledButton.icon(
              onPressed: state.scanning
                  ? null
                  : () =>
                      ref.read(scannerNotifierProvider.notifier).startScan(),
              icon: const Icon(Icons.content_copy_outlined, size: 18),
              label: Text(state.path.isEmpty ? '选择文件夹' : '重新扫描'),
            ),
          ),
          const SizedBox(height: 20),
          _DuplicateStatus(state: state, reclaimable: recoverable),
          const SizedBox(height: 20),
          SectionTitle(
            title: '重复结果',
            trailing: results.isEmpty
                ? null
                : Text('${results.length} 组',
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: results.isEmpty
                ? EmptyState(
                    icon: Icons.copy_outlined,
                    title: state.scanning ? '正在比对文件' : '还没有重复结果',
                    detail: state.scanning
                        ? '同大小文件会先通过小样本指纹筛选，再进行完整哈希验证。'
                        : '选择一个文件夹开始扫描，结果只显示内容完全相同的文件。',
                  )
                : SurfacePanel(
                    padding: EdgeInsets.zero,
                    child: ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.line),
                      itemBuilder: (context, index) =>
                          _DuplicateGroup(result: results[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DuplicateStatus extends StatelessWidget {
  const _DuplicateStatus({required this.state, required this.reclaimable});

  final ScannerState state;
  final BigInt reclaimable;

  @override
  Widget build(BuildContext context) {
    final isFinished = state.path.isNotEmpty && !state.scanning;
    return SurfacePanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color:
                      state.scanning ? AppColors.amberSoft : AppColors.blueSoft,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  state.scanning ? Icons.sync : Icons.copy_outlined,
                  color: state.scanning ? AppColors.amber : AppColors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.scanning
                          ? state.stage
                          : isFinished
                              ? '扫描完成'
                              : '等待扫描',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      state.path.isEmpty ? '未选择文件夹' : state.path,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (state.scanning)
                const StatusChip(label: '运行中', color: AppColors.amber),
              if (isFinished)
                const StatusChip(label: '已完成', color: AppColors.green),
            ],
          ),
          if (state.scanning) ...[
            const SizedBox(height: 15),
            const LinearProgressIndicator(minHeight: 5),
          ],
          const SizedBox(height: 15),
          Wrap(
            spacing: 28,
            runSpacing: 8,
            children: [
              _ScanFact(label: '已发现文件', value: '${state.totalFileCount}'),
              _ScanFact(label: '重复文件组', value: '${state.results.length}'),
              _ScanFact(label: '可回收空间', value: formatBytes(reclaimable)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanFact extends StatelessWidget {
  const _ScanFact({required this.label, required this.value});

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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _DuplicateGroup extends ConsumerWidget {
  const _DuplicateGroup({required this.result});

  final CompareResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = result.allSameFiles.expand((group) => group).toList();
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 4),
        childrenPadding: const EdgeInsets.only(left: 17, right: 17, bottom: 9),
        leading: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
              color: AppColors.amberSoft,
              borderRadius: BorderRadius.circular(7)),
          child: const Icon(Icons.copy_all_outlined,
              color: AppColors.amber, size: 19),
        ),
        title: Text(
          '${files.length} 个相同文件',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        subtitle: Text(
          '${formatBytes(result.fileSize)} / 文件，可回收 ${formatBytes(result.fileSize * (BigInt.from(files.length) - BigInt.one))}',
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        children: files
            .map((file) => _DuplicateFile(resultId: result.index, file: file))
            .toList(),
      ),
    );
  }
}

class _DuplicateFile extends ConsumerWidget {
  const _DuplicateFile({required this.resultId, required this.file});

  final BigInt resultId;
  final File file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.only(left: 12, right: 4, top: 7, bottom: 7),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined,
              size: 17, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 2),
                Text(file.path,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            tooltip: '打开位置',
            onPressed: () => openFile(s: file.path),
            icon: const Icon(Icons.open_in_new_outlined, size: 18),
          ),
          IconButton(
            tooltip: '移到回收站',
            onPressed: () async {
              final outcome = await removeFile(s: file.path);
              if (outcome.success) {
                ref
                    .read(scannerNotifierProvider.notifier)
                    .removeFileFromList(resultId, file);
              }
            },
            icon: const Icon(Icons.delete_outline,
                color: AppColors.red, size: 18),
          ),
        ],
      ),
    );
  }
}
