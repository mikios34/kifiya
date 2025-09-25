import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:kifiya/features/transfer/data/api_service/transfer_api_service.dart';
import 'package:kifiya/features/transfer/data/model/transfer_model.dart';

// Abstract repository interface
abstract class TransferRepository {
  Future<Either<TransferFailure, TransferResponse>> transfer(
    TransferRequest request,
  );
  Future<Either<TransferFailure, List<TransferResponse>>> getTransferHistory();
  Future<Either<TransferFailure, TransferResponse>> getTransferById(
    String transactionId,
  );
}

// Concrete implementation
class TransferRepositoryImpl implements TransferRepository {
  final TransferApiService _transferApiService;

  TransferRepositoryImpl(this._transferApiService);

  @override
  Future<Either<TransferFailure, TransferResponse>> transfer(
    TransferRequest request,
  ) async {
    try {
      final response = await _transferApiService.transfer(request: request);
      return Right(response);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(TransferFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<TransferFailure, List<TransferResponse>>>
  getTransferHistory() async {
    try {
      final transfers = await _transferApiService.getTransferHistory();
      return Right(transfers);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(TransferFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<TransferFailure, TransferResponse>> getTransferById(
    String transactionId,
  ) async {
    try {
      final transfer = await _transferApiService.getTransferById(transactionId);
      return Right(transfer);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(TransferFailure.unexpected(e.toString()));
    }
  }

  // Helper method to handle Dio errors
  TransferFailure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TransferFailure.networkError();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        switch (statusCode) {
          case 400:
            return TransferFailure.badRequest(
              data?['message'] ?? 'Bad request',
            );
          case 401:
            return const TransferFailure.unauthorized();
          case 403:
            return const TransferFailure.forbidden();
          case 404:
            return const TransferFailure.notFound();
          case 422:
            return TransferFailure.validationError(
              data?['message'] ?? 'Validation failed',
            );
          case 500:
            return const TransferFailure.serverError();
          default:
            return TransferFailure.unexpected(
              'HTTP $statusCode: ${data?['message'] ?? 'Unknown error'}',
            );
        }
      case DioExceptionType.connectionError:
        return const TransferFailure.networkError();
      case DioExceptionType.cancel:
        return const TransferFailure.cancelled();
      default:
        return TransferFailure.unexpected(
          error.message ?? 'Unknown error occurred',
        );
    }
  }
}

// Failure classes using freezed-like pattern
abstract class TransferFailure {
  const TransferFailure();

  const factory TransferFailure.networkError() = NetworkError;
  const factory TransferFailure.serverError() = ServerError;
  const factory TransferFailure.unauthorized() = Unauthorized;
  const factory TransferFailure.forbidden() = Forbidden;
  const factory TransferFailure.notFound() = NotFound;
  const factory TransferFailure.badRequest(String message) = BadRequest;
  const factory TransferFailure.validationError(String message) =
      ValidationError;
  const factory TransferFailure.cancelled() = Cancelled;
  const factory TransferFailure.unexpected(String message) = Unexpected;
  const factory TransferFailure.insufficientFunds() = InsufficientFunds;
  const factory TransferFailure.invalidAccount() = InvalidAccount;
  const factory TransferFailure.transferLimitExceeded() = TransferLimitExceeded;
}

class NetworkError extends TransferFailure {
  const NetworkError();

  @override
  String toString() => 'Network error occurred';
}

class ServerError extends TransferFailure {
  const ServerError();

  @override
  String toString() => 'Server error occurred';
}

class Unauthorized extends TransferFailure {
  const Unauthorized();

  @override
  String toString() => 'Unauthorized access';
}

class Forbidden extends TransferFailure {
  const Forbidden();

  @override
  String toString() => 'Access forbidden';
}

class NotFound extends TransferFailure {
  const NotFound();

  @override
  String toString() => 'Transfer not found';
}

class BadRequest extends TransferFailure {
  final String message;

  const BadRequest(this.message);

  @override
  String toString() => 'Bad request: $message';
}

class ValidationError extends TransferFailure {
  final String message;

  const ValidationError(this.message);

  @override
  String toString() => 'Validation error: $message';
}

class Cancelled extends TransferFailure {
  const Cancelled();

  @override
  String toString() => 'Request cancelled';
}

class Unexpected extends TransferFailure {
  final String message;

  const Unexpected(this.message);

  @override
  String toString() => 'Unexpected error: $message';
}

class InsufficientFunds extends TransferFailure {
  const InsufficientFunds();

  @override
  String toString() => 'Insufficient funds for transfer';
}

class InvalidAccount extends TransferFailure {
  const InvalidAccount();

  @override
  String toString() => 'Invalid account number';
}

class TransferLimitExceeded extends TransferFailure {
  const TransferLimitExceeded();

  @override
  String toString() => 'Transfer limit exceeded';
}
