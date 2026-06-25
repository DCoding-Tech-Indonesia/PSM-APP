import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/presentations/cubit/core_tab_cubit.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/core/router/route_observer.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/core/storage/shared_preferences.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/leave_request_event.dart';
import 'package:psm_mobile/features/attendance/presentation/screens/approval_detail_screen.dart';
import 'package:psm_mobile/features/attendance/presentation/screens/approval_screen.dart';
import 'package:psm_mobile/features/attendance/presentation/screens/schedule_calendar_screen.dart';
import 'package:psm_mobile/features/attendance/data/models/schedule_model.dart';
import 'package:psm_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:psm_mobile/features/auth/presentation/auth_screen.dart';
import 'package:psm_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:psm_mobile/features/checklist/presentation/checklist_screen.dart';
import 'package:psm_mobile/features/checklist/presentation/screens/checklist_input_screen.dart';
import 'package:psm_mobile/features/kmbus/data/kmbus_data_source.dart';
import 'package:psm_mobile/features/kmbus/data/kmbus_repository_impl.dart';
import 'package:psm_mobile/features/kmbus/presentation/bloc/kmbus_bloc.dart';
import 'package:psm_mobile/features/kmbus/presentation/kmbus_history_screen.dart';
import 'package:psm_mobile/features/kmbus/presentation/kmbus_screen.dart';
import 'package:psm_mobile/features/kmbus/presentation/kmbus_titik_awal_form_screen.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_bloc.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_state.dart';
import 'package:psm_mobile/features/portal/presentation/portal_screen.dart';
import 'package:psm_mobile/features/reference/reference_data_source.dart';
import 'package:psm_mobile/features/settlement/data/settlement_data_source.dart';
import 'package:psm_mobile/features/settlement/data/settlement_repository_impl.dart';
import 'package:psm_mobile/features/settlement/domain/entities/detailSettlementScreen/detail_screen_args.dart';
import 'package:psm_mobile/features/settlement/domain/entities/successDraftScreen/settlement_success_args.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_category_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_step_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/cubit/settlement_tab_cubit.dart';
import 'package:psm_mobile/features/settlement/presentation/settlement_detail_screen.dart';
import 'package:psm_mobile/features/settlement/presentation/settlement_form_screen.dart';
import 'package:psm_mobile/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:psm_mobile/features/attendance/presentation/screens/leave_request_screen.dart';
import 'package:psm_mobile/features/attendance/presentation/screens/shift_replacement_screen.dart';
import 'package:psm_mobile/features/attendance/data/datasources/leave_request_remote_data_source.dart';
import 'package:psm_mobile/features/attendance/data/repositories/leave_request_repository_impl.dart';
import 'package:psm_mobile/features/attendance/presentation/screens/history_screen.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/leave_request_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/settlement_history_screen.dart';
import 'package:psm_mobile/features/settlement/presentation/settlement_screen.dart';
import 'package:psm_mobile/features/settlement/presentation/settlement_success_submit_draft_screen.dart';
import 'package:psm_mobile/features/splash/presentation/splash_screen.dart';
import 'package:psm_mobile/features/spm/presentation/screens/spm_detail_screen.dart';
import 'package:psm_mobile/features/spm/presentation/screens/spm_input_screen.dart';
import 'package:psm_mobile/features/spm/presentation/screens/spm_screen.dart';
import 'package:psm_mobile/features/timetable/data/timetable_data_source.dart';
import 'package:psm_mobile/features/timetable/data/timetable_repository_impl.dart';
import 'package:psm_mobile/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:psm_mobile/features/timetable/presentation/timetable_history_screen.dart';
import 'package:psm_mobile/features/timetable/presentation/timetable_screen.dart';

late final GoRouter appRouter;

void setupRouter(String initialLocation) {
  appRouter = GoRouter(
    initialLocation: initialLocation,
    observers: [routeObserver],

    routes: [
      // SPLASH ROUTE
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

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
                    dataSourceReference: ReferenceDataSource(dio: dio),
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
                    dataSourceReference: ReferenceDataSource(dio: dio),
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
                    dataSourceReference: ReferenceDataSource(dio: dio),
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
                    dataSourceReference: ReferenceDataSource(dio: dio),
                  ),
                ),
              ),
            ],
            child: SettlementHistoryScreen(),
          );
        },
      ),
      GoRoute(
        path: '/settlement/detail',
        builder: (context, state) {
          final dio = DioClient().instance;
          final secureStorageService = SecureStorageService();

          final args = state.extra as DetailScreenArgs;

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
                    dataSourceReference: ReferenceDataSource(dio: dio),
                  ),
                ),
              ),
            ],
            child: SettlementDetailScreen(
              idAuditTrail: args.idAuditTrail!,
              statusName: args.statusName!,
            ),
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
                    dataSourceReference: ReferenceDataSource(dio: dio),
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
                    dataSourceReference: ReferenceDataSource(dio: dio),
                  ),
                ),
              ),
            ],
            child: KmbusTitikAwalFormScreen(),
          );
        },
      ),
      GoRoute(
        path: '/kmbus/history',
        builder: (context, state) {
          return KmbusHistoryScreen();
          // final dio = DioClient().instance;
          // final secureStorageService = SecureStorageService();

          // return MultiBlocProvider(
          //   providers: [
          //     BlocProvider(
          //       create: (_) => SettlementBloc(
          //         SettlementRepositoryImpl(
          //           dataSource: SettlementDataSource(
          //             dio: dio,
          //             secureStorageService: secureStorageService,
          //           ),
          //           dataSourceReference: ReferenceDataSource(dio: dio),
          //         ),
          //       ),
          //     ),
          //   ],
          //   child: SettlementHistoryScreen(),
          // );
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
              BlocProvider(
                create: (_) => TimetableBloc(
                  TimetableRepositoryImpl(
                    dataSource: TimetableDataSource(dio: dio),
                    dataSourceReference: ReferenceDataSource(dio: dio),
                  ),
                  secureStorageService,
                ),
              ),
            ],
            child: const TimetableScreen(),
          );
        },
      ),
      GoRoute(
        path: '/timetable/history',
        builder: (context, state) {
          return TimetableHistoryScreen();
          // final dio = DioClient().instance;
          // final secureStorageService = SecureStorageService();

          // return MultiBlocProvider(
          //   providers: [
          //     BlocProvider(
          //       create: (_) => SettlementBloc(
          //         SettlementRepositoryImpl(
          //           dataSource: SettlementDataSource(
          //             dio: dio,
          //             secureStorageService: secureStorageService,
          //           ),
          //           dataSourceReference: ReferenceDataSource(dio: dio),
          //         ),
          //       ),
          //     ),
          //   ],
          //   child: SettlementHistoryScreen(),
          // );
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

      // ATTENDANCE & APPROVAL ROUTE
      GoRoute(
        path: '/leave-request',
        builder: (context, state) {
          final portalState = context.read<PortalBloc>().state;
          int userId = 0;
          if (portalState is PortalLoaded) {
            userId = int.tryParse(portalState.profile.id) ?? 0;
          }

          return BlocProvider(
            create: (context) => LeaveRequestBloc(
              repository: LeaveRequestRepositoryImpl(
                remoteDataSource: LeaveRequestRemoteDataSourceImpl(DioClient()),
              ),
            )..add(LoadLeaveRequestList(userId: userId)),
            child: const LeaveRequestScreen(),
          );
        },
      ),
      GoRoute(
        path: '/attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/approval',
        builder: (context, state) => const ApprovalScreen(),
      ),
      GoRoute(
        path: '/approval-detail',
        builder: (context, state) {
          final idStr = state.extra?.toString();
          return ApprovalDetailScreen(id: idStr);
        },
      ),
      GoRoute(
        path: '/schedule-calendar',
        builder: (context, state) {
          final userId = state.extra as String? ?? '';
          return ScheduleCalendarScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          final userId = args['userId'] as String? ?? '';
          return HistoryScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/shift-replacement',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ShiftReplacementScreen(
            schedules: extra['schedules'] as List<ScheduleModel>,
            requesterId: extra['requesterId'] as int,
            onFetchReplacementSchedules:
                extra['onFetchReplacementSchedules']
                    as Future<List<dynamic>> Function(int),
            onRequestShiftReplacement:
                extra['onRequestShiftReplacement']
                    as Future<bool> Function({
                      required int requesterId,
                      required int replacementId,
                      required int jadwalId,
                      required String alasan,
                    }),
          );
        },
      ),

      // SPM ROUTE
      GoRoute(path: '/spm', builder: (context, state) => const SpmScreen()),
      GoRoute(
        path: '/spm/input',
        builder: (context, state) => const SpmInputScreen(),
      ),
      GoRoute(
        path: '/spm/detail',
        builder: (context, state) {
          final taskId = state.extra as int;
          return SpmDetailScreen(taskId: taskId);
        },
      ),

      // CHECKLIST ROUTE
      GoRoute(
        path: '/checklist',
        builder: (context, state) => const ChecklistScreen(),
      ),
      GoRoute(
        path: '/checklist/input',
        builder: (context, state) => const ChecklistInputScreen(),
      ),

      // WIDGET DEMO ROUTE
      GoRoute(
        path: '/widget-demo',
        builder: (context, state) => const WidgetDemoScreen(),
      ),
    ],
  );
}
