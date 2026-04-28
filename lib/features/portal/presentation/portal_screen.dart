import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_bloc.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_state.dart';

import 'bloc/portal_event.dart';
import 'widget/portal_header.dart';
import 'widget/portal_date_time_card.dart';
import 'widget/portal_welcome_banner.dart';
import 'widget/portal_quick_stats_bar.dart';
import 'widget/portal_quick_actions_grid.dart';

class PortalScreen extends StatefulWidget {
  const PortalScreen({super.key});

  @override
  State<PortalScreen> createState() => _PortalScreenState();
}

class _PortalScreenState extends State<PortalScreen> {

  @override
  void initState() {
    super.initState();

    context.read<PortalBloc>().add(PageLoad());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<PortalBloc, PortalState>(
          listenWhen: (previous, current) => previous.logoutSuccess != current.logoutSuccess,
          listener: (context, state) {
            if (state.logoutSuccess) {
              context.go('/login');
            }
          },
          builder: (context, state) {
            String userName = "Pengguna";
            String userEmail = "Loading...";

            if (state is PortalLoaded) {
              userName = state.profile.name ?? state.profile.username ?? "Pengguna";
              userEmail = state.profile.username ?? "";
            }

            return Column(
              children: [
                // Custom Header Section
                PortalHeader(userName: userName, userEmail: userEmail),

                // Date Section at Bottom
                const PortalDateTimeCard(),

                // Welcome Banner
                const PortalWelcomeBanner(),

                // Quick Stats Bar
                const PortalQuickStatsBar(),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dynamic Menu Grid
                        PortalQuickActionsGrid(state: state),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

