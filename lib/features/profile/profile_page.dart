import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kifiya/core/theme/app_theme.dart';
import 'package:kifiya/core/widgets/app_button.dart';
import 'package:kifiya/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kifiya/features/auth/presentation/bloc/auth_event.dart';
import 'package:kifiya/features/auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  static const String routeName = '/profilePage';
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTheme.titleStyle),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar Section
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      state.username.isNotEmpty
                          ? state.username[0].toUpperCase()
                          : 'U',
                      style: AppTheme.headingStyle.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Username Section
                  Text(
                    state.username,
                    style: AppTheme.headingStyle.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'User ID: ${state.userId}',
                    style: AppTheme.bodyStyle.copyWith(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Logout Button
                  AppButton(
                    text: 'Logout',
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthLogoutRequested());
                    },
                    backgroundColor: Colors.red.shade600,
                    height: 50,
                  ),
                ],
              ),
            );
          }

          // Show loading or error state
          return const Center(child: Text('Not authenticated'));
        },
      ),
    );
  }
}
