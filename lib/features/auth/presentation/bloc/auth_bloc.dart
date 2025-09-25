import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kifiya/core/services/token_storage_service.dart';
import 'package:kifiya/features/auth/data/repository/auth_repository.dart';
import 'package:kifiya/features/auth/presentation/bloc/auth_event.dart';
import 'package:kifiya/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final TokenStorageService _tokenStorage;

  AuthBloc(this._authRepository, this._tokenStorage)
    : super(const AuthInitial()) {
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

    await result.fold((failure) async => emit(AuthError(failure)), (
      loginResponse,
    ) async {
      // Save user session (tokens + user info) to secure storage
      await _tokenStorage.saveUserSession(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
        userId: loginResponse.userId,
        username: loginResponse.username,
      );

      // Save user data
      // await _tokenStorage.saveUserData(jsonEncode(loginResponse.user.toJson()));

      emit(
        AuthAuthenticated(
          // user: loginResponse.user,
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
          userId: loginResponse.userId,
          username: loginResponse.username,
        ),
      );
    });
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Clear all stored tokens and user data
    await _tokenStorage.clearAll();

    emit(const AuthUnauthenticated());
  }

  Future<void> _onRefreshTokenRequested(
    AuthRefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) return;

    final currentState = state as AuthAuthenticated;

    final result = await _authRepository.refreshToken(event.refreshToken);

    result.fold((failure) => emit(AuthError(failure)), (refreshResponse) async {
      // Update tokens in storage while preserving user info
      await _tokenStorage.saveUserSession(
        accessToken: refreshResponse.accessToken,
        refreshToken: refreshResponse.refreshToken,
        userId: currentState.userId,
        username: currentState.username,
      );

      emit(
        currentState.copyWith(
          accessToken: refreshResponse.accessToken,
          refreshToken: refreshResponse.refreshToken,
        ),
      );
    });
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    // Check if user is already authenticated from secure storage
    final hasTokens = await _tokenStorage.hasTokens();

    if (hasTokens) {
      try {
        final accessToken = await _tokenStorage.getAccessToken();
        final refreshToken = await _tokenStorage.getRefreshToken();
        final userId = await _tokenStorage.getUserId();
        final username = await _tokenStorage.getUsername();
        // final userDataJson = await _tokenStorage.getUserData();

        if (accessToken != null &&
            refreshToken != null &&
            userId != null &&
            username != null
        // &&
        // userDataJson != null
        ) {
          // final userData = jsonDecode(userDataJson);
          // final user = UserModel.fromJson(userData);

          emit(
            AuthAuthenticated(
              // user: user,
              accessToken: accessToken,
              refreshToken: refreshToken,
              userId: userId,
              username: username,
            ),
          );
          print(
            'AuthAuthenticated with Tokens ${accessToken} and ${refreshToken}, userId: ${userId}, username: ${username}',
          );
          return;
        }
      } catch (e) {
        // Error parsing stored data, clear storage
        await _tokenStorage.clearAll();
      }
    }

    emit(const AuthUnauthenticated());
  }

  void _onClearError(AuthClearError event, Emitter<AuthState> emit) {
    if (state is AuthError) {
      emit(const AuthUnauthenticated());
    }
  }
}
