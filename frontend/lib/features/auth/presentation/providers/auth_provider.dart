import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/auth/auth_models.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final AuthUser? authUser;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.authUser,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    AuthUser? authUser,
    String? errorMessage,
    bool clearUser = false,
    bool clearAuthUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      authUser: clearAuthUser ? null : (authUser ?? this.authUser),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SecureStorage _storage;

  Timer? _tokenExpiryTimer;
  Timer? _validityTicker;

  static const _prefsLoggedIn = 'auth.is_logged_in';
  static const _prefsSub = 'auth.sub';
  static const _prefsRoles = 'auth.roles';
  static const _prefsIsOwner = 'auth.is_owner';
  static const _prefsExp = 'auth.exp';

  // User data stored in SharedPreferences (should be cleared on logout).
  static const _prefsSavedCards = 'saved_payment_cards';
  static const _prefsAccountRole = 'account.role';
  static const _prefsAccountUser = 'account.user';
  static const _prefsAccountNotificationsEnabled =
      'account.notifications.enabled';

  AuthNotifier(this._repository, this._storage) : super(AuthState()) {
    checkAuthStatus();
  }

  void _cancelTimers() {
    _tokenExpiryTimer?.cancel();
    _validityTicker?.cancel();
    _tokenExpiryTimer = null;
    _validityTicker = null;
  }

  Future<void> _persistAuthToShared(AuthUser authUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsLoggedIn, true);
    await prefs.setString(_prefsSub, authUser.sub);
    await prefs.setStringList(_prefsRoles, authUser.roles);
    await prefs.setBool(_prefsIsOwner, authUser.isOwner);
    await prefs.setInt(_prefsExp, authUser.exp);
  }

  Future<void> _clearSharedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsLoggedIn, false);
    await prefs.remove(_prefsSub);
    await prefs.remove(_prefsRoles);
    await prefs.remove(_prefsIsOwner);
    await prefs.remove(_prefsExp);
  }

  Future<void> _clearUserLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsSavedCards);
    await prefs.remove(_prefsAccountRole);
    await prefs.remove(_prefsAccountUser);
    await prefs.remove(_prefsAccountNotificationsEnabled);
  }

  void _scheduleTokenExpiryLogout(AuthUser authUser) {
    // Token expiry is handled by API refresh flow (401 / pre-request refresh).
    // Keep timer disabled to avoid logging out while refresh is possible.
    _tokenExpiryTimer?.cancel();
    _tokenExpiryTimer = null;
  }

  void _startValidityTicker() {
    // Validity is enforced by backend + refresh-on-401.
    _validityTicker?.cancel();
    _validityTicker = null;
  }

  Future<void> checkAuthStatus() async {
    _cancelTimers();
    try {
      final token = await _storage.getToken();
      if (token == null || token.isEmpty) {
        // Treat as fully logged out: clear both tokens and any user-specific
        // cached data persisted locally.
        await _storage.clearAll();
        await _clearSharedAuth();
        await _clearUserLocalData();
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          clearAuthUser: true,
          errorMessage: null,
        );
        return;
      }

      final authUser = AuthUser.fromAccessToken(token);
      final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (authUser.exp <= nowSeconds) {
        // Try to refresh session instead of logging out immediately.
        await _repository.refreshTokens();
      }

      final freshToken = await _storage.getToken();
      if (freshToken == null || freshToken.isEmpty) {
        await logout();
        return;
      }

      final effectiveAuthUser = AuthUser.fromAccessToken(freshToken);
      final user = await _repository.getProfile();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        authUser: effectiveAuthUser,
        errorMessage: null,
      );

      await _persistAuthToShared(effectiveAuthUser);
      _scheduleTokenExpiryLogout(effectiveAuthUser);
      _startValidityTicker();
    } catch (_) {
      await logout();
    }
  }

  Future<void> login(String email, String password) async {
    _cancelTimers();
    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
      clearUser: true,
      clearAuthUser: true,
    );
    try {
      final tokens = await _repository.login(email, password);
      final authUser = AuthUser.fromAccessToken(tokens.accessToken);
      final user = await _repository.getProfile();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        authUser: authUser,
        errorMessage: null,
      );

      await _persistAuthToShared(authUser);
      _scheduleTokenExpiryLogout(authUser);
      _startValidityTicker();
    } catch (e) {
      _cancelTimers();
      await _clearSharedAuth();
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
        clearUser: true,
        clearAuthUser: true,
      );
    }
  }

  Future<void> register(RegisterRequest request) async {
    _cancelTimers();
    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
      clearUser: true,
      clearAuthUser: true,
    );
    try {
      await _repository.register(request);
      await login(request.username, request.password);
    } catch (e) {
      _cancelTimers();
      await _clearSharedAuth();
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
        clearUser: true,
        clearAuthUser: true,
      );
    }
  }

  Future<void> logout() async {
    _cancelTimers();
    await _repository.logout();
    await _clearSharedAuth();
    await _clearUserLocalData();
    state = AuthState(
      status: AuthStatus.unauthenticated,
      user: null,
      authUser: null,
      errorMessage: null,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(repository, storage);
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});

final isOwnerProvider = Provider<bool>((ref) {
  final auth = ref.watch(authProvider);
  return auth.status == AuthStatus.authenticated && (auth.authUser?.isOwner ?? false);
});
