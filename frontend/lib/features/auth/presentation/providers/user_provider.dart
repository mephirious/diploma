import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model_simple.dart';

enum UserRole { customer, owner }

class UserAccountState {
  final UserModelSimple? user;
  final UserRole role;
  final bool notificationsEnabled;

  const UserAccountState({
    required this.user,
    required this.role,
    required this.notificationsEnabled,
  });

  UserAccountState copyWith({
    UserModelSimple? user,
    UserRole? role,
    bool? notificationsEnabled,
    bool clearUser = false,
  }) {
    return UserAccountState(
      user: clearUser ? null : (user ?? this.user),
      role: role ?? this.role,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

final userAccountProvider =
    StateNotifierProvider<UserNotifier, UserAccountState>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserAccountState> {
  static const _prefsKeyRole = 'account.role';
  static const _prefsKeyUser = 'account.user';
  static const _prefsKeyNotifications = 'account.notifications.enabled';

  static final UserModelSimple _customerUser = UserModelSimple(
    id: '1',
    fullName: 'Danial Bolat',
    email: 'danial.bolat@example.com',
    phone: '+7 (777) 123-45-67',
    avatar: null,
  );

  static final UserModelSimple _ownerUser = UserModelSimple(
    id: '100',
    fullName: 'Ainur Beketova',
    email: 'ainur.beketova@sportbooking.kz',
    phone: '+7 (701) 555-20-11',
    avatar: null,
  );

  UserNotifier()
      : super(
          UserAccountState(
            user: _customerUser,
            role: UserRole.customer,
            notificationsEnabled: true,
          ),
        ) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final roleValue = prefs.getString(_prefsKeyRole);
    final userJson = prefs.getString(_prefsKeyUser);
    final notifications =
        prefs.getBool(_prefsKeyNotifications) ?? state.notificationsEnabled;

    final role = _roleFromString(roleValue);
    final persistedUser = userJson != null
        ? UserModelSimple.fromJson(_jsonToMap(userJson))
        : _defaultUserByRole(role);

    state = UserAccountState(
      user: persistedUser,
      role: role,
      notificationsEnabled: notifications,
    );
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyRole, _roleToString(state.role));
    await prefs.setBool(_prefsKeyNotifications, state.notificationsEnabled);

    final user = state.user;
    if (user == null) {
      await prefs.remove(_prefsKeyUser);
      return;
    }

    await prefs.setString(_prefsKeyUser, _mapToJson(user.toJson()));
  }

  Future<void> updateUser(UserModelSimple user) async {
    state = state.copyWith(user: user);
    await _persist();
  }

  Future<void> switchRole(UserRole role) async {
    final roleUser = _defaultUserByRole(role);
    state = state.copyWith(role: role, user: roleUser);
    await _persist();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _persist();
  }

  Future<void> logout() async {
    state = state.copyWith(clearUser: true);
    await _persist();
  }

  UserRole _roleFromString(String? value) {
    switch (value) {
      case 'owner':
        return UserRole.owner;
      default:
        return UserRole.customer;
    }
  }

  String _roleToString(UserRole role) {
    return role == UserRole.owner ? 'owner' : 'customer';
  }

  UserModelSimple _defaultUserByRole(UserRole role) {
    return role == UserRole.owner ? _ownerUser : _customerUser;
  }

  Map<String, dynamic> _jsonToMap(String json) {
    return Map<String, dynamic>.from(jsonDecode(json));
  }

  String _mapToJson(Map<String, dynamic> map) {
    return jsonEncode(map);
  }
}

final userProvider = Provider<UserModelSimple?>((ref) {
  return ref.watch(userAccountProvider).user;
});

final userRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(userAccountProvider).role;
});

final isOwnerProvider = Provider<bool>((ref) {
  return ref.watch(userRoleProvider) == UserRole.owner;
});

final notificationsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(userAccountProvider).notificationsEnabled;
});

// Authentication state provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(userProvider) != null;
});
