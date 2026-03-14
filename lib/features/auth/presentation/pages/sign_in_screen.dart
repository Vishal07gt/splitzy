import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/core/utils/form_validators.dart';
import 'package:splitzy/core/widgets/app_text_form_field.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_in_with_credentials_usecase.dart';
import 'package:splitzy/features/auth/presentation/cubit/auth_cubit.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(SignInParams(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, UiStates<User?>>(
      listener: (context, state) {
        if (state is Error<User?>) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: SelectableText(state.message)),
          );
        }
        // Navigation handled by GoRouter redirect
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Sign In',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    AppTextFormField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: FormValidators.email,
                    ),
                    const SizedBox(height: 20),
                    AppTextFormField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock,
                      obscureText: _obscurePassword,
                      validator: FormValidators.password,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<AuthCubit, UiStates<User?>>(
                      builder: (context, state) {
                        final isLoading = state is Progress<User?>;
                        return FilledButton(
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Sign In'),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: const Text("Don't have an account? Sign Up"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
