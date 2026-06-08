import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_state.dart';
import 'portal_dialogs.dart';

class PortalQuickActionsGrid extends StatelessWidget {
  final PortalState state;

  const PortalQuickActionsGrid({super.key, required this.state});

  Widget _buildEnhancedActionCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
    ThemeData theme, {
    bool isAvailable = true,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Tooltip(
          message: isAvailable
              ? 'Klik untuk membuka $title'
              : '$title akan segera hadir',
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? theme.cardTheme.color
                  : isAvailable
                    ? color.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isAvailable
                    ? color.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: isAvailable
                  ? onTap
                  : () {
                      PortalDialogs.showComingSoonDialog(context, title, description);
                    },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? color.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: isAvailable ? color : Colors.grey,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isAvailable
                            ? theme.textTheme.titleMedium?.color
                            : theme.textTheme.titleMedium?.color?.withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isAvailable
                            ? theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7)
                            : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isAvailable) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Coming Soon',
                          style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with description
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.dashboard,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu Utama',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  Text(
                    'Pilih menu yang Anda butuhkan',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Builder(
          builder: (context) {
            if (state is PortalLoading) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ));
            } else if (state is PortalError) {
              return Center(child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text("Gagal mengambil data profil", style: TextStyle(color: Colors.red)),
                    Text((state as PortalError).message, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                ),
              ));
            } else if (state is PortalLoaded) {
              final loadedState = state as PortalLoaded;

              if (kDebugMode) {
                print("DEBUG: Total menu mentah dari API: ${loadedState.profile.menu.length}");
                for (var m in loadedState.profile.menu) {
                  print("DEBUG: Raw Menu -> Title: ${m.title}, Type: '${m.typeMenu}'");
                }
              }

              // Filter menu yang typeMenu-nya null (di model defaultnya string kosong)
              // dan urutkan berdasarkan orderIndex sesuai response API
              final filteredMenus = loadedState.profile.menu
                  .where((menu) => menu.typeMenu.isEmpty)
                  .toList();
              
              if (kDebugMode) {
                print("DEBUG: Total menu setelah difilter (typeMenu == ''): ${filteredMenus.length}");
              }

              filteredMenus.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredMenus.length,
                itemBuilder: (context, index) {
                  final menu = filteredMenus[index];

                  if (kDebugMode) {
                    print("[MENU FILTERED][$index] ${filteredMenus[index].title}");
                    print("[CHILDREN][${filteredMenus[index].title}] ${menu.children.map((e) => e.title).toList()}");
                  }

                  // Dynamic icon mapping based on menu string
                  IconData mappedIcon = Icons.dashboard;
                  Color mappedColor = theme.primaryColor;

                  if (menu.title.toLowerCase().contains("settlement")) {
                    mappedIcon = Icons.account_balance_wallet;
                    mappedColor = Colors.orange;
                  } else if (menu.icon == "mdi-view-dashboard") {
                    mappedIcon = Icons.dashboard;
                  } else if (menu.icon == "mdi-account-cog") {
                    mappedIcon = Icons.manage_accounts;
                  } else if (menu.icon == "mdi-database") {
                    mappedIcon = Icons.storage;
                  } else if (menu.icon == "mdi-cash-multiple") {
                    mappedIcon = Icons.payments;
                  } else if (menu.icon == "mdi-bus-clock") {
                    mappedIcon = Icons.directions_bus;
                  } else if (menu.icon == "mdi-clipboard-account") {
                    mappedIcon = Icons.assignment_ind;
                  } else if (menu.icon == "mdi-poll") {
                    mappedIcon = Icons.poll;
                  } else if (menu.title.toLowerCase().contains("absensi")) {
                    mappedIcon = Icons.fingerprint;
                    mappedColor = Colors.blue;
                  } else {
                    mappedIcon = Icons.menu;
                  }

                  // final isAvailable = menu.route != null && menu.route!.isNotEmpty;
                  final isAvailable = menu.title.toString().isNotEmpty;

                  return _buildEnhancedActionCard(
                    menu.title,
                    "Menu ${menu.title}",
                    mappedIcon,
                    mappedColor,
                    () {
                      if (menu.title.toUpperCase().contains("SETTELMENT")) {
                        context.push('/settlement/dashboard');
                      } else if (menu.title.toLowerCase().contains("absensi") || menu.route == "/attendance") {
                        context.push('/attendance');
                      } else if (menu.title.toUpperCase().contains("KM")) {
                        context.push('/kmbus/dashboard');
                      } else {
                        PortalDialogs.showComingSoonDialog(context, menu.title, "Fitur ini masih dalam pengembangan.");
                      }
                    },
                    theme,
                    isAvailable: isAvailable,
                  );
                },
              );
            }

            return const SizedBox.shrink();
          }
        )
      ],
    );
  }
}
