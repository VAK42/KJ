import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/userModel.dart';
import '../services/authService.dart';
final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(() => AuthNotifier());
class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async => AuthService.loadSavedUser();
  Future<void> register(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => AuthService.register(email, password).then((_) => null));
  }
  Future<UserModel> verifyEmail(String email, String code) async {
    state = const AsyncLoading();
    final user = await AuthService.verifyEmail(email, code);
    state = AsyncData(user);
    return user;
  }
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => AuthService.login(email, password));
  }
  Future<void> logout() async {
    await AuthService.logout();
    state = const AsyncData(null);
  }
}