import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:splitzy/core/router/go_router_refresh_stream.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:splitzy/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:splitzy/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:splitzy/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:splitzy/features/friends/presentation/cubit/incoming_requests_cubit.dart';
import 'package:splitzy/features/friends/presentation/cubit/search_cubit.dart';
import 'package:splitzy/features/friends/presentation/pages/friends_page.dart';
import 'package:splitzy/features/friends/presentation/pages/request_page.dart';
import 'package:splitzy/features/friends/presentation/pages/search_page.dart';

import '../../core/di/injection_container.dart';

GoRouter buildRouter(AuthCubit authCubit) => GoRouter(
      initialLocation: '/signin',
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      redirect: (context, routerState) {
        final s = authCubit.state;
        final isLoggedIn = s is Success<User?> && s.data != null;
        final isLoading = s is Progress<User?>;
        final isAuthRoute = routerState.matchedLocation == '/signin' ||
            routerState.matchedLocation == '/signup';

        if (isLoading) return null;
        if (isLoggedIn && isAuthRoute) return '/home';
        if (!isLoggedIn && !isAuthRoute) return '/signin';
        return null;
      },
      routes: [
        GoRoute(
          path: '/signin',
          builder: (ctx, state) => const SignInScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (ctx, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (ctx, state) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<FriendsCubit>()),
              BlocProvider(create: (_) => sl<IncomingRequestsCubit>()),
            ],
            child: const FriendsPage(),
          ),
        ),
        GoRoute(
          path: '/friends',
          builder: (ctx, state) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<FriendsCubit>()),
              BlocProvider(create: (_) => sl<IncomingRequestsCubit>()),
            ],
            child: const FriendsPage(),
          ),
          routes: [
            GoRoute(
              path: 'search',
              builder: (ctx, state) => BlocProvider(
                create: (_) => sl<SearchCubit>(),
                child: const SearchPage(),
              ),
            ),
            GoRoute(
              path: 'requests',
              builder: (ctx, state) => BlocProvider(
                create: (_) => sl<IncomingRequestsCubit>(),
                child: const RequestsPage(),
              ),
            ),
          ],
        ),
      ],
    );
