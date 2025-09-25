import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kifiya/core/theme/app_theme.dart';
import 'package:kifiya/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kifiya/features/auth/presentation/bloc/auth_event.dart';
import 'package:kifiya/injector.dart';
import 'package:kifiya/router.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AuthBloc(locator(), locator())..add(AuthCheckStatus()),
      child: MaterialApp.router(
        title: 'Kifiya',
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
