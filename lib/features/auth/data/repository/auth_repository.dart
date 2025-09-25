import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:kifiya/features/auth/data/api_service/auth_api_service.dart';
import 'package:kifiya/features/auth/data/model/user_model.dart';

// Abstract repository interface
abstract class AuthRepository {
  Future<Either<AuthFailure, UserModel>> register(UserModel userData);
  Future<Either<AuthFailure, LoginResponse>> login(
    String username,
    String password,
  );
  Future<Either<AuthFailure, RefreshTokenResponse>> refreshToken(
    String refreshToken,
  );
}

// Concrete implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _authApiService;

  AuthRepositoryImpl(this._authApiService);

  @override
  Future<Either<AuthFailure, UserModel>> register(UserModel userData) async {
    try {
      final user = await _authApiService.register(userData: userData);
      return Right(user);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(AuthFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, LoginResponse>> login(
    String username,
    String password,
  ) async {
    try {
      final loginResponse = await _authApiService.login(
        username: username,
        password: password,
      );
      return Right(loginResponse);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(AuthFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, RefreshTokenResponse>> refreshToken(
    String refreshToken,
  ) async {
    try {
      final response = await _authApiService.refreshToken(
        refreshToken: refreshToken,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(AuthFailure.unexpected(e.toString()));
    }
  }

  // Helper method to handle Dio errors
  AuthFailure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AuthFailure.networkError();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        switch (statusCode) {
          case 400:
            return AuthFailure.badRequest(data?['message'] ?? 'Bad request');
          case 401:
            return const AuthFailure.unauthorized();
          case 403:
            return const AuthFailure.forbidden();
          case 404:
            return const AuthFailure.notFound();
          case 422:
            return AuthFailure.validationError(
              data?['message'] ?? 'Validation failed',
            );
          case 500:
            return const AuthFailure.serverError();
          default:
            return AuthFailure.unexpected(
              'HTTP $statusCode: ${data?['message'] ?? 'Unknown error'}',
            );
        }
      case DioExceptionType.connectionError:
        return const AuthFailure.networkError();
      case DioExceptionType.cancel:
        return const AuthFailure.cancelled();
      default:
        return AuthFailure.unexpected(
          error.message ?? 'Unknown error occurred',
        );
    }
  }
}

// Failure classes using freezed-like pattern
abstract class AuthFailure {
  const AuthFailure();

  const factory AuthFailure.networkError() = NetworkError;
  const factory AuthFailure.serverError() = ServerError;
  const factory AuthFailure.unauthorized() = Unauthorized;
  const factory AuthFailure.forbidden() = Forbidden;
  const factory AuthFailure.notFound() = NotFound;
  const factory AuthFailure.badRequest(String message) = BadRequest;
  const factory AuthFailure.validationError(String message) = ValidationError;
  const factory AuthFailure.cancelled() = Cancelled;
  const factory AuthFailure.unexpected(String message) = Unexpected;
}

class NetworkError extends AuthFailure {
  const NetworkError();

  @override
  String toString() => 'Network error occurred';
}

class ServerError extends AuthFailure {
  const ServerError();

  @override
  String toString() => 'Server error occurred';
}

class Unauthorized extends AuthFailure {
  const Unauthorized();

  @override
  String toString() => 'Unauthorized access';
}

class Forbidden extends AuthFailure {
  const Forbidden();

  @override
  String toString() => 'Access forbidden';
}

class NotFound extends AuthFailure {
  const NotFound();

  @override
  String toString() => 'Resource not found';
}

class BadRequest extends AuthFailure {
  final String message;

  const BadRequest(this.message);

  @override
  String toString() => 'Bad request: $message';
}

class ValidationError extends AuthFailure {
  final String message;

  const ValidationError(this.message);

  @override
  String toString() => 'Validation error: $message';
}

class Cancelled extends AuthFailure {
  const Cancelled();

  @override
  String toString() => 'Request cancelled';
}

class Unexpected extends AuthFailure {
  final String message;

  const Unexpected(this.message);

  @override
  String toString() => 'Unexpected error: $message';
}
