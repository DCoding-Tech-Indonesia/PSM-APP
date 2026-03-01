import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:psm_mobile/features/auth/presentation/auth_screen.dart';
import 'package:psm_mobile/features/auth/presentation/bloc/auth_bloc.dart';

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/login',

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => AuthBloc(),
            child: const AuthScreen(),
          );
        },
      ),
    ],
  );
}
