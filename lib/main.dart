import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/permission/permission_cubit.dart';
import 'package:psm_mobile/core/router/app_router.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/core/storage/shared_preferences.dart';
import 'package:psm_mobile/core/theme/app_theme.dart';
import 'package:psm_mobile/features/auth/data/auth_data_source.dart';
import 'package:psm_mobile/features/auth/data/auth_repository_impl.dart';
import 'package:psm_mobile/features/auth/domain/repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferencesService = SharedPreferencesService();

  await dotenv.load(fileName: ".env");

  await sharedPreferencesService.init();

  final dioClient = DioClient();
  dioClient.init(baseUrl: dotenv.env['API_BASE_URL']);

  runApp(
    MultiRepositoryProvider(
      providers: [
        Provider<SharedPreferencesService>.value(
          value: sharedPreferencesService,
        ),
        Provider<SecureStorageService>(create: (_) => SecureStorageService()),
        RepositoryProvider<AuthRepository>(
            create: (_) => AuthRepositoryImpl(
                dataSource: AuthDataSource(dio: dioClient.instance)
            ),
        ),
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
      ],
      child: Builder(
        builder: (context) {
          final router = createRouter(context);

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'PSM Mobile',
            theme: AppTheme.lightTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
