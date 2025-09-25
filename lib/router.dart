import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kifiya/features/account/presentation/bloc/account_bloc.dart';
import 'package:kifiya/features/auth/presentation/pages/login_page.dart';
import 'package:kifiya/features/auth/presentation/pages/register_page.dart';
import 'package:kifiya/features/account/presentation/pages/accounts_page.dart';
import 'package:kifiya/features/home/presentation/base_page.dart';
import 'package:kifiya/features/home/presentation/pages/home_page.dart';
import 'package:kifiya/features/home/presentation/pages/transfer_page.dart';
import 'package:kifiya/features/profile/profile_page.dart';
import 'package:kifiya/features/transaction/presentation/pages/transactions_page.dart';
import 'package:kifiya/features/splash/splash_scree.dart';
import 'package:kifiya/features/transfer/presentation/bloc/transfer_bloc.dart';
import 'package:kifiya/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:kifiya/injector.dart';

GoRouter appRouter = GoRouter(
  initialLocation: SplashScreen.routeName,
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

    StatefulShellRoute.indexedStack(
      pageBuilder: (context, state, child) => createCustomTransition(
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => AccountBloc(locator())),
          ],
          child: BasePage(navigationShell: child),
        ),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: HomePage.routeName,
              pageBuilder: (context, GoRouterState state) =>
                  createCustomTransition(child: HomePage()),
              routes: [
                GoRoute(
                  path: TransferPage.routeName,
                  name: TransferPage.routeName,
                  pageBuilder: (context, GoRouterState state) =>
                      createCustomTransition(
                        child: BlocProvider(
                          create: (context) => TransferBloc(locator()),
                          child: TransferPage(),
                        ),
                      ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AccountsPage.routeName,
              pageBuilder: (context, GoRouterState state) =>
                  createCustomTransition(child: AccountsPage()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: TransactionsPage.routeName,
              pageBuilder: (context, GoRouterState state) {
                final accountId = int.tryParse(
                  state.uri.queryParameters['accountId'] ?? '',
                );
                return createCustomTransition(
                  child: BlocProvider(
                    create: (context) => TransactionBloc(locator()),
                    child: TransactionsPage(accountId: accountId),
                  ),
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: ProfilePage.routeName,
              pageBuilder: (context, GoRouterState state) =>
                  createCustomTransition(child: ProfilePage()),
            ),
          ],
        ),
      ],
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
