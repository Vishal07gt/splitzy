import 'package:flutter/material.dart';
import 'package:splitzy/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://xzoupptvzbztyfaplnta.supabase.co',
    anonKey: 'sb_publishable_gd4JwA2eb8COI-hWwkKdFQ_xkIo6lHz',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const SignUpScreen(),
    );
  }
}
