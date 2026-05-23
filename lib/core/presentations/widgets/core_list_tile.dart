import 'package:flutter/material.dart';

class CoreListTile extends StatelessWidget {
  const CoreListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.tileColor,
    this.borderRadius = 12.0,
    this.padding,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  });

  final dynamic title; // String or Widget
  final dynamic subtitle; // String or Widget or null
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? tileColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final resolvedBgColor = tileColor ??
        (isDark ? theme.colorScheme.surface : Colors.grey.shade50);

    Widget titleWidget;
    if (title is Widget) {
      titleWidget = title as Widget;
    } else {
      titleWidget = Text(
        title.toString(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      );
    }

    Widget? subtitleWidget;
    if (subtitle != null) {
      if (subtitle is Widget) {
        subtitleWidget = subtitle as Widget;
      } else {
        subtitleWidget = Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle.toString(),
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
        );
      }
    }

    Widget coreContent = Padding(
      padding: contentPadding,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                titleWidget,
                // ignore: use_null_aware_elements
                if (subtitleWidget != null) subtitleWidget,
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap != null) {
      coreContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: coreContent,
      );
    }

    return Container(
      margin: padding,
      decoration: BoxDecoration(
        color: resolvedBgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: coreContent,
      ),
    );
  }
}
