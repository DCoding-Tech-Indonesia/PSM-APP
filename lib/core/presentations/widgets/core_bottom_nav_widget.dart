import 'package:advanced_salomon_bottom_bar/advanced_salomon_bottom_bar.dart';
import 'package:flutter/material.dart';

class CoreBottomNavWidget extends StatelessWidget {
  const CoreBottomNavWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final Function(int) onTap;
  final List<AdvancedSalomonBottomBarItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AdvancedSalomonBottomBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: items,
      ),
    );
  }
}