import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const canvas = Color(0xfff5f7fb);
  static const surface = Colors.white;
  static const line = Color(0xffe8ecf3);
  static const text = Color(0xff1c2434);
  static const muted = Color(0xff718096);
  static const blue = Color(0xff246bfd);
  static const blueSoft = Color(0xffeaf1ff);
  static const green = Color(0xff1a9b68);
  static const greenSoft = Color(0xffe8f7f0);
  static const amber = Color(0xffe89b12);
  static const amberSoft = Color(0xfffff5df);
  static const red = Color(0xffd9534f);
  static const ink = Color.fromARGB(255, 119, 112, 112);
}

class SurfacePanel extends StatelessWidget {
  const SurfacePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.subtitle,
    this.icon,
    this.accent = AppColors.blue,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color accent;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (icon != null) ...[
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.11),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: accent, size: 20),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 5),
                              Text(
                                subtitle!,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: '关闭',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 19),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  content,
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    OverflowBar(
                      alignment: MainAxisAlignment.end,
                      spacing: 8,
                      overflowAlignment: OverflowBarAlignment.end,
                      overflowSpacing: 8,
                      children: actions,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppSelectOption<T> {
  const AppSelectOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

class AppSelectField<T> extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.icon,
  });

  final String label;
  final T value;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final selected = options.firstWhere(
      (option) => option.value == value,
      orElse: () => options.first,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        MenuAnchor(
          style: MenuStyle(
            backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            elevation: const WidgetStatePropertyAll(8),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.line),
              ),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: 6),
            ),
          ),
          menuChildren: [
            for (final option in options)
              MenuItemButton(
                onPressed: () => onChanged(option.value),
                leadingIcon: option.icon == null
                    ? null
                    : Icon(option.icon, size: 18, color: AppColors.muted),
                style: ButtonStyle(
                  foregroundColor: const WidgetStatePropertyAll(AppColors.text),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                  ),
                  minimumSize: const WidgetStatePropertyAll(Size(220, 42)),
                ),
                child: Text(option.label),
              ),
          ],
          builder: (context, controller, child) => InkWell(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                border: Border.all(
                  color: controller.isOpen ? AppColors.blue : AppColors.line,
                  width: controller.isOpen ? 1.4 : 1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.muted, size: 18),
                    const SizedBox(width: 9),
                  ],
                  Expanded(
                    child: Text(
                      selected.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    controller.isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.muted,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    builder: builder,
  );
}

class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.blue,
    this.note,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.tightFor(height: 108),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (note != null)
            Text(
              note!,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
    this.action,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: AppColors.blueSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.blue, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 7),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String formatBytes(BigInt value) => formatByteCount(value.toDouble());

String formatByteCount(num value) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var bytes = value.toDouble();
  var index = 0;
  while (bytes >= 1024 && index < units.length - 1) {
    bytes /= 1024;
    index += 1;
  }
  final fractionDigits = bytes >= 100 || index == 0 ? 0 : 1;
  return '${bytes.toStringAsFixed(fractionDigits)} ${units[index]}';
}
