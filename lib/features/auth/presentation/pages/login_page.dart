import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kifiya/core/theme/app_theme.dart';
import 'package:kifiya/core/widgets/app_button.dart';
import 'package:kifiya/core/widgets/app_text_field.dart';
import 'package:kifiya/features/auth/presentation/bloc/bloc.dart';
import 'package:kifiya/features/auth/presentation/pages/register_page.dart';
import 'package:kifiya/injector.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/loginPage';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(locator()),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColorAuth,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.failure.toString()),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is AuthAuthenticated) {
              // Navigate to home or main screen
              // Navigator.pushReplacementNamed(context, '/home');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Login successful!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Welcome Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    left: 28,
                    right: 28,
                    top: 60,
                    bottom: 40,
                  ),
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundColorAuth,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome', style: AppTheme.welcomeStyle),
                        const SizedBox(height: 8),
                        Text('Login here', style: AppTheme.loginHereStyle),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 40),

                              // Login Icon - Centered
                              Center(
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: AppTheme.loginIconBgColor,
                                    borderRadius: BorderRadius.circular(36),
                                  ),
                                  child: const Icon(
                                    Icons.login,
                                    size: 32,
                                    color: AppTheme.loginIconColor,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 60),

                              // Username Field
                              AppTextField(
                                label: 'Username',
                                hintText: 'please enter your username',
                                controller: _usernameController,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 40),

                              // Password Field
                              AppTextField(
                                label: 'Password',
                                hintText: 'please enter your password',
                                controller: _passwordController,
                                isPassword: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 60),

                              // Login Button
                              AppButton(
                                text: 'Login',
                                isLoading: state is AuthLoading,
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                      AuthLoginRequested(
                                        username: _usernameController.text
                                            .trim(),
                                        password: _passwordController.text,
                                      ),
                                    );
                                  }
                                },
                              ),

                              const SizedBox(height: 40),

                              // Register Link
                              Center(
                                child: Column(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "don't have an account?",
                                      style: AppTheme.linkTextStyle,
                                    ),
                                    const SizedBox(width: 4),
                                    TextButton(
                                      onPressed: () {
                                        context.pushNamed(
                                          RegisterPage.routeName,
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'register',
                                        style: AppTheme.linkActiveTextStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
