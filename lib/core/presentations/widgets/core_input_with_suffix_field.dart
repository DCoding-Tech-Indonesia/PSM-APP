import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InputRuleSuffix { text, number, positiveNumber }

class CoreInputWithSuffixField extends StatefulWidget {
  final String label;
  final String suffixText;
  final TextEditingController? controller;
  final String? hintText;
  final bool isRequired;
  final String? initValue;
  final InputRuleSuffix rule;
  final ValueChanged<String>? onChanged;

  const CoreInputWithSuffixField({
    super.key,
    required this.label,
    required this.suffixText,
    this.controller,
    this.hintText,
    this.isRequired = false,
    this.initValue,
    this.rule = InputRuleSuffix.text,
    this.onChanged,
  });

  @override
  State<CoreInputWithSuffixField> createState() =>
      _CoreInputWithSuffixFieldState();
}

class _CoreInputWithSuffixFieldState extends State<CoreInputWithSuffixField> {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _controller;

  bool get isFocused => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      setState(() {});
    });
    _controller = TextEditingController(text: widget.initValue ?? '');
  }

  @override
  void didUpdateWidget(covariant CoreInputWithSuffixField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initValue != oldWidget.initValue &&
        widget.initValue != _controller.text) {
      _controller.text = widget.initValue ?? '';
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF1565C0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A5568),
              ),
            ),
            if (widget.isRequired)
              const Text(
                " *",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFocused ? primaryColor : Colors.grey.shade300,
              width: 1.2,
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: isFocused
                    ? primaryColor.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: _getKeyboardType(),
                  inputFormatters: _getInputFormatters(),
                  onChanged: (value) {
                    final processedValue = _processValue(value);
                    widget.onChanged?.call(processedValue);
                  },
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isFocused ? primaryColor : Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(11),
                    bottomRight: Radius.circular(11),
                  ),
                ),
                child: Text(
                  widget.suffixText,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isFocused ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.rule) {
      case InputRuleSuffix.number:
      case InputRuleSuffix.positiveNumber:
        return TextInputType.number;
      case InputRuleSuffix.text:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (widget.rule) {
      case InputRuleSuffix.number:
        return [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))];
      case InputRuleSuffix.positiveNumber:
        return [FilteringTextInputFormatter.digitsOnly];
      case InputRuleSuffix.text:
        return null;
    }
    return null;
  }

  String _processValue(String value) {
    switch (widget.rule) {
      case InputRuleSuffix.positiveNumber:
        final num = int.tryParse(value) ?? 0;
        return num < 0 ? '0' : value;

      case InputRuleSuffix.number:
      case InputRuleSuffix.text:
        return value;
    }
  }
}
