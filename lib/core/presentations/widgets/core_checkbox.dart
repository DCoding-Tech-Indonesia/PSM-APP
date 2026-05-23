import 'package:flutter/material.dart';

class CoreCheckbox extends StatelessWidget {
  const CoreCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.activeColor,
    this.checkColor,
    this.borderRadius = 4.0,
    this.size = 24.0,
    this.labelStyle,
    this.isDisabled = false,
  });

  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final Color? activeColor;
  final Color? checkColor;
  final double borderRadius;
  final double size;
  final TextStyle? labelStyle;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final Color resolvedActiveColor = activeColor ?? theme.colorScheme.primary;
    final Color resolvedCheckColor = checkColor ?? Colors.white;

    Widget checkboxWidget = SizedBox(
      height: size,
      width: size,
      child: Checkbox(
        value: value,
        onChanged: isDisabled ? null : onChanged,
        activeColor: resolvedActiveColor,
        checkColor: resolvedCheckColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        side: BorderSide(
          color: isDisabled 
              ? theme.disabledColor.withValues(alpha: 0.5)
              : Colors.grey.shade400,
          width: 1.5,
        ),
      ),
    );

    if (label == null) {
      return checkboxWidget;
    }

    return GestureDetector(
      onTap: isDisabled || onChanged == null
          ? null
          : () => onChanged!(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          checkboxWidget,
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label!,
              style: labelStyle ??
                  TextStyle(
                    fontSize: 16,
                    color: isDisabled 
                        ? theme.disabledColor 
                        : Colors.grey.shade800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
