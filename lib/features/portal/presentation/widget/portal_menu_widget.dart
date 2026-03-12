import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PortalMenuWidget extends StatelessWidget {
  const PortalMenuWidget({
    super.key,
    required this.title,
    required this.route
  });

  final String title, route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: theme.colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(20),
            color: theme.colorScheme.surface,
          ),
          child: Center(
            child: Text(
              title,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}