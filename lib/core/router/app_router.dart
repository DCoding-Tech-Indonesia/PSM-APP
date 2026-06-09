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
import 'package:psm_mobile/features/kmbus/data/kmbus_data_source.dart';
import 'package:psm_mobile/features/kmbus/data/kmbus_repository_impl.dart';
import 'package:psm_mobile/features/kmbus/presentation/bloc/kmbus_bloc.dart';
import 'package:psm_mobile/features/kmbus/presentation/kmbus_screen.dart';
import 'package:psm_mobile/features/kmbus/presentation/kmbus_titik_awal_form_screen.dart';
import 'package:psm_mobile/features/portal/presentation/portal_screen.dart';
import 'package:psm_mobile/features/reference/reference_data_source.dart';
import 'package:psm_mobile/features/settlement/data/settlement_data_source.dart';
import 'package:psm_mobile/features/settlement/data/settlement_repository_impl.dart';
import 'package:psm_mobile/features/settlement/domain/entities/successDraftScreen/settlement_success_args.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_category_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_step_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_tab_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/settlement_form_screen.dart';
import 'package:psm_mobile/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:psm_mobile/features/settlement/presentation/settlement_history_screen.dart';
import 'package:psm_mobile/features/settlement/presentation/settlement_screen.dart';
import 'package:psm_mobile/features/settlement/presentation/settlement_success_submit_draft_screen.dart';
import 'package:psm_mobile/features/timetable/presentation/timetable_screen.dart';

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
                    dataSourceReference: ReferenceDataSource(
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
                    dataSourceReference: ReferenceDataSource(
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
        path: '/settlement/success-draft',
        builder: (context, state) {
          final dio = DioClient().instance;
          final secureStorageService = SecureStorageService();

          final args = state.extra as SettlementSuccessArgs?;

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
                    dataSourceReference: ReferenceDataSource(
                      dio: dio,
                      secureStorageService: secureStorageService,
                    ),
                  ),
                ),
              ),
            ],
            child: SettlementSuccessSubmitDraftScreen(
              idAuditTrail: args?.idAuditTrail,
              totalCust: args?.totalCust,
              totalPayment: args?.totalPayment,
              koridorName: args?.koridorName,
              noPol: args?.noPol,
              ritase: args?.ritase,
            ),
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
                    dataSourceReference: ReferenceDataSource(
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

      // KM BUS ROUTE
      GoRoute(
        path: '/kmbus/dashboard',
        builder: (context, state) {
          final dio = DioClient().instance;
          final secureStorageService = SecureStorageService();

          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => KmbusBloc(
                  KmbusRepositoryImpl(
                    dataSource: KmbusDataSource(
                      dio: dio,
                      secureStorageService: secureStorageService,
                    ),
                    dataSourceReference: ReferenceDataSource(
                      dio: dio,
                      secureStorageService: secureStorageService,
                    ),
                  ),
                ),
              ),
            ],
            child: KmbusScreen(),
          );
        },
      ),
      GoRoute(
        path: '/kmbus/titik-awal/form',
        builder: (context, state) {
          final dio = DioClient().instance;
          final secureStorageService = SecureStorageService();

          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => KmbusBloc(
                  KmbusRepositoryImpl(
                    dataSource: KmbusDataSource(
                      dio: dio,
                      secureStorageService: secureStorageService,
                    ),
                    dataSourceReference: ReferenceDataSource(
                      dio: dio,
                      secureStorageService: secureStorageService,
                    ),
                  ),
                ),
              ),
            ],
            child: KmbusTitikAwalFormScreen(),
          );
        },
      ),

      // TIMETABLE ROUTE
      GoRoute(
        path: '/timetable/dashboard',
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
                    dataSourceReference: ReferenceDataSource(
                      dio: dio,
                      secureStorageService: secureStorageService,
                    ),
                  ),
                ),
              ),
            ],
            child: TimetableScreen(),
          );
        },
      ),

      // CUSTOM ROUTE
      GoRoute(
        path: '/camera',
        builder: (context, state) {
          final extra = state.extra as Map?;

          final ratio = (extra?['ratio'] as double?) ?? (9 / 16);

          return CustomCameraWidget(ratio: ratio);
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
