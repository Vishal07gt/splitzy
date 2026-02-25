import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitzy/core/di/injection.dart';
import 'package:splitzy/core/router/app_router.dart';
import 'package:splitzy/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: AppConstants.SUPABASE_URL, anonKey: AppConstants.SUPABASE_ANON_KEY);
  setupInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: MaterialApp.router(
        title: 'Splitzy',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
