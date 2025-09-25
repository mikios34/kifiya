import 'package:dio/dio.dart';
import 'package:kifiya/features/account/data/model/account_model.dart';

class AccountApiService {
  final Dio _dio;

  AccountApiService(this._dio);

  // Get all accounts for the current user
  Future<List<AccountModel>> getAccounts() async {
    try {
      final response = await _dio.get('/api/accounts');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;
        final List<dynamic> accountsJson =
            responseData['content'] as List<dynamic>;
        return accountsJson
            .map((json) => AccountModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch accounts',
        );
      }
    } on DioException catch (e) {
      print('Get accounts failed: $e');
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/accounts'),
        message: 'Failed to fetch accounts: $e',
      );
    }
  }

  // Get account by ID
  Future<AccountModel> getAccountById(int accountId) async {
    try {
      final response = await _dio.get('/api/accounts/$accountId');

      if (response.statusCode == 200) {
        return AccountModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch account',
        );
      }
    } on DioException catch (e) {
      print('Get account by ID failed: $e');
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/accounts/$accountId'),
        message: 'Failed to fetch account: $e',
      );
    }
  }

  // Create new account
  Future<AccountModel> createAccount({
    required CreateAccountRequest request,
  }) async {
    try {
      print("Create account request: $request");
      final response = await _dio.post('/api/accounts', data: request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AccountModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to create account',
        );
      }
    } on DioException catch (e) {
      print('Create account failed: $e');
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/accounts'),
        message: 'Failed to create account: $e',
      );
    }
  }
}
