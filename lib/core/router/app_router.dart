import 'package:go_router/go_router.dart';
import 'package:splitzy/features/auth/presentation/pages/sign_in_screen.dart';
import 'package:splitzy/features/auth/presentation/pages/sign_up_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/signup',
  routes: [
    GoRoute(path: '/signin', builder: (context, state) => const SignInScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
    // GoRoute(
    //   path: '/home',
    //   builder: (context, state) => const HomeScreen(),
    // ),
  ],
);
