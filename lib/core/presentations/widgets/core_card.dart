import 'package:flutter/material.dart';

class CoreCard extends StatelessWidget {
  const CoreCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.elevation = 1.0,
    this.shadowColor,
    this.borderColor,
    this.width,
    this.height,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double borderRadius;
  final double elevation;
  final Color? shadowColor;
  final Color? borderColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final resolvedBgColor = backgroundColor ?? 
        (isDark ? theme.colorScheme.surface : Colors.white);
    
    final resolvedShadowColor = shadowColor ?? 
        (isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.05));

    final ShapeBorder resolvedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: borderColor != null
          ? BorderSide(color: borderColor!, width: 1.0)
          : BorderSide.none,
    );

    Widget cardContent = Padding(
      padding: padding,
      child: child,
    );

    // If tap callback is provided, wrap content with InkWell for ripple effect
    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardContent,
      );
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: Card(
        color: resolvedBgColor,
        elevation: elevation,
        shadowColor: resolvedShadowColor,
        shape: resolvedShape,
        clipBehavior: Clip.antiAlias, // Ensures InkWell ripple doesn't overflow corners
        margin: EdgeInsets.zero,
        child: cardContent,
      ),
    );
  }
}
