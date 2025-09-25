import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:kifiya/core/services/token_storage_service.dart';
import 'package:kifiya/features/auth/data/api_service/auth_api_service.dart';

class DioInterceptor extends Interceptor {
  final TokenStorageService _tokenStorage;
  final Dio _dio;

  DioInterceptor(this._tokenStorage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding token for auth endpoints
    if (_isAuthEndpoint(options.path)) {
      return handler.next(options);
    }

    // Add access token to request headers
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401 &&
        !_isAuthEndpoint(err.requestOptions.path)) {
      try {
        // Attempt to refresh token
        final refreshed = await _refreshToken();

        if (refreshed) {
          // Retry the original request with new token
          final retryResponse = await _retryRequest(err.requestOptions);
          return handler.resolve(retryResponse);
        } else {
          // Refresh failed, clear tokens and let error pass through
          // await _tokenStorage.clearAll();
        }
      } catch (refreshError) {
        // Refresh failed, clear tokens
        // await _tokenStorage.clearAll();
      }
    }

    return handler.next(err);
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/api/auth/login') ||
        path.contains('/api/auth/register') ||
        path.contains('/api/auth/refresh-token');
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      final accessToken = await _tokenStorage.getAccessToken();

      if (refreshToken == null) return false;

      // Create a new Dio instance to avoid interceptor loops
      final refreshDio = Dio(_dio.options);
      if (accessToken != null) {
        refreshDio.options.headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await refreshDio.post(
        '/api/auth/refresh-token',

        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String;

        // Save new tokens
        await _tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        return true;
      }
    } catch (e) {
      // Refresh failed
      return false;
    }

    return false;
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    // Get the new access token
    final accessToken = await _tokenStorage.getAccessToken();

    // Update the authorization header
    if (accessToken != null) {
      requestOptions.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Create a new Dio instance to avoid interceptor loops for retry
    final retryDio = Dio(_dio.options);

    // Retry the request
    return await retryDio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        contentType: requestOptions.contentType,
        responseType: requestOptions.responseType,
        followRedirects: requestOptions.followRedirects,
        maxRedirects: requestOptions.maxRedirects,
        receiveTimeout: requestOptions.receiveTimeout,
        sendTimeout: requestOptions.sendTimeout,
      ),
    );
  }
}
