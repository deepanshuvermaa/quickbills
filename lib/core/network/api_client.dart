import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_config.dart';
import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref);
});

class ApiClient {
  late final Dio _dio;
  final Ref _ref;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  ApiClient(this._ref) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectionTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: ApiConfig.headers,
    ));
    
    _dio.interceptors.addAll([
      AuthInterceptor(_secureStorage, _dio),
      ErrorInterceptor(),
      if (const bool.fromEnvironment('DEBUG', defaultValue: true))
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
    ]);
  }
  
  Dio get dio => _dio;
  
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;
  
  AuthInterceptor(this._secureStorage, this._dio);
  
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }
  
  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken != null) {
        try {
          final response = await _dio.post(
            ApiEndpoints.authRefresh,
            data: {'refreshToken': refreshToken},
          );
          
          final newAccessToken = response.data['accessToken'];
          final newRefreshToken = response.data['refreshToken'];
          
          await _secureStorage.write(key: AppConstants.tokenKey, value: newAccessToken);
          await _secureStorage.write(key: AppConstants.refreshTokenKey, value: newRefreshToken);
          
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          
          return handler.resolve(await _dio.fetch(err.requestOptions));
        } catch (e) {
          await _secureStorage.deleteAll();
        }
      }
    }
    return handler.next(err);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException appException;
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        appException = TimeoutException('Connection timed out');
        break;
      case DioExceptionType.connectionError:
        appException = NetworkException('No internet connection');
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        final message = err.response?.data['message'] ?? 'Unknown error occurred';
        
        if (statusCode == 401) {
          appException = UnauthorizedException(message);
        } else if (statusCode == 403) {
          appException = ForbiddenException(message);
        } else if (statusCode == 404) {
          appException = NotFoundException(message);
        } else if (statusCode >= 400 && statusCode < 500) {
          appException = BadRequestException(message);
        } else if (statusCode >= 500) {
          appException = ServerException(message);
        } else {
          appException = AppException(message);
        }
        break;
      default:
        appException = AppException('Something went wrong');
    }
    
    throw appException;
  }
}