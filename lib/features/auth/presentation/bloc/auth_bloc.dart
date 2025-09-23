import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kifiya/features/auth/data/repository/auth_repository.dart';
import 'package:kifiya/features/auth/presentation/bloc/auth_event.dart';
import 'package:kifiya/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthRefreshTokenRequested>(_onRefreshTokenRequested);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthClearError>(_onClearError);
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.register(event.userData);

    result.fold(
      (failure) => emit(AuthError(failure)),
      (user) => emit(AuthRegistrationSuccess(user)),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.login(event.username, event.password);

    result.fold(
      (failure) => emit(AuthError(failure)),
      (loginResponse) => emit(
        AuthAuthenticated(
          user: loginResponse.user,
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
        ),
      ),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
 

    emit(const AuthUnauthenticated());
  }

  Future<void> _onRefreshTokenRequested(
    AuthRefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) return;

    final currentState = state as AuthAuthenticated;

    final result = await _authRepository.refreshToken(event.refreshToken);

    result.fold(
      (failure) => emit(AuthError(failure)),
      (refreshResponse) => emit(
        currentState.copyWith(
          accessToken: refreshResponse.accessToken,
          refreshToken: refreshResponse.refreshToken,
        ),
      ),
    );
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    // Check if user is already authenticated (e.g., from secure storage)
    // This is typically called when the app starts

    // For now, emit unauthenticated
    // In a real app, you would check stored tokens here
    emit(const AuthUnauthenticated());
  }

  void _onClearError(AuthClearError event, Emitter<AuthState> emit) {
    if (state is AuthError) {
      emit(const AuthUnauthenticated());
    }
  }
}
