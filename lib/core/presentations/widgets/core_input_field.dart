import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InputRule { text, number, positiveNumber }

class CoreInputField extends StatelessWidget {
  const CoreInputField({
    super.key,
    required this.label,
    required this.keyInput,
    this.isRequired = false,
    this.hintText = '',
    this.onChanged,
    this.rule = InputRule.text,
    this.isSecured = false,
  });

  final String label;
  final String keyInput;
  final bool isRequired;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final InputRule rule;
  final bool isSecured;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 18)),
              if (isRequired)
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
            onChanged: (value) {
              final processedValue = _processValue(value);
              onChanged?.call(processedValue);
            },
            obscureText: isSecured,
            decoration: InputDecoration(
              hintText: hintText,
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
      ),
    );
  }

  TextInputType _getKeyboardType() {
    switch (rule) {
      case InputRule.number:
      case InputRule.positiveNumber:
        return TextInputType.number;
      case InputRule.text:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (rule) {
      case InputRule.number:
        return [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))];
      case InputRule.positiveNumber:
        return [FilteringTextInputFormatter.digitsOnly];
      case InputRule.text:
        return null;
    }
  }

  String _processValue(String value) {
    switch (rule) {
      case InputRule.positiveNumber:
        final num = int.tryParse(value) ?? 0;
        return num < 0 ? '0' : value;

      case InputRule.number:
      case InputRule.text:
        return value;
    }
  }
}
