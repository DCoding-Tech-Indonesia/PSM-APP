import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travis/core/config/app_config.dart';
import 'package:travis/core/network/dio_client.dart';
import 'package:travis/core/notification/notification_service.dart';
import 'package:travis/core/permission/permission_cubit.dart';
import 'package:travis/core/presentations/cubit/core_tab_cubit.dart';
import 'package:travis/core/router/app_router.dart';
import 'package:travis/core/storage/secure_storage.dart';
import 'package:travis/core/storage/shared_preferences.dart';
import 'package:travis/core/theme/app_theme.dart';
import 'package:travis/features/auth/data/auth_data_source.dart';
import 'package:travis/features/auth/data/auth_repository_impl.dart';
import 'package:travis/features/auth/domain/repositories/auth_repository.dart';
import 'package:travis/features/portal/data/datasources/portal_data_source.dart';
import 'package:travis/features/portal/data/repositories/portal_repository_impl.dart';
import 'package:travis/features/portal/domain/repositories/portal_repository.dart';
import 'package:travis/core/error/global_error_handler.dart';
import 'package:travis/features/portal/presentation/bloc/portal_bloc.dart';
import 'package:travis/firebase_options.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase dengan opsi otomatis dari CLI
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Jalankan fungsi notifikasi
  await NotificationService().initNotification();

  // Load tema
  await AppTheme.loadTheme();

  // Request permissions at the very start
  await [
    Permission.notification,
    Permission.locationWhenInUse,
    Permission.camera,
  ].request();

  final sharedPreferencesService = SharedPreferencesService();

  await dotenv.load(fileName: ".env");

  await sharedPreferencesService.init();

  await NotificationServices.initialize();

  final dioClient = DioClient();
  final secureStorage = SecureStorageService();
  dioClient.init(
    baseUrl: AppConfig.apiBaseUrl,
    onUnauthorized: () {
      secureStorage.clearLogin();
      try {
        appRouter.go('/login');
      } catch (e) {
        // Router mungkin belum diinisialisasi saat startup
      }
    },
    onServerError: (statusCode, message) {
      try {
        appRouter.go(
          '/maintenance-error',
          extra: {
            'statusCode': statusCode,
            'errorMessage': message,
          },
        );
      } catch (e) {
        // Router mungkin belum diinisialisasi saat startup
      }
    },
  );

  // Arahkan rute pertama kali ke SplashScreen
  // Pengecekan token sekarang dipindahkan ke dalam SplashScreen agar user bisa melihat animasi
  const String initialRoute = '/splash';
  setupRouter(initialRoute);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SharedPreferencesService>.value(
          value: sharedPreferencesService,
        ),
        RepositoryProvider<SecureStorageService>(
          create: (_) => SecureStorageService(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(
            dataSource: AuthDataSource(
              dio: dioClient.instance,
              secureStorageService: secureStorage,
            ),
          ),
        ),
        RepositoryProvider<PortalRepository>(
          create: (_) => PortalRepositoryImpl(
            dataSource: PortalDataSource(dio: dioClient.instance),
          ),
        ),
        BlocProvider(create: (_) => CoreTabCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    GlobalErrorHandler().serverErrorNotifier.addListener(_handleServerError);
  }

  @override
  void dispose() {
    GlobalErrorHandler().serverErrorNotifier.removeListener(_handleServerError);
    super.dispose();
  }

  void _handleServerError() {
    final error = GlobalErrorHandler().serverErrorNotifier.value;
    if (error != null && mounted) {
      appRouter.go(
        '/maintenance-error',
        extra: {
          'statusCode': error.statusCode,
          'errorMessage': error.message,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PermissionCubit()..checkAndRequestPermissions(),
        ),
        BlocProvider(
          create: (context) => PortalBloc(
            context.read<AuthRepository>(),
            context.read<SecureStorageService>(),
            context.read<PortalRepository>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'TRAVIS',
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
