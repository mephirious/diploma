import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  /// Access token expiration time in unix seconds (decoded from JWT `exp`).
  final int? accessTokenExp;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.accessTokenExp,
  });
}

class AuthUser {
  final String sub; // JWT `sub`
  final String username; // JWT `preferred_username` (fallback: `username`)
  final String? firstName; // JWT `given_name`
  final String? lastName; // JWT `family_name`
  final String email; // JWT `email`
  final List<String> roles; // JWT `realm_access.roles`
  final int exp; // JWT `exp` (unix seconds)

  const AuthUser({
    required this.sub,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.roles,
    required this.exp,
  });

  bool get isOwner => roles.contains('owner') || roles.contains('core:admin');
  bool get isAuthenticated => exp > DateTime.now().millisecondsSinceEpoch ~/ 1000;

  String get fullName {
    final first = firstName?.trim();
    final last = lastName?.trim();
    final hasFirst = first != null && first.isNotEmpty;
    final hasLast = last != null && last.isNotEmpty;
    if (hasFirst && hasLast) return '$first $last';
    if (hasFirst) return first;
    return username;
  }

  /// Label for chat participant rows: "Last First" from JWT when present, else username, email local-part, short sub, or "user".
  String get chatDisplayName {
    final first = firstName?.trim();
    final last = lastName?.trim();
    if (last != null &&
        last.isNotEmpty &&
        first != null &&
        first.isNotEmpty) {
      return '$last $first';
    }
    if (last != null && last.isNotEmpty) return last;
    if (first != null && first.isNotEmpty) return first;
    final un = username.trim();
    if (un.isNotEmpty) return un;
    final em = email.trim();
    if (em.isNotEmpty) {
      final at = em.indexOf('@');
      if (at > 0) return em.substring(0, at);
    }
    final sid = sub.trim();
    if (sid.isNotEmpty) {
      return sid.length <= 16 ? sid : '${sid.substring(0, 8)}…';
    }
    return 'user';
  }

  factory AuthUser.fromAccessToken(String accessToken) {
    final jwt = JWT.decode(accessToken);
    final payload = jwt.payload;

    final sub = (payload['sub'] ?? '').toString();

    final username =
        (payload['preferred_username'] ?? payload['username'] ?? '').toString();

    final firstName =
        payload['given_name'] != null ? payload['given_name'].toString() : null;
    final lastName =
        payload['family_name'] != null ? payload['family_name'].toString() : null;

    final email = (payload['email'] ?? '').toString();

    final expRaw = payload['exp'];
    final exp = expRaw is int ? expRaw : int.tryParse(expRaw?.toString() ?? '');
    if (exp == null) {
      throw FormatException('JWT exp claim missing or invalid');
    }

    final realmAccess = payload['realm_access'];
    final rolesRaw = realmAccess is Map ? realmAccess['roles'] : payload['roles'];
    final roles = rolesRaw is List
        ? rolesRaw.map((e) => e.toString()).toList(growable: false)
        : const <String>[];

    return AuthUser(
      sub: sub,
      username: username,
      firstName: firstName,
      lastName: lastName,
      email: email,
      roles: roles,
      exp: exp,
    );
  }
}

