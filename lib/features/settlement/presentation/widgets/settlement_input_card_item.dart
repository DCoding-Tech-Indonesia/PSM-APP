import 'package:flutter/material.dart';

class SettlementInputCardItem extends StatelessWidget {
  const SettlementInputCardItem({
    super.key,
    required this.label,
    required this.keyInput,
    this.isRequired = false,
  });

  final String label, keyInput;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
      ),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: 4,
            children: [
              Text(label, style: TextStyle(fontSize: 18),),
              Text(isRequired ? "*" : "", style: TextStyle(color: Colors.redAccent, fontSize: 18),)
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 10
            ),
            decoration: BoxDecoration(
                border: Border.all(
                  width: .2,
                ),
                borderRadius: BorderRadius.circular(2)
            ),
            child: Text("Masukkan total pelajar", style: TextStyle(fontSize: 15, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}