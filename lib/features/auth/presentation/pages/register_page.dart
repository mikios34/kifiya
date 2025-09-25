import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kifiya/core/theme/app_theme.dart';
import 'package:kifiya/core/widgets/app_button.dart';
import 'package:kifiya/core/widgets/app_text_field.dart';
import 'package:kifiya/features/auth/data/model/user_model.dart';
import 'package:kifiya/features/auth/presentation/bloc/bloc.dart';
import 'package:kifiya/features/auth/presentation/pages/login_page.dart';
import 'package:kifiya/injector.dart';

class RegisterPage extends StatefulWidget {
  static const String routeName = '/registerPage';
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          } else if (state is AuthRegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful! Please login.'),
                backgroundColor: Colors.green,
              ),
            );
            context.go(LoginPage.routeName);
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
                      Text('Register', style: AppTheme.registerHereStyle),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
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

                            // First Name Field
                            AppTextField(
                              label: 'First Name',
                              hintText: 'please specify your first name',
                              controller: _firstNameController,
                              keyboardType: TextInputType.name,
                              suffixIcon: const Icon(
                                Icons.person_outline,
                                color: AppTheme.iconColor,
                                size: 20,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your first name';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            // Last Name Field
                            AppTextField(
                              label: 'Last Name',
                              hintText: 'please specify your last name',
                              controller: _lastNameController,
                              keyboardType: TextInputType.name,
                              suffixIcon: const Icon(
                                Icons.person_outline,
                                color: AppTheme.iconColor,
                                size: 20,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your last name';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            // Username Field
                            AppTextField(
                              label: 'Username',
                              hintText: 'please enter new username',
                              controller: _usernameController,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a username';
                                }
                                if (value.length < 3) {
                                  return 'Username must be at least 3 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            // Phone Number Field
                            AppTextField(
                              label: 'Phone number',
                              hintText: 'enter a valid phone number',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              suffixIcon: const Icon(
                                Icons.phone_outlined,
                                color: AppTheme.iconColor,
                                size: 20,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                if (value.length < 10) {
                                  return 'Please enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // Email Field
                            AppTextField(
                              label: 'Email',
                              hintText: 'please enter your email address',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              suffixIcon: const Icon(
                                Icons.email_outlined,
                                color: AppTheme.iconColor,
                                size: 20,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email address';
                                }
                                // Simple email validation
                                if (!RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            // Password Field
                            AppTextField(
                              label: 'Password',
                              hintText: 'please create new password',
                              controller: _passwordController,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 60),

                            // Register Button
                            AppButton(
                              text: 'Register',
                              isLoading: state is AuthLoading,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Create user data map

                                  final userData = UserModel(
                                    username: _usernameController.text.trim(),
                                    passwordHash: _passwordController.text,
                                    firstName: _firstNameController.text.trim(),
                                    lastName: _lastNameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    phoneNumber: _phoneController.text.trim(),
                                  );

                                  context.read<AuthBloc>().add(
                                    AuthRegisterRequested(userData),
                                  );
                                }
                              },
                            ),

                            const SizedBox(height: 40),

                            // Login Link
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    "already have an account?",
                                    style: AppTheme.linkTextStyle,
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () {
                                      context.go(LoginPage.routeName);
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
                                      'login',
                                      style: AppTheme.linkActiveTextStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),
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
    );
  }
}
