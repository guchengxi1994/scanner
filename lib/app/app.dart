import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import 'dashboard/dashboard_screen.dart';
import 'document_search/document_search_screen.dart';
import 'duplicate_finder/scanner_screen.dart';
import 'navigation.dart';
import 'project_view/project_view_screen.dart';
import 'settings/settings_screen.dart';
import 'tasks/tasks_screen.dart';
import 'ui/app_ui.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: ToastificationWrapper(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '存储扫描器',
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Microsoft YaHei UI',
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.blue,
              brightness: Brightness.light,
              surface: AppColors.surface,
            ),
            scaffoldBackgroundColor: AppColors.canvas,
            dividerColor: AppColors.line,
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.canvas,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.blue, width: 1.4),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 38),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                textStyle:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
            ),
          ),
          home: const _AppShell(),
        ),
      ),
    );
  }
}

class _AppShell extends ConsumerWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(appNavigationProvider);
    const pages = [
      DashboardScreen(),
      ProjectViewScreen(),
      ScannerScreen(),
      TasksScreen(),
      SettingsScreen(),
      DocumentSearchScreen(),
    ];

    return Scaffold(
      body: Row(
        children: [
          _NavigationRail(
            selectedIndex: current,
            onChanged: (index) =>
                ref.read(appNavigationProvider.notifier).goTo(index),
          ),
          const VerticalDivider(width: 1, color: AppColors.line),
          Expanded(child: IndexedStack(index: current, children: pages)),
        ],
      ),
    );
  }
}

class _NavigationRail extends StatelessWidget {
  const _NavigationRail({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const destinations = [
      _NavigationDestination(
          Icons.space_dashboard_outlined, Icons.space_dashboard, '首页'),
      _NavigationDestination(
          Icons.folder_open_outlined, Icons.folder_open, '大文件扫描'),
      _NavigationDestination(Icons.copy_outlined, Icons.copy, '重复文件扫描'),
      _NavigationDestination(Icons.list_alt_outlined, Icons.list_alt, '扫描任务'),
      _NavigationDestination(Icons.settings_outlined, Icons.settings, '设置'),
    ];

    return SizedBox(
      width: 292,
      child: ColoredBox(
        color: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Brand(),
              const SizedBox(height: 28),
              for (var index = 0; index < destinations.length; index++)
                _NavItem(
                  destination: destinations[index],
                  selected: selectedIndex == index,
                  onTap: () => onChanged(index),
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_outlined,
                        color: AppColors.green, size: 17),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text('本机处理，不上传文件',
                          style:
                              TextStyle(color: AppColors.muted, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text('Scanner 3.1',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.all(Radius.circular(7))),
          child: SizedBox(
              width: 34,
              height: 34,
              child: Icon(Icons.radar_outlined, color: Colors.white, size: 20)),
        ),
        SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('存储扫描器',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              SizedBox(height: 1),
              Text('本地文件分析',
                  style: TextStyle(color: AppColors.muted, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavigationDestination {
  const _NavigationDestination(this.outlinedIcon, this.filledIcon, this.label);

  final IconData outlinedIcon;
  final IconData filledIcon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem(
      {required this.destination, required this.selected, required this.onTap});

  final _NavigationDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: selected ? AppColors.blueSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 42,
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  selected ? destination.filledIcon : destination.outlinedIcon,
                  color: selected ? AppColors.blue : AppColors.muted,
                  size: 19,
                ),
                const SizedBox(width: 11),
                Text(
                  destination.label,
                  style: TextStyle(
                    color: selected ? AppColors.blue : AppColors.text,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
