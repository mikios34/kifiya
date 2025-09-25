import 'package:dio/dio.dart';
import 'package:kifiya/features/auth/data/model/user_model.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  // Register endpoint
  Future<UserModel> register({required UserModel userData}) async {
    try {
      print("userData $userData");
      final response = await _dio.post(
        '/api/auth/register',
        data: userData.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Registration failed',
        );
      }
    } on DioException catch (e) {
      print(
        'Registration failed ${DioException(
          requestOptions: RequestOptions(path: '/api/auth/register'),
          message: 'Registration failed: $e',
        )}',
      );
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/auth/register'),
        message: 'Registration failed: $e',
      );
    }
  }

  // Login endpoint
  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'username': username, 'passwordHash': password},
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Login failed',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        message: 'Login failed: $e',
      );
    }
  }

  // Refresh token endpoint
  Future<RefreshTokenResponse> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        return RefreshTokenResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Token refresh failed',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/auth/refresh-token'),
        message: 'Token refresh failed: $e',
      );
    }
  }
}

// Response models for API endpoints
class LoginResponse {
  // final UserModel user;
  final String accessToken;
  final String refreshToken;
  final int userId;
  final String username;

  const LoginResponse({
    // required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.username,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      // user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: json['userId'] as int,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userId': userId,
      'username': username,
    };
  }
}

class RefreshTokenResponse {
  final String accessToken;
  final String refreshToken;

  const RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }
}
