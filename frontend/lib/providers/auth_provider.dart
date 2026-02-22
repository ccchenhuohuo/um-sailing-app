import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart' as riverpod;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/user.dart';
import '../services/api_service.dart';

final sharedPreferencesProvider = riverpod.Provider<SharedPreferences>((_) {
  throw UnimplementedError();
});

final authProvider = riverpod.StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(prefs);
});

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = true,
    this.errorMessage,
  });

  factory AuthState.initial() => AuthState(isLoading: true);

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends riverpod.StateNotifier<AuthState> {
  final SharedPreferences _prefs;

  AuthNotifier(this._prefs) : super(AuthState.initial()) {
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      await checkAuth();
    } catch (e, stackTrace) {
      // 记录错误用于调试
      debugPrint('Auth initialization failed: $e\n$stackTrace');
      state = AuthState(isAuthenticated: false, isLoading: false);
    }
  }

  Future<void> checkAuth() async {
    try {
      final token = _prefs.getString(AppConstants.accessTokenKey);
      final userJson = _prefs.getString(AppConstants.userInfoKey);

      if (token != null && userJson != null) {
        final user = User.fromJson(jsonDecode(userJson));
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      // SharedPreferences 读取失败，跳过登录状态检查
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      // 先设置为加载中状态，清除错误消息
      state = state.copyWith(isLoading: true, errorMessage: null);
      final api = ApiService();
      final user = await api.login(username: username, password: password);
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      // 登录失败，保持在登录页面，设置错误消息
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String password,
    required String email,
    String? phone,
  }) async {
    try {
      final api = ApiService();
      final user = await api.register(
        username: username,
        password: password,
        email: email,
        phone: phone,
      );
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService().logout();
    state = AuthState(isAuthenticated: false, user: null, isLoading: false);
  }

  void updateUser(User user) {
    state = state.copyWith(user: user);
  }
}
