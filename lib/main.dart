import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/notification/notification_service.dart';
import 'package:psm_mobile/core/permission/permission_cubit.dart';
import 'package:psm_mobile/core/presentations/cubit/core_tab_cubit.dart';
import 'package:psm_mobile/core/router/app_router.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/core/storage/shared_preferences.dart';
import 'package:psm_mobile/core/theme/app_theme.dart';
import 'package:psm_mobile/features/auth/data/auth_data_source.dart';
import 'package:psm_mobile/features/auth/data/auth_repository_impl.dart';
import 'package:psm_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:psm_mobile/features/portal/data/datasources/portal_data_source.dart';
import 'package:psm_mobile/features/portal/data/repositories/portal_repository_impl.dart';
import 'package:psm_mobile/features/portal/domain/repositories/portal_repository.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    baseUrl: dotenv.env['API_BASE_URL'],
    onUnauthorized: () {
      secureStorage.clearLogin();
      try {
        appRouter.go('/login');
      } catch (e) {
        // Router mungkin belum diinisialisasi saat startup
      }
    },
  );

  // Tentukan rute awal dengan validasi token ke server
  String initialRoute = '/login';
  final token = await secureStorage.readAccessToken();

  if (token != null && token.isNotEmpty) {
    dioClient.setAuthToken(token);
    try {
      // Hit API check-token untuk memastikan sesi masih valid di server
      // Jika token expired, interceptor akan otomatis mencoba refresh terlebih dahulu
      final response = await dioClient.instance.post('/auth/check-token');
      
      if (response.statusCode == 200 && response.data['status'] == true) {
        // Jika valid, simpan token baru (jika ada pembaruan) dan masuk ke portal
        final newData = response.data['data'];
        if (newData is List && newData.isNotEmpty && newData[0]['token'] != null) {
          final newToken = newData[0]['token'];
          await secureStorage.saveAccessToken(newToken);
          dioClient.setAuthToken(newToken);
        }
        initialRoute = '/portal';
      } else {
        await secureStorage.clearLogin();
        initialRoute = '/login';
      }
    } catch (e) {
      // Jika gagal (misal: 401 dan refresh gagal), arahkan ke login
      initialRoute = '/login';
    }
  }

  setupRouter(initialRoute);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SharedPreferencesService>.value(
          value: sharedPreferencesService,
        ),
        RepositoryProvider<SecureStorageService>(create: (_) => SecureStorageService()),
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
                dataSource: PortalDataSource(dio: dioClient.instance)
            ),
        ),
        BlocProvider(create: (_) => CoreTabCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        title: 'PSM Mobile',
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
