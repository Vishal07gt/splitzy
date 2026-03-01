import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitzy/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:splitzy/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:splitzy/features/auth/presentation/providers/auth_notifier.dart';

// TODO: import HomeScreen when ready
// import 'package:splitzy/features/home/presentation/pages/home_screen.dart';

part 'app_router.g.dart';

// GoRouter as a Riverpod provider so it can watch auth state
@riverpod
GoRouter appRouter(AppRouterRef ref) {
  // Watch auth state — router refreshes when auth changes
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/signin',
    // Redirect logic runs on every navigation attempt
    redirect: (context, routerState) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoading  = authState.isLoading;
      final isAuthRoute = routerState.matchedLocation == '/signin' ||
          routerState.matchedLocation == '/signup';

      // Still checking auth — don't redirect yet
      if (isLoading) return null;

      // Logged in but on auth page → go home
      if (isLoggedIn && isAuthRoute) return '/home';

      // Not logged in and not on auth page → go to signin
      if (!isLoggedIn && !isAuthRoute) return '/signin';

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/home',
        // Replace with HomeScreen() when ready
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Home — coming soon')),
        ),
      ),
    ],
  );
}