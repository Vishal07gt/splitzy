import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitzy/core/di/injection_container.dart';
import 'package:splitzy/core/router/app_router.dart';
import 'package:splitzy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  await configureDependencies();
  runApp(
    BlocProvider<AuthCubit>(
      create: (_) => sl<AuthCubit>(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = buildRouter(sl<AuthCubit>());
    return MaterialApp.router(
      title: 'Splitzy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
    );
  }
}
