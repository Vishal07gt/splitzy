import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:splitzy/core/router/go_router_refresh_stream.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:splitzy/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:splitzy/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:splitzy/features/expenses/presentation/cubit/expense_detail_cubit.dart';
import 'package:splitzy/features/expenses/presentation/cubit/expenses_cubit.dart';
import 'package:splitzy/features/expenses/presentation/pages/add_expense_page.dart';
import 'package:splitzy/features/expenses/presentation/pages/expense_detail_page.dart';
import 'package:splitzy/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:splitzy/features/friends/presentation/cubit/incoming_requests_cubit.dart';
import 'package:splitzy/features/friends/presentation/cubit/search_cubit.dart';
import 'package:splitzy/features/friends/presentation/pages/friends_page.dart';
import 'package:splitzy/features/friends/presentation/pages/request_page.dart';
import 'package:splitzy/features/friends/presentation/pages/search_page.dart';
import 'package:splitzy/features/groups/presentation/cubit/group_detail_cubit.dart';
import 'package:splitzy/features/groups/presentation/cubit/groups_cubit.dart';
import 'package:splitzy/features/groups/presentation/pages/add_member_page.dart';
import 'package:splitzy/features/groups/presentation/pages/create_group_page.dart';
import 'package:splitzy/features/groups/presentation/pages/group_detail_page.dart';
import 'package:splitzy/features/groups/presentation/pages/groups_page.dart';
import 'package:splitzy/features/settlements/presentation/cubit/settlements_cubit.dart';
import 'package:splitzy/features/settlements/presentation/pages/settlements_page.dart';

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
          builder: (ctx, state) => BlocProvider(
            create: (_) => sl<GroupsCubit>()..loadGroups(),
            child: const GroupsPage(),
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
              builder: (ctx, state) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => sl<SearchCubit>()),
                  BlocProvider(create: (_) => sl<FriendsCubit>()),
                ],
                child: const SearchPage(),
              ),
            ),
            GoRoute(
              path: 'requests',
              builder: (ctx, state) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => sl<FriendsCubit>()),
                  BlocProvider(create: (_) => sl<IncomingRequestsCubit>()),
                ],
                child: const RequestsPage(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/groups/create',
          builder: (ctx, state) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<GroupsCubit>()),
              BlocProvider(create: (_) => sl<FriendsCubit>()),
            ],
            child: const CreateGroupPage(),
          ),
        ),
        GoRoute(
          path: '/groups/:groupId',
          builder: (ctx, state) {
            final groupId = state.pathParameters['groupId']!;
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) =>
                      sl<GroupDetailCubit>()..loadGroup(groupId),
                ),
                BlocProvider(
                  create: (_) =>
                      sl<ExpensesCubit>()..loadExpenses(groupId),
                ),
                BlocProvider(
                  create: (_) =>
                      sl<SettlementsCubit>()..loadSettlements(groupId),
                ),
              ],
              child: GroupDetailPage(groupId: groupId),
            );
          },
          routes: [
            GoRoute(
              path: 'add-member',
              builder: (ctx, state) {
                final groupId = state.pathParameters['groupId']!;
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) =>
                          sl<GroupDetailCubit>()..loadGroup(groupId),
                    ),
                    BlocProvider(create: (_) => sl<FriendsCubit>()),
                  ],
                  child: AddMemberPage(groupId: groupId),
                );
              },
            ),
            GoRoute(
              path: 'add-expense',
              builder: (ctx, state) {
                final groupId = state.pathParameters['groupId']!;
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) =>
                          sl<GroupDetailCubit>()..loadGroup(groupId),
                    ),
                    BlocProvider(
                      create: (_) =>
                          sl<ExpensesCubit>()..loadExpenses(groupId),
                    ),
                  ],
                  child: AddExpensePage(groupId: groupId),
                );
              },
            ),
            GoRoute(
              path: 'expenses/:expenseId',
              builder: (ctx, state) {
                final expenseId = state.pathParameters['expenseId']!;
                return BlocProvider(
                  create: (_) =>
                      sl<ExpenseDetailCubit>()..loadExpense(expenseId),
                  child: ExpenseDetailPage(expenseId: expenseId),
                );
              },
            ),
            GoRoute(
              path: 'settlements',
              builder: (ctx, state) {
                final groupId = state.pathParameters['groupId']!;
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) =>
                          sl<GroupDetailCubit>()..loadGroup(groupId),
                    ),
                    BlocProvider(
                      create: (_) =>
                          sl<ExpensesCubit>()..loadExpenses(groupId),
                    ),
                    BlocProvider(
                      create: (_) =>
                          sl<SettlementsCubit>()
                            ..loadSettlements(groupId),
                    ),
                  ],
                  child: SettlementsPage(groupId: groupId),
                );
              },
            ),
          ],
        ),
      ],
    );
