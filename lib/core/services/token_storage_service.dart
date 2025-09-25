import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';

  final FlutterSecureStorage _secureStorage;

  TokenStorageService(this._secureStorage);

  // Save tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  // Save user session (tokens + user info)
  Future<void> saveUserSession({
    required String accessToken,
    required String refreshToken,
    required int userId,
    required String username,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
      _secureStorage.write(key: _userIdKey, value: userId.toString()),
      _secureStorage.write(key: _usernameKey, value: username),
    ]);
  }

  // Get access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  // Update access token (for refresh scenarios)
  Future<void> updateAccessToken(String accessToken) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
  }

  // Update refresh token
  Future<void> updateRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // Save user data as JSON string
  Future<void> saveUserData(String userData) async {
    await _secureStorage.write(key: _userDataKey, value: userData);
  }

  // Get user data
  Future<String?> getUserData() async {
    return await _secureStorage.read(key: _userDataKey);
  }

  // Save user ID
  Future<void> saveUserId(int userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId.toString());
  }

  // Get user ID
  Future<int?> getUserId() async {
    final userIdString = await _secureStorage.read(key: _userIdKey);
    return userIdString != null ? int.tryParse(userIdString) : null;
  }

  // Save username
  Future<void> saveUsername(String username) async {
    await _secureStorage.write(key: _usernameKey, value: username);
  }

  // Get username
  Future<String?> getUsername() async {
    return await _secureStorage.read(key: _usernameKey);
  }

  // Check if tokens exist
  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  // Clear all stored data
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  // Clear only tokens (keep user data if needed)
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
    ]);
  }
}
