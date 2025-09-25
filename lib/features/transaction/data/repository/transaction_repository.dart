import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:kifiya/features/transaction/data/api_service/transaction_api_service.dart';
import 'package:kifiya/features/transaction/data/model/transaction_model.dart';

// Abstract repository interface
abstract class TransactionRepository {
  Future<Either<TransactionFailure, TransactionPageResponse>>
  getTransactionsByAccountId({
    required int accountId,
    int page = 0,
    int size = 20,
    String sortBy = 'timestamp',
    String sortDirection = 'desc',
  });

  Future<Either<TransactionFailure, TransactionModel>> getTransactionById(
    int transactionId,
  );

  Future<Either<TransactionFailure, TransactionPageResponse>>
  getTransactionsByType({
    required int accountId,
    required TransactionDirection direction,
    int page = 0,
    int size = 20,
    String sortBy = 'timestamp',
    String sortDirection = 'desc',
  });

  Future<Either<TransactionFailure, TransactionPageResponse>>
  getTransactionsByDateRange({
    required int accountId,
    required DateTime startDate,
    required DateTime endDate,
    int page = 0,
    int size = 20,
    String sortBy = 'timestamp',
    String sortDirection = 'desc',
  });
}

// Concrete implementation
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionApiService _transactionApiService;

  TransactionRepositoryImpl(this._transactionApiService);

  @override
  Future<Either<TransactionFailure, TransactionPageResponse>>
  getTransactionsByAccountId({
    required int accountId,
    int page = 0,
    int size = 20,
    String sortBy = 'timestamp',
    String sortDirection = 'desc',
  }) async {
    try {
      final response = await _transactionApiService.getTransactionsByAccountId(
        accountId: accountId,
        page: page,
        size: size,
        sortBy: sortBy,
        sortDirection: sortDirection,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(TransactionFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<TransactionFailure, TransactionModel>> getTransactionById(
    int transactionId,
  ) async {
    try {
      final transaction = await _transactionApiService.getTransactionById(
        transactionId,
      );
      return Right(transaction);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(TransactionFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<TransactionFailure, TransactionPageResponse>>
  getTransactionsByType({
    required int accountId,
    required TransactionDirection direction,
    int page = 0,
    int size = 20,
    String sortBy = 'timestamp',
    String sortDirection = 'desc',
  }) async {
    try {
      final response = await _transactionApiService.getTransactionsByType(
        accountId: accountId,
        direction: direction,
        page: page,
        size: size,
        sortBy: sortBy,
        sortDirection: sortDirection,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(TransactionFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<TransactionFailure, TransactionPageResponse>>
  getTransactionsByDateRange({
    required int accountId,
    required DateTime startDate,
    required DateTime endDate,
    int page = 0,
    int size = 20,
    String sortBy = 'timestamp',
    String sortDirection = 'desc',
  }) async {
    try {
      final response = await _transactionApiService.getTransactionsByDateRange(
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
        page: page,
        size: size,
        sortBy: sortBy,
        sortDirection: sortDirection,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(TransactionFailure.unexpected(e.toString()));
    }
  }

  // Helper method to handle Dio errors
  TransactionFailure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TransactionFailure.networkError();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        switch (statusCode) {
          case 400:
            return TransactionFailure.badRequest(
              data?['message'] ?? 'Bad request',
            );
          case 401:
            return const TransactionFailure.unauthorized();
          case 403:
            return const TransactionFailure.forbidden();
          case 404:
            return const TransactionFailure.notFound();
          case 422:
            return TransactionFailure.validationError(
              data?['message'] ?? 'Validation failed',
            );
          case 500:
            return const TransactionFailure.serverError();
          default:
            return TransactionFailure.unexpected(
              'HTTP $statusCode: ${data?['message'] ?? 'Unknown error'}',
            );
        }
      case DioExceptionType.connectionError:
        return const TransactionFailure.networkError();
      case DioExceptionType.cancel:
        return const TransactionFailure.cancelled();
      default:
        return TransactionFailure.unexpected(
          error.message ?? 'Unknown error occurred',
        );
    }
  }
}

// Failure classes using freezed-like pattern
abstract class TransactionFailure {
  const TransactionFailure();

  const factory TransactionFailure.networkError() = NetworkError;
  const factory TransactionFailure.serverError() = ServerError;
  const factory TransactionFailure.unauthorized() = Unauthorized;
  const factory TransactionFailure.forbidden() = Forbidden;
  const factory TransactionFailure.notFound() = NotFound;
  const factory TransactionFailure.badRequest(String message) = BadRequest;
  const factory TransactionFailure.validationError(String message) =
      ValidationError;
  const factory TransactionFailure.cancelled() = Cancelled;
  const factory TransactionFailure.unexpected(String message) = Unexpected;
}

class NetworkError extends TransactionFailure {
  const NetworkError();

  @override
  String toString() => 'Network error occurred';
}

class ServerError extends TransactionFailure {
  const ServerError();

  @override
  String toString() => 'Server error occurred';
}

class Unauthorized extends TransactionFailure {
  const Unauthorized();

  @override
  String toString() => 'Unauthorized access';
}

class Forbidden extends TransactionFailure {
  const Forbidden();

  @override
  String toString() => 'Access forbidden';
}

class NotFound extends TransactionFailure {
  const NotFound();

  @override
  String toString() => 'Transactions not found';
}

class BadRequest extends TransactionFailure {
  final String message;

  const BadRequest(this.message);

  @override
  String toString() => 'Bad request: $message';
}

class ValidationError extends TransactionFailure {
  final String message;

  const ValidationError(this.message);

  @override
  String toString() => 'Validation error: $message';
}

class Cancelled extends TransactionFailure {
  const Cancelled();

  @override
  String toString() => 'Request cancelled';
}

class Unexpected extends TransactionFailure {
  final String message;

  const Unexpected(this.message);

  @override
  String toString() => 'Unexpected error: $message';
}
