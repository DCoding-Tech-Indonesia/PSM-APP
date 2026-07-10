import 'package:flutter/material.dart';

enum CoreButtonType { primary, secondary, outline, text }

enum CoreButtonSize { small, medium, large }

class CoreButton extends StatelessWidget {
  const CoreButton({
    super.key,
    this.text,
    this.child,
    required this.onPressed,
    this.type = CoreButtonType.primary,
    this.size = CoreButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.isIconTrailing = false,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
    this.elevation,
  }) : assert(
         text != null || child != null,
         'Either text or child must be provided',
       );

  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final CoreButtonType type;
  final CoreButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final bool isIconTrailing;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  bool get _isEnabled => onPressed != null && !isDisabled && !isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Resolve colors based on button type
    final resolvedBgColor = _getBackgroundColor(context, theme);
    final resolvedFgColor = _getForegroundColor(context, theme);
    final resolvedBorderSide = _getBorderSide(context, theme, resolvedFgColor);

    // Resolve sizes
    final double buttonHeight = height ?? _getDefaultHeight();
    final double buttonRadius = borderRadius ?? 12.0;
    final EdgeInsetsGeometry buttonPadding = padding ?? _getDefaultPadding();

    // Build content: Text/Child + Icon + Loading
    final Widget content = isLoading
        ? _buildLoadingIndicator(resolvedFgColor)
        : _buildContent(resolvedFgColor);

    // InkWell/Material structure or ElevatedButton
    return SizedBox(
      width: width,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: _isEnabled ? onPressed : null,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: resolvedBgColor,
              foregroundColor: resolvedFgColor,
              disabledBackgroundColor: _getDisabledBackgroundColor(theme),
              disabledForegroundColor: _getDisabledForegroundColor(theme),
              elevation: _isEnabled
                  ? (elevation ?? _getDefaultElevation())
                  : 0.0,
              shadowColor: resolvedBgColor?.withValues(alpha: 0.3),
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
                side: resolvedBorderSide,
              ),
              splashFactory:
                  NoSplash.splashFactory, // Set to default or ink ripple
            ).copyWith(
              // Ensure visual states like disabled are well handled
              elevation: ButtonStyleButton.allOrNull<double>(
                _isEnabled ? (elevation ?? _getDefaultElevation()) : 0.0,
              ),
            ),
        child: content,
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    if (child != null) return child!;

    final Widget textWidget = Text(
      text!,
      style: TextStyle(fontSize: _getFontSize(), fontWeight: FontWeight.bold),
    );

    if (icon == null) return textWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isIconTrailing) ...[icon!, const SizedBox(width: 8)],
        textWidget,
        if (isIconTrailing) ...[const SizedBox(width: 8), icon!],
      ],
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    final double spinnerSize = size == CoreButtonSize.small ? 16.0 : 20.0;
    return SizedBox(
      width: spinnerSize,
      height: spinnerSize,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  // --- Helper Methods ---

  Color? _getBackgroundColor(BuildContext context, ThemeData theme) {
    if (!_isEnabled) {
      return null; // Let ElevatedButton use its default disabled color
    }
    if (backgroundColor != null) return backgroundColor;

    switch (type) {
      case CoreButtonType.primary:
        return theme.colorScheme.primary;
      case CoreButtonType.secondary:
        return theme.colorScheme.secondary;
      case CoreButtonType.outline:
      case CoreButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(BuildContext context, ThemeData theme) {
    if (!_isEnabled) return theme.disabledColor;
    if (foregroundColor != null) return foregroundColor!;

    switch (type) {
      case CoreButtonType.primary:
        return theme.colorScheme.onPrimary;
      case CoreButtonType.secondary:
        return theme.colorScheme.onSecondary;
      case CoreButtonType.outline:
        return theme.colorScheme.primary;
      case CoreButtonType.text:
        return theme.colorScheme.primary;
    }
  }

  BorderSide _getBorderSide(
    BuildContext context,
    ThemeData theme,
    Color fgColor,
  ) {
    if (borderColor != null) {
      return BorderSide(
        color: _isEnabled
            ? borderColor!
            : theme.disabledColor.withValues(alpha: 0.8),
        width: 1.5,
      );
    }

    if (type == CoreButtonType.outline) {
      return BorderSide(
        color: _isEnabled
            ? fgColor
            : theme.disabledColor.withValues(alpha: 0.8),
        width: 1.5,
      );
    }
    return BorderSide.none;
  }

  Color? _getDisabledBackgroundColor(ThemeData theme) {
    if (type == CoreButtonType.outline || type == CoreButtonType.text) {
      return Colors.transparent;
    }
    // Matching typical Material disabled color
    return theme.brightness == Brightness.dark
        ? Colors.white10
        : Colors.grey[300];
  }

  Color? _getDisabledForegroundColor(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? Colors.white30
        : Colors.grey[500];
  }

  double _getDefaultHeight() {
    switch (size) {
      case CoreButtonSize.small:
        return 36.0;
      case CoreButtonSize.medium:
        return 48.0;
      case CoreButtonSize.large:
        return 56.0;
    }
  }

  double _getFontSize() {
    switch (size) {
      case CoreButtonSize.small:
        return 12.0;
      case CoreButtonSize.medium:
        return 16.0;
      case CoreButtonSize.large:
        return 18.0;
    }
  }

  EdgeInsetsGeometry _getDefaultPadding() {
    switch (size) {
      case CoreButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case CoreButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case CoreButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
  }

  double _getDefaultElevation() {
    switch (type) {
      case CoreButtonType.primary:
        return 2.0;
      case CoreButtonType.secondary:
        return 2.0;
      case CoreButtonType.outline:
      case CoreButtonType.text:
        return 0.0;
    }
  }
}
