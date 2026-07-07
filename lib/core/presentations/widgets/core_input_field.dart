import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InputRule { text, number, positiveNumber }

class CoreInputField extends StatefulWidget {
  const CoreInputField({
    super.key,
    required this.label,
    this.isRequired = false,
    this.hintText = '',
    this.onChanged,
    this.rule = InputRule.text,
    this.isSecured = false,
    this.initValue,
  });

  final String label;
  final bool isRequired;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final InputRule rule;
  final bool isSecured;
  final String? initValue;

  @override
  State<CoreInputField> createState() => _CoreInputFieldState();
}

class _CoreInputFieldState extends State<CoreInputField> {
  late bool _isHidden;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _isHidden = widget.isSecured;
    _controller = TextEditingController(text: widget.initValue ?? '');
  }

  @override
  void didUpdateWidget(covariant CoreInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initValue != oldWidget.initValue &&
        widget.initValue != _controller.text) {
      _controller.text = widget.initValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label, style: const TextStyle(fontSize: 18)),
            if (widget.isRequired)
              const Text(
                " *",
                style: TextStyle(color: Colors.redAccent, fontSize: 18),
              ),
          ],
        ),

        const SizedBox(height: 8),

        TextFormField(
          keyboardType: _getKeyboardType(),
          inputFormatters: _getInputFormatters(),
          controller: _controller,
          onChanged: (value) {
            final processedValue = _processValue(value);
            widget.onChanged?.call(processedValue);
          },
          obscureText: _isHidden,
          decoration: InputDecoration(
            suffixIcon: widget.isSecured
                ? IconButton(
                    icon: Icon(
                      _isHidden ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isHidden = !_isHidden;
                      });
                    },
                  )
                : null,
            hintText: widget.hintText,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: .5),
              borderRadius: BorderRadius.circular(4),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.rule) {
      case InputRule.number:
      case InputRule.positiveNumber:
        return TextInputType.number;
      case InputRule.text:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (widget.rule) {
      case InputRule.number:
        return [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))];
      case InputRule.positiveNumber:
        return [FilteringTextInputFormatter.digitsOnly];
      case InputRule.text:
        return null;
    }
    return null;
  }

  String _processValue(String value) {
    switch (widget.rule) {
      case InputRule.positiveNumber:
        final num = int.tryParse(value) ?? 0;
        return num < 0 ? '0' : value;

      case InputRule.number:
      case InputRule.text:
        return value;
    }
  }
}
