import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/presentations/cubit/core_tab_cubit.dart';
import 'package:psm_mobile/core/presentations/widgets/custom_camera_widget.dart';
import 'package:psm_mobile/features/auth/presentation/auth_screen.dart';
import 'package:psm_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_category_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_step_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_tab_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/settlement_dashboard_screen.dart';
import 'package:psm_mobile/features/settlement/presentation/settlement_add_screen.dart';
import 'package:psm_mobile/features/portal/presentation/portal_screen.dart';

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/login',

    routes: [
      // AUTH ROUTE
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => AuthBloc(),
            child: const AuthScreen(),
          );
        },
      ),

      // PORTAL ROUTE
      GoRoute(
        path: '/portal',
        builder: (context, state) {
          return const PortalScreen();
        },
      ),

      // SETTLEMENT ROUTE
      GoRoute(
        path: '/settlement/dashboard',
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [BlocProvider(create: (_) => CoreTabCubit())],
            child: const SettlementDashboardScreen(),
          );
        },
      ),
      GoRoute(
        path: '/settlement/add',
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => SettlementTabCubit()),
              BlocProvider(create: (_) => SettlementCategoryCubit()),
              BlocProvider(create: (_) => SettlementStepCubit()),
              BlocProvider(create: (_) => SettlementBloc()),
            ],
            child: const SettlementAddScreen(),
          );
        },
      ),

      // CUSTOM ROUTE
      GoRoute(
        path: '/camera',
        builder: (context, state) {

          final ratio = state.extra as double? ?? 1;

          return CustomCameraWidget(
            ratio: ratio,
          );
        },
      ),
    ],
  );
}
