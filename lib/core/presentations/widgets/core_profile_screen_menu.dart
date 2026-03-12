import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CoreProfileScreenMenu extends StatelessWidget {
  const CoreProfileScreenMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("PROFILE DASHBOARD"),
          GestureDetector(
            onTap: () {
              context.go('/portal');
            },
            child: Container(
              decoration: BoxDecoration(color: theme.primaryColor),
              child: Text(
                "Kembali Ke Menu Utama",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
