import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InputRuleSuffixNew { text, number, positiveNumber }

class CoreInputFieldNew extends StatefulWidget {
  final String? label;
  final dynamic widgetSuffix;
  final TextEditingController? controller;
  final String? hintText;
  final bool isRequired;
  final String? initValue;
  final InputRuleSuffixNew rule;
  final ValueChanged<String>? onChanged;
  final bool isSecured;
  final String? errorText;

  const CoreInputFieldNew({
    super.key,
    this.label,
    this.widgetSuffix,
    this.controller,
    this.hintText,
    this.isRequired = false,
    this.initValue,
    this.rule = InputRuleSuffixNew.text,
    this.onChanged,
    this.isSecured = false,
    this.errorText,
  });

  @override
  State<CoreInputFieldNew> createState() => _CoreInputFieldNewState();
}

class _CoreInputFieldNewState extends State<CoreInputFieldNew> {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _controller;
  late bool _isHidden;

  bool get isFocused => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _isHidden = widget.isSecured;
    _focusNode.addListener(() {
      setState(() {});
    });
    _controller = TextEditingController(text: widget.initValue ?? '');
  }

  @override
  void didUpdateWidget(covariant CoreInputFieldNew oldWidget) {
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
    final primaryColor = Colors.blueAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Row(
            children: [
              Text(
                widget.label!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.isRequired)
                const Text(
                  " *",
                  style: TextStyle(color: Colors.redAccent, fontSize: 18),
                ),
            ],
          ),

        const SizedBox(height: 8),

        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.errorText != null
                  ? Colors.redAccent
                  : isFocused
                  ? primaryColor
                  : Colors.grey.shade400,
              width: 1.5,
            ),
            // color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: widget.errorText != null
                    ? Colors.redAccent.withValues(alpha: 0.1)
                    : isFocused
                    ? primaryColor.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  obscureText: _isHidden,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: _getKeyboardType(),
                  inputFormatters: _getInputFormatters(),
                  onChanged: (value) {
                    final processedValue = _processValue(value);
                    debugPrint(
                      "CoreInputFieldNew [${widget.label}] onChanged: $processedValue",
                    );
                    widget.onChanged?.call(processedValue);
                  },
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      top: 14,
                      bottom: 14,
                    ),
                  ),
                ),
              ),

              // Eye icon toggle muncul di sebelah kanan input (di dalam container) hanya saat isSecured true
              // dan tidak ada widgetSuffix di kanan luar
              if (widget.isSecured && widget.widgetSuffix == null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isHidden = !_isHidden;
                      });
                    },
                    child: Icon(
                      _isHidden ? Icons.visibility_off : Icons.visibility,
                      color: isFocused ? primaryColor : Colors.grey.shade500,
                    ),
                  ),
                ),

              // Suffix widget kanan (kotaknya) hanya muncul jika widgetSuffix diberikan
              if (widget.widgetSuffix != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isFocused ? primaryColor : Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  // Jika isSecured & widgetSuffix keduanya ada, tampilkan eye icon di kotak suffix
                  child: widget.isSecured
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _isHidden = !_isHidden;
                            });
                          },
                          child: Icon(
                            _isHidden ? Icons.visibility_off : Icons.visibility,
                            color: isFocused
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        )
                      : widget.widgetSuffix,
                ),
            ],
          ),
        ),

        // Error text
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              widget.errorText!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
      ],
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.rule) {
      case InputRuleSuffixNew.number:
      case InputRuleSuffixNew.positiveNumber:
        return TextInputType.number;
      case InputRuleSuffixNew.text:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (widget.rule) {
      case InputRuleSuffixNew.number:
        return [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))];
      case InputRuleSuffixNew.positiveNumber:
        return [FilteringTextInputFormatter.digitsOnly];
      case InputRuleSuffixNew.text:
        return null;
    }
    return null;
  }

  String _processValue(String value) {
    switch (widget.rule) {
      case InputRuleSuffixNew.positiveNumber:
        final num = int.tryParse(value) ?? 0;
        return num < 0 ? '0' : value;

      case InputRuleSuffixNew.number:
      case InputRuleSuffixNew.text:
        return value;
    }
  }
}
