import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/presentations/cubit/core_tab_cubit.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/core/router/route_observer.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/core/storage/shared_preferences.dart';
import 'package:psm_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:psm_mobile/features/auth/presentation/auth_screen.dart';
import 'package:psm_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:psm_mobile/features/portal/presentation/portal_screen.dart';
import 'package:psm_mobile/features/settlement/data/settlement_data_source.dart';
import 'package:psm_mobile/features/settlement/data/settlement_repository_impl.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_category_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_step_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_tab_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/settlement_form_screen.dart';
import 'package:psm_mobile/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:psm_mobile/features/settlement/presentation/settlement_history_screen.dart';
import 'package:psm_mobile/features/settlement/presentation/settlement_screen.dart';

late final GoRouter appRouter;

void setupRouter(String initialLocation) {
  appRouter = GoRouter(
    initialLocation: initialLocation,
    observers: [routeObserver],

    routes: [
      // AUTH ROUTE
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final secureStorageService = context.read<SecureStorageService>();
          final sharedPreferencesService = context
              .read<SharedPreferencesService>();
          final authRepository = context.read<AuthRepository>();

          return BlocProvider(
            create: (_) => AuthBloc(
              secureStorageService,
              sharedPreferencesService,
              authRepository,
            ),
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
          final dio = DioClient().instance;
          final secureStorageService = SecureStorageService();

          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => CoreTabCubit()),
              BlocProvider(
                create: (_) => SettlementBloc(
                  SettlementRepositoryImpl(
                    dataSource: SettlementDataSource(
                      dio: dio,
                      secureStorageService: secureStorageService,
                    ),
                  ),
                ),
              ),
            ],
            child: SettlementScreen(),
          );
        },
      ),
      GoRoute(
        path: '/settlement/form',
        builder: (context, state) {
          final dio = DioClient().instance;
          final secureStorageService = SecureStorageService();

          final idAuditTrail = state.extra as int?;

          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => SettlementTabCubit()),
              BlocProvider(create: (_) => SettlementCategoryCubit()),
              BlocProvider(create: (_) => SettlementStepCubit()),
              BlocProvider(
                create: (_) => SettlementBloc(
                  SettlementRepositoryImpl(
                    dataSource: SettlementDataSource(
                      dio: dio,
                      secureStorageService: secureStorageService,
                    ),
                  ),
                ),
              ),
            ],
            child: SettlementFormScreen(idAuditTrail: idAuditTrail),
          );
        },
      ),
      GoRoute(
        path: '/settlement/history',
        builder: (context, state) {
          final dio = DioClient().instance;
          final secureStorageService = SecureStorageService();

          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => SettlementBloc(
                  SettlementRepositoryImpl(
                    dataSource: SettlementDataSource(
                      dio: dio,
                      secureStorageService: secureStorageService,
                    ),
                  ),
                ),
              ),
            ],
            child: SettlementHistoryScreen(),
          );
        },
      ),

      // CUSTOM ROUTE
      GoRoute(
        path: '/camera',
        builder: (context, state) {
          final extra = state.extra as Map;

          final ratio = extra['ratio'] as double;
          final settlementBloc = extra['bloc'] as SettlementBloc;

          return BlocProvider.value(
            value: settlementBloc,
            child: CustomCameraWidget(ratio: ratio),
          );
        },
      ),
      GoRoute(
        path: '/attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/widget-demo',
        builder: (context, state) => const WidgetDemoScreen(),
      ),
    ],
  );
}
