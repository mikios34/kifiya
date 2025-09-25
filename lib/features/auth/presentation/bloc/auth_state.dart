import 'package:equatable/equatable.dart';
import 'package:kifiya/features/auth/data/model/user_model.dart';
import 'package:kifiya/features/auth/data/repository/auth_repository.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  // final UserModel user;
  final String accessToken;
  final String refreshToken;
  final int userId;
  final String username;

  const AuthAuthenticated({
    // required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.username,
  });

  @override
  List<Object> get props => [accessToken, refreshToken, userId, username];

  AuthAuthenticated copyWith({
    String? accessToken,
    String? refreshToken,
    int? userId,
    String? username,
  }) {
    return AuthAuthenticated(
      // user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userId: userId ?? this.userId,
      username: username ?? this.username,
    );
  }
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final AuthFailure failure;

  const AuthError(this.failure);

  @override
  List<Object> get props => [failure];
}

class AuthRegistrationSuccess extends AuthState {
  final UserModel user;

  const AuthRegistrationSuccess(this.user);

  @override
  List<Object> get props => [user];
}
