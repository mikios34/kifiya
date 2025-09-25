import 'package:dio/dio.dart';
import 'package:kifiya/features/transaction/data/model/transaction_model.dart';

class TransactionApiService {
  final Dio _dio;

  TransactionApiService(this._dio);

  // Get transactions for a specific account with pagination
  Future<TransactionPageResponse> getTransactionsByAccountId({
    required int accountId,
    int page = 0,
    int size = 20,
    String sortBy = 'timestamp',
    String sortDirection = 'desc',
  }) async {
    try {
      print(
        "Getting transactions for account: $accountId, page: $page, size: $size",
      );

      final response = await _dio.get(
        '/api/transactions/$accountId',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': '$sortBy,$sortDirection',
        },
      );

      if (response.statusCode == 200) {
        print("Transaction API response received:");
        print("- Response type: ${response.data.runtimeType}");
        print("- Has content field: ${response.data.containsKey('content')}");
        print("- Empty flag: ${response.data['empty']}");
        print("- Total elements: ${response.data['totalElements']}");
        print("- Sort structure: ${response.data['sort']}");

        try {
          final result = TransactionPageResponse.fromJson(
            response.data as Map<String, dynamic>,
          );
          print("Successfully parsed ${result.content.length} transactions");
          return result;
        } catch (e) {
          print("Error parsing transaction response: $e");
          print("Full response data: ${response.data}");
          rethrow;
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch transactions',
        );
      }
    } on DioException catch (e) {
      print('Get transactions failed: $e');
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/transactions/$accountId'),
        message: 'Failed to fetch transactions: $e',
      );
    }
  }

  // Get specific transaction by ID (if needed for future features)
  Future<TransactionModel> getTransactionById(int transactionId) async {
    try {
      final response = await _dio.get(
        '/api/transactions/detail/$transactionId',
      );

      if (response.statusCode == 200) {
        return TransactionModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch transaction details',
        );
      }
    } on DioException catch (e) {
      print('Get transaction by ID failed: $e');
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/api/transactions/detail/$transactionId',
        ),
        message: 'Failed to fetch transaction details: $e',
      );
    }
  }

  // Get transactions by type filter
  Future<TransactionPageResponse> getTransactionsByType({
    required int accountId,
    required TransactionDirection direction,
    int page = 0,
    int size = 20,
    String sortBy = 'timestamp',
    String sortDirection = 'desc',
  }) async {
    try {
      final response = await _dio.get(
        '/api/transactions/$accountId',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': '$sortBy,$sortDirection',
          'direction': direction.name.toUpperCase(),
        },
      );

      if (response.statusCode == 200) {
        return TransactionPageResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch filtered transactions',
        );
      }
    } on DioException catch (e) {
      print('Get filtered transactions failed: $e');
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/transactions/$accountId'),
        message: 'Failed to fetch filtered transactions: $e',
      );
    }
  }

  // Get transactions for a date range (if needed for future features)
  Future<TransactionPageResponse> getTransactionsByDateRange({
    required int accountId,
    required DateTime startDate,
    required DateTime endDate,
    int page = 0,
    int size = 20,
    String sortBy = 'timestamp',
    String sortDirection = 'desc',
  }) async {
    try {
      final response = await _dio.get(
        '/api/transactions/$accountId',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': '$sortBy,$sortDirection',
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return TransactionPageResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch transactions for date range',
        );
      }
    } on DioException catch (e) {
      print('Get transactions by date range failed: $e');
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/transactions/$accountId'),
        message: 'Failed to fetch transactions for date range: $e',
      );
    }
  }
}
