import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:kifiya/features/account/data/api_service/account_api_service.dart';
import 'package:kifiya/features/account/data/model/account_model.dart';

// Abstract repository interface
abstract class AccountRepository {
  Future<Either<AccountFailure, List<AccountModel>>> getAccounts();
  Future<Either<AccountFailure, AccountModel>> getAccountById(int accountId);
  Future<Either<AccountFailure, AccountModel>> createAccount(
    CreateAccountRequest request,
  );
}

// Concrete implementation
class AccountRepositoryImpl implements AccountRepository {
  final AccountApiService _accountApiService;

  AccountRepositoryImpl(this._accountApiService);

  @override
  Future<Either<AccountFailure, List<AccountModel>>> getAccounts() async {
    try {
      final accounts = await _accountApiService.getAccounts();
      return Right(accounts);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(AccountFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AccountFailure, AccountModel>> getAccountById(
    int accountId,
  ) async {
    try {
      final account = await _accountApiService.getAccountById(accountId);
      return Right(account);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(AccountFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AccountFailure, AccountModel>> createAccount(
    CreateAccountRequest request,
  ) async {
    try {
      final account = await _accountApiService.createAccount(request: request);
      return Right(account);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(AccountFailure.unexpected(e.toString()));
    }
  }

  // Helper method to handle Dio errors
  AccountFailure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AccountFailure.networkError();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        switch (statusCode) {
          case 400:
            return AccountFailure.badRequest(data?['message'] ?? 'Bad request');
          case 401:
            return const AccountFailure.unauthorized();
          case 403:
            return const AccountFailure.forbidden();
          case 404:
            return const AccountFailure.notFound();
          case 422:
            return AccountFailure.validationError(
              data?['message'] ?? 'Validation failed',
            );
          case 500:
            return const AccountFailure.serverError();
          default:
            return AccountFailure.unexpected(
              'HTTP $statusCode: ${data?['message'] ?? 'Unknown error'}',
            );
        }
      case DioExceptionType.connectionError:
        return const AccountFailure.networkError();
      case DioExceptionType.cancel:
        return const AccountFailure.cancelled();
      default:
        return AccountFailure.unexpected(
          error.message ?? 'Unknown error occurred',
        );
    }
  }
}

// Failure classes using freezed-like pattern
abstract class AccountFailure {
  const AccountFailure();

  const factory AccountFailure.networkError() = NetworkError;
  const factory AccountFailure.serverError() = ServerError;
  const factory AccountFailure.unauthorized() = Unauthorized;
  const factory AccountFailure.forbidden() = Forbidden;
  const factory AccountFailure.notFound() = NotFound;
  const factory AccountFailure.badRequest(String message) = BadRequest;
  const factory AccountFailure.validationError(String message) =
      ValidationError;
  const factory AccountFailure.cancelled() = Cancelled;
  const factory AccountFailure.unexpected(String message) = Unexpected;
  const factory AccountFailure.insufficientFunds() = InsufficientFunds;
  const factory AccountFailure.accountLocked() = AccountLocked;
}

class NetworkError extends AccountFailure {
  const NetworkError();

  @override
  String toString() => 'Network error occurred';
}

class ServerError extends AccountFailure {
  const ServerError();

  @override
  String toString() => 'Server error occurred';
}

class Unauthorized extends AccountFailure {
  const Unauthorized();

  @override
  String toString() => 'Unauthorized access';
}

class Forbidden extends AccountFailure {
  const Forbidden();

  @override
  String toString() => 'Access forbidden';
}

class NotFound extends AccountFailure {
  const NotFound();

  @override
  String toString() => 'Account not found';
}

class BadRequest extends AccountFailure {
  final String message;

  const BadRequest(this.message);

  @override
  String toString() => 'Bad request: $message';
}

class ValidationError extends AccountFailure {
  final String message;

  const ValidationError(this.message);

  @override
  String toString() => 'Validation error: $message';
}

class Cancelled extends AccountFailure {
  const Cancelled();

  @override
  String toString() => 'Request cancelled';
}

class Unexpected extends AccountFailure {
  final String message;

  const Unexpected(this.message);

  @override
  String toString() => 'Unexpected error: $message';
}

class InsufficientFunds extends AccountFailure {
  const InsufficientFunds();

  @override
  String toString() => 'Insufficient funds';
}

class AccountLocked extends AccountFailure {
  const AccountLocked();

  @override
  String toString() => 'Account is locked';
}
