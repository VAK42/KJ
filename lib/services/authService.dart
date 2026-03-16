import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../appConfig.dart';
import '../models/userModel.dart';
class AuthService {
  AuthService._();
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ))
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('jwt');
          await prefs.remove('userEmail');
        }
        handler.next(error);
      },
    ));
  static Future<void> register(String email, String password) async {
    await _dio.post('/auth/register', data: {'email': email, 'password': password});
  }
  static Future<UserModel> verifyEmail(String email, String code) async {
    final res = await _dio.post('/auth/verify', data: {'email': email, 'code': code});
    final user = UserModel.fromJson(res.data as Map<String, dynamic>);
    await _persistUser(user);
    return user;
  }
  static Future<UserModel> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    final user = UserModel.fromJson(res.data as Map<String, dynamic>);
    await _persistUser(user);
    return user;
  }
  static Future<void> forgotPassword(String email) async {
    await _dio.post('/auth/forgotPassword', data: {'email': email});
  }
  static Future<void> resetPassword(String email, String code, String newPassword) async {
    await _dio.post('/auth/resetPassword', data: {'email': email, 'code': code, 'newPassword': newPassword});
  }
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    await prefs.remove('userEmail');
  }
  static Future<UserModel?> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    final email = prefs.getString('userEmail');
    if (token == null || email == null) return null;
    return UserModel(email: email, token: token);
  }
  static Future<void> _persistUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', user.token);
    await prefs.setString('userEmail', user.email);
  }
  static String _formatDioError(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      return data['message'] as String? ?? 'Something Went Wrong!';
    }
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return 'Connection Timed Out! Check Your Network!';
    }
    return 'Network Error! Is The Server Running?';
  }
  static String handleError(Object e) {
    if (e is DioException) return _formatDioError(e);
    return e.toString();
  }
}