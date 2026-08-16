import 'dart:convert';

import 'package:file_selector/file_selector.dart' hide openFile;
import 'package:flutter/material.dart';
import 'package:scanner/src/rust/api/hybrid_search_api.dart';
import 'package:scanner/src/rust/api/tools_api.dart';
import 'package:scanner/src/rust/hybrid_search.dart';

import '../ui/app_ui.dart';

class DocumentSearchScreen extends StatefulWidget {
  const DocumentSearchScreen({super.key});

  @override
  State<DocumentSearchScreen> createState() => _DocumentSearchScreenState();
}

class _DocumentSearchScreenState extends State<DocumentSearchScreen> {
  static const _contentSearchPrefix = '__anydoc_content_search__:';
  final _queryController = TextEditingController();
  String _path = '';
  bool _searching = false;
  List<_DocumentHit> _results = const [];
  String? _error;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _chooseFolder() async {
    final path = await getDirectoryPath();
    if (path != null && mounted) {
      setState(() => _path = path);
    }
  }

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (_path.isEmpty || query.isEmpty || _searching) return;

    setState(() {
      _searching = true;
      _results = const [];
      _error = null;
    });

    try {
      final raw = await hybridSearchSync(
        p: _path,
        caseSensitive: false,
        startsWith: const [],
        endsWith: const [],
        includes: const [],
        excludes: const [],
        regex: [_contentSearchPrefix + query],
        searchType: SearchType.and,
      );
      final results = raw
          .map((item) =>
              _DocumentHit.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
      if (mounted) setState(() => _results = results);
    } catch (_) {
      if (mounted) setState(() => _error = '检索未能完成，请确认所选位置可读取。');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSearch = _path.isNotEmpty &&
        _queryController.text.trim().isNotEmpty &&
        !_searching;
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 28, 30, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeading(
            title: '文档内容检索',
            subtitle: '实验功能：AnyDoc 在本机转换受支持的文档，再按内容匹配',
            trailing: StatusChip(label: '实验性', color: AppColors.amber),
          ),
          const SizedBox(height: 20),
          SurfacePanel(
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.folder_outlined,
                        color: AppColors.blue, size: 19),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        _path.isEmpty ? '尚未选择文档目录' : _path,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: _path.isEmpty
                                ? AppColors.muted
                                : AppColors.text,
                            fontSize: 13),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _searching ? null : _chooseFolder,
                      icon: const Icon(Icons.folder_open_outlined, size: 17),
                      label: Text(_path.isEmpty ? '选择文件夹' : '更改'),
                    ),
                  ],
                ),
                const Divider(height: 25, color: AppColors.line),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _queryController,
                        enabled: !_searching,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _search(),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: '输入要查找的文字',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: canSearch ? _search : null,
                      icon: _searching
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.manage_search_outlined, size: 18),
                      label: Text(_searching ? '检索中' : '开始检索'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionTitle(
            title: '匹配结果',
            trailing: _results.isEmpty
                ? null
                : Text('${_results.length} 个文档',
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _error != null
                ? EmptyState(
                    icon: Icons.error_outline, title: '检索失败', detail: _error!)
                : _results.isEmpty
                    ? EmptyState(
                        icon: Icons.article_outlined,
                        title: _searching ? '正在读取文档内容' : '等待检索',
                        detail: _searching
                            ? '检索会跳过无法转换或不受支持的文档。'
                            : '支持 Word、PowerPoint、Excel、PDF、EPUB、RTF、CSV 和 OpenDocument 格式。',
                      )
                    : SurfacePanel(
                        padding: EdgeInsets.zero,
                        child: ListView.separated(
                          itemCount: _results.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: AppColors.line),
                          itemBuilder: (context, index) =>
                              _DocumentResult(hit: _results[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _DocumentHit {
  const _DocumentHit({
    required this.path,
    required this.name,
    required this.snippet,
    required this.size,
    required this.matchCount,
  });

  final String path;
  final String name;
  final String snippet;
  final int size;
  final int matchCount;

  factory _DocumentHit.fromJson(Map<String, dynamic> json) {
    return _DocumentHit(
      path: json['path'] as String? ?? '',
      name: json['name'] as String? ?? '',
      snippet: json['snippet'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      matchCount: json['match_count'] as int? ?? 0,
    );
  }
}

class _DocumentResult extends StatelessWidget {
  const _DocumentResult({required this.hit});

  final _DocumentHit hit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(7)),
            child: const Icon(Icons.article_outlined,
                color: AppColors.green, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hit.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 3),
                Text(hit.path,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 11)),
                const SizedBox(height: 7),
                Text(hit.snippet,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 12, height: 1.35)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusChip(
                  label: '${hit.matchCount} 处匹配', color: AppColors.green),
              const SizedBox(height: 4),
              Text(formatByteCount(hit.size),
                  style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              IconButton(
                tooltip: '打开位置',
                onPressed: () => openFile(s: hit.path),
                icon: const Icon(Icons.open_in_new_outlined, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
