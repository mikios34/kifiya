import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kifiya/features/auth/presentation/pages/login_page.dart';
import 'package:kifiya/features/auth/presentation/pages/register_page.dart';
import 'package:kifiya/features/splash/splash_scree.dart';

GoRouter appRouter = GoRouter(
  initialLocation: LoginPage.routeName,
  routes: <RouteBase>[
    GoRoute(
      name: SplashScreen.routeName,
      path: SplashScreen.routeName,
      pageBuilder: (context, GoRouterState state) =>
          createCustomTransition(child: SplashScreen()),
    ),
    GoRoute(
      name: LoginPage.routeName,
      path: LoginPage.routeName,
      pageBuilder: (context, GoRouterState state) =>
          createCustomTransition(child: LoginPage()),
    ),

    GoRoute(
      name: RegisterPage.routeName,
      path: RegisterPage.routeName,
      pageBuilder: (context, GoRouterState state) =>
          createCustomTransition(child: RegisterPage()),
    ),
  ],
);

CustomTransitionPage<T> createCustomTransition<T>({
  required Widget child,
  LocalKey? key,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation.drive(
          Tween<double>(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: Curves.easeInOut), // Smoother animation
          ),
        ),
        child: child,
      );
    },
  );
}
