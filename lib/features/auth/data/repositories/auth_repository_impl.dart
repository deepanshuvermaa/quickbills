import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../models/subscription_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(apiClientProvider));
});

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  AuthRepositoryImpl(this._apiClient);
  
  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    // Mock login for testing
    if (email == 'test@quickbills.com' && password == 'test123') {
      final mockUser = UserModel(
        id: '1',
        name: 'Test User',
        email: email,
        phone: '+91 9876543210',
        businessName: 'Test Business',
        createdAt: DateTime.now(),
        subscription: SubscriptionModel(
          plan: 'premium',
          status: 'active',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          features: ['unlimited_bills', 'inventory', 'reports', 'multi_user'],
        ),
      );
      
      final mockAuthResponse = AuthResponseModel(
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        user: mockUser,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
      
      await _saveAuthData(mockAuthResponse);
      return mockAuthResponse;
    }
    
    // For real backend (uncommented when ready)
    /*
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.authLogin,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      final authResponse = AuthResponseModel.fromJson(response.data);
      await _saveAuthData(authResponse);
      
      return authResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Unable to connect to server. Please check your internet connection.');
      }
      throw Exception('Login failed: ${e.message}');
    }
    */
    
    throw Exception('Invalid email or password');
  }
  
  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String phone,
    required String businessName,
    required String password,
  }) async {
    // Mock registration for testing
    final mockUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      businessName: businessName,
      createdAt: DateTime.now(),
      subscription: SubscriptionModel(
        plan: 'free',
        status: 'active',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 14)), // 14 day free trial
        features: ['limited_bills', 'basic_inventory'],
      ),
    );
    
    final mockAuthResponse = AuthResponseModel(
      accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      user: mockUser,
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
    
    await _saveAuthData(mockAuthResponse);
    return mockAuthResponse;
    
    // For real backend (uncommented when ready)
    /*
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.authRegister,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'businessName': businessName,
          'password': password,
        },
      );
      
      final authResponse = AuthResponseModel.fromJson(response.data);
      await _saveAuthData(authResponse);
      
      return authResponse;
    } on DioException catch (e) {
      throw e.error ?? Exception('Registration failed');
    }
    */
  }
  
  @override
  Future<AuthResponseModel?> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) return null;
      
      final response = await _apiClient.dio.post(
        ApiEndpoints.authRefresh,
        data: {'refreshToken': refreshToken},
      );
      
      final authResponse = AuthResponseModel.fromJson(response.data);
      await _saveAuthData(authResponse);
      
      return authResponse;
    } on DioException catch (_) {
      await logout();
      return null;
    }
  }
  
  @override
  Future<void> logout() async {
    await _secureStorage.deleteAll();
    // Clear any cached data
    _apiClient.clearAuthToken();
  }
  
  @override
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    return token != null;
  }
  
  @override
  Future<UserModel?> getCurrentUser() async {
    final userJson = await _secureStorage.read(key: AppConstants.userKey);
    if (userJson == null) return null;
    
    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }
  
  Future<void> _saveAuthData(AuthResponseModel authResponse) async {
    await _secureStorage.write(
      key: AppConstants.tokenKey,
      value: authResponse.accessToken,
    );
    await _secureStorage.write(
      key: AppConstants.refreshTokenKey,
      value: authResponse.refreshToken,
    );
    // Store user data as JSON string properly
    await _secureStorage.write(
      key: AppConstants.userKey,
      value: jsonEncode(authResponse.user.toJson()),
    );
  }
}