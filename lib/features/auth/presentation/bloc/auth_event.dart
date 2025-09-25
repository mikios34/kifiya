import 'package:equatable/equatable.dart';
import 'package:kifiya/features/auth/data/model/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthRegisterRequested extends AuthEvent {
  final UserModel userData;

  const AuthRegisterRequested(this.userData);

  @override
  List<Object> get props => [userData];
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthRefreshTokenRequested extends AuthEvent {
  final String refreshToken;

  const AuthRefreshTokenRequested(this.refreshToken);

  @override
  List<Object> get props => [refreshToken];
}

class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

class AuthClearError extends AuthEvent {
  const AuthClearError();
}
