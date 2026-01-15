import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Auth state to track if the user is logged in.
class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? token;

  const AuthState({this.isLoggedIn = false, this.isLoading = true, this.token});

  AuthState copyWith({bool? isLoggedIn, bool? isLoading, String? token}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkAuthStatus();
    return const AuthState(isLoading: true);
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    state = AuthState(
      isLoggedIn: token != null && token.isNotEmpty,
      isLoading: false,
      token: token,
    );
  }

  Future<void> login(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    state = AuthState(isLoggedIn: true, isLoading: false, token: token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_email');
    state = const AuthState(isLoggedIn: false, isLoading: false, token: null);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _checkAuthStatus();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
