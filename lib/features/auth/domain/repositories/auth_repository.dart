import '../../data/models/auth_response_model.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });
  
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String phone,
    required String businessName,
    required String password,
  });
  
  Future<AuthResponseModel?> refreshToken();
  
  Future<void> logout();
  
  Future<bool> isAuthenticated();
  
  Future<UserModel?> getCurrentUser();
}