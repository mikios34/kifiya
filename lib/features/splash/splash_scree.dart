import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kifiya/features/home/presentation/pages/home_page.dart';
import 'package:kifiya/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kifiya/features/auth/presentation/bloc/auth_state.dart';
import 'package:kifiya/features/auth/presentation/pages/login_page.dart';
import 'package:kifiya/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splashPage';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _loadingController;
  late AnimationController _backgroundController;

  late Animation<double> _logoAnimation;
  late Animation<double> _loadingAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize animations
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _backgroundController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _loadingController.repeat();
  }

  @override
  void dispose() {
    // Stop all animations before disposing
    _logoController.stop();
    _loadingController.stop();
    _backgroundController.stop();

    // Dispose controllers
    _logoController.dispose();
    _loadingController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          Future.delayed(const Duration(seconds: 2), () {
            if (state is AuthAuthenticated) {
              context.go(HomePage.routeName);
            }
          });
          if (state is AuthUnauthenticated) {
            context.go(LoginPage.routeName);
          }
        },
        builder: (context, state) {
          return AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.gradientColor1.withOpacity(
                        _backgroundAnimation.value,
                      ),
                      AppTheme.gradientColor2.withOpacity(
                        _backgroundAnimation.value,
                      ),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _logoAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _logoAnimation.value,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // App Logo/Icon
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.account_balance,
                                          size: 60,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    // App Name
                                    Text(
                                      'KIFIYA',
                                      style: AppTheme.loginHereStyle.copyWith(
                                        fontSize: 32,
                                        letterSpacing: 3,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Your Financial Companion',
                                      style: AppTheme.welcomeStyle.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Loading Section
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Loading Animation
                            AnimatedBuilder(
                              animation: _loadingAnimation,
                              builder: (context, child) {
                                return Column(
                                  children: [
                                    // Circular Progress Indicator
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                        backgroundColor: Colors.white
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    const SizedBox(height: 30),

                                    // Loading Text with Animation
                                    AnimatedOpacity(
                                      opacity:
                                          (0.5 + 0.5 * _loadingAnimation.value),
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: Text(
                                        'Loading...',
                                        style: AppTheme.welcomeStyle.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // Loading Dots
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(3, (index) {
                                        return AnimatedContainer(
                                          duration: Duration(
                                            milliseconds: 300 + (index * 100),
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.4 +
                                                  0.6 * _loadingAnimation.value,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Footer
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Text(
                          'Powered by Kifiya',
                          style: AppTheme.welcomeStyle.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
