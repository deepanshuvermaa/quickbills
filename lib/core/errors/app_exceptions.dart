class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, {this.code});
  
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code}) : super(message, code: code);
}

class TimeoutException extends AppException {
  TimeoutException(String message, {String? code}) : super(message, code: code);
}

class ServerException extends AppException {
  ServerException(String message, {String? code}) : super(message, code: code);
}

class BadRequestException extends AppException {
  BadRequestException(String message, {String? code}) : super(message, code: code);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message, {String? code}) : super(message, code: code);
}

class ForbiddenException extends AppException {
  ForbiddenException(String message, {String? code}) : super(message, code: code);
}

class NotFoundException extends AppException {
  NotFoundException(String message, {String? code}) : super(message, code: code);
}

class ValidationException extends AppException {
  final Map<String, List<String>>? errors;
  
  ValidationException(String message, {this.errors, String? code}) : super(message, code: code);
}