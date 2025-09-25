import 'package:dio/dio.dart';
import 'package:kifiya/features/transfer/data/model/transfer_model.dart';

class TransferApiService {
  final Dio _dio;

  TransferApiService(this._dio);

  // Transfer money between accounts
  Future<TransferResponse> transfer({required TransferRequest request}) async {
    try {
      print("Transfer request: $request");
      final response = await _dio.post(
        '/api/accounts/transfer',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TransferResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Transfer failed',
        );
      }
    } on DioException catch (e) {
      print('Transfer failed: $e');
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/accounts/transfer'),
        message: 'Transfer failed: $e',
      );
    }
  }

  // Get transfer history (if needed for future features)
  Future<List<TransferResponse>> getTransferHistory() async {
    try {
      final response = await _dio.get('/api/accounts/transfers');

      if (response.statusCode == 200) {
        final List<dynamic> transfersJson = response.data as List<dynamic>;
        return transfersJson
            .map(
              (json) => TransferResponse.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch transfer history',
        );
      }
    } on DioException catch (e) {
      print('Get transfer history failed: $e');
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/accounts/transfers'),
        message: 'Failed to fetch transfer history: $e',
      );
    }
  }

  // Get transfer by ID (if needed for future features)
  Future<TransferResponse> getTransferById(String transactionId) async {
    try {
      final response = await _dio.get('/api/accounts/transfers/$transactionId');

      if (response.statusCode == 200) {
        return TransferResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch transfer details',
        );
      }
    } on DioException catch (e) {
      print('Get transfer by ID failed: $e');
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/api/accounts/transfers/$transactionId',
        ),
        message: 'Failed to fetch transfer details: $e',
      );
    }
  }
}
