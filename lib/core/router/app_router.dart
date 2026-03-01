import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:psm_mobile/features/auth/presentation/auth_screen.dart';
import 'package:psm_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:psm_mobile/features/portal/presentation/portal_screen.dart';

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/portal',

    routes: [
      GoRoute(
        path: '/portal',
        builder: (context, state) {
          return const PortalScreen();
        },
      ),
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
