import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sidebar_item.dart';
import 'sidebar_notifier.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sidebarProvider);

    late final List<SidebarItem> items = [
      SidebarItem(
          icon: const Icon(
            Icons.file_present,
            color: Colors.blueAccent,
          ),
          iconInactive: const Icon(Icons.file_present),
          onClick: (v) {
            ref.read(sidebarProvider.notifier).setIndex(v);
          },
          index: 0,
          title: "重复文件查找"),
      SidebarItem(
          icon: const Icon(
            Icons.folder,
            color: Colors.blueAccent,
          ),
          iconInactive: const Icon(Icons.folder),
          onClick: (v) {
            ref.read(sidebarProvider.notifier).setIndex(v);
          },
          index: 1,
          title: "大文件(夹)扫描"),
      SidebarItem(
          icon: const Icon(
            Icons.search,
            color: Colors.blueAccent,
          ),
          iconInactive: const Icon(Icons.search),
          onClick: (v) {
            ref.read(sidebarProvider.notifier).setIndex(v);
          },
          index: 2,
          title: "混合查询"),
    ];

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(10),
        child: Container(
            width: state.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: items.map((v) => SidebarItemWidget(item: v)).toList(),
            )),
      ),
    );
  }
}
