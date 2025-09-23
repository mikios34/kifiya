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
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  const AuthAuthenticated({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object> get props => [user, accessToken, refreshToken];

  AuthAuthenticated copyWith({
    UserModel? user,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthAuthenticated(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
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
