import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitzy/core/router/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// ConsumerWidget so we can ref.watch the router provider
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch gives us the actual GoRouter instance
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Splitzy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router, // ← actual GoRouter, not the provider
    );
  }
}