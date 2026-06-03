import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Canonical venue sport keys (snake_case), aligned with backend / owner platform.
const List<String> venueSportKeys = [
  'football',
  'basketball',
  'tennis',
  'swimming',
  'volleyball',
  'badminton',
  'tabletennis',
  'gym',
  'ice_hockey',
  'judo',
  'chess',
  'boxing',
  'mma',
  'athletics',
  'handball',
  'futsal',
  'golf',
  'climbing',
  'yoga',
  'pilates',
  'crossfit',
  'cycling',
  'running',
  'esports',
  'other',
];

/// Keys shown in home/session category filters (no generic "other").
final List<String> filterSportKeys =
    venueSportKeys.where((k) => k != 'other').toList();

const Map<String, String> _sportAliases = {
  'table_tennis': 'tabletennis',
};

String canonicalSportKey(String raw) {
  final trimmed = raw.trim().toLowerCase();
  if (trimmed.isEmpty) return 'other';
  return _sportAliases[trimmed] ?? trimmed;
}

bool isKnownSportKey(String key) => venueSportKeys.contains(canonicalSportKey(key));

String sportLabel(AppLocalizations l10n, String rawKey) {
  switch (canonicalSportKey(rawKey)) {
    case 'football':
      return l10n.football;
    case 'basketball':
      return l10n.basketball;
    case 'tennis':
      return l10n.tennis;
    case 'swimming':
      return l10n.swimming;
    case 'volleyball':
      return l10n.volleyball;
    case 'badminton':
      return l10n.badminton;
    case 'tabletennis':
      return l10n.tabletennis;
    case 'gym':
      return l10n.gym;
    case 'ice_hockey':
      return l10n.ice_hockey;
    case 'judo':
      return l10n.judo;
    case 'chess':
      return l10n.chess;
    case 'boxing':
      return l10n.boxing;
    case 'mma':
      return l10n.mma;
    case 'athletics':
      return l10n.athletics;
    case 'handball':
      return l10n.handball;
    case 'futsal':
      return l10n.futsal;
    case 'golf':
      return l10n.golf;
    case 'climbing':
      return l10n.climbing;
    case 'yoga':
      return l10n.yoga;
    case 'pilates':
      return l10n.pilates;
    case 'crossfit':
      return l10n.crossfit;
    case 'cycling':
      return l10n.cycling;
    case 'running':
      return l10n.running;
    case 'esports':
      return l10n.esports;
    default:
      return l10n.other;
  }
}

IconData sportIcon(String rawKey) {
  switch (canonicalSportKey(rawKey)) {
    case 'football':
      return Icons.sports_soccer;
    case 'basketball':
      return Icons.sports_basketball;
    case 'tennis':
      return Icons.sports_tennis;
    case 'volleyball':
      return Icons.sports_volleyball;
    case 'swimming':
      return Icons.pool;
    case 'gym':
      return Icons.fitness_center;
    case 'badminton':
    case 'tabletennis':
      return Icons.sports_tennis;
    case 'ice_hockey':
      return Icons.sports_hockey;
    case 'judo':
    case 'mma':
    case 'boxing':
      return Icons.sports_martial_arts;
    case 'chess':
      return Icons.grid_on;
    case 'athletics':
    case 'running':
      return Icons.directions_run;
    case 'handball':
      return Icons.sports_handball;
    case 'futsal':
      return Icons.sports_soccer;
    case 'golf':
      return Icons.sports_golf;
    case 'climbing':
      return Icons.terrain;
    case 'yoga':
    case 'pilates':
      return Icons.self_improvement;
    case 'crossfit':
      return Icons.fitness_center;
    case 'cycling':
      return Icons.directions_bike;
    case 'esports':
      return Icons.sports_esports;
    default:
      return Icons.sports;
  }
}

Color sportColor(String rawKey) {
  switch (canonicalSportKey(rawKey)) {
    case 'football':
    case 'futsal':
      return const Color(0xFF4CAF50);
    case 'basketball':
      return const Color(0xFFFF9800);
    case 'tennis':
    case 'badminton':
    case 'tabletennis':
      return const Color(0xFFFFC107);
    case 'volleyball':
      return const Color(0xFF2196F3);
    case 'swimming':
      return const Color(0xFF00BCD4);
    case 'gym':
    case 'crossfit':
      return const Color(0xFF9C27B0);
    case 'ice_hockey':
      return const Color(0xFF607D8B);
    case 'judo':
    case 'boxing':
    case 'mma':
      return const Color(0xFF795548);
    case 'chess':
      return const Color(0xFF5D4037);
    default:
      return const Color(0xFF1DB954);
  }
}

int _sportLabelCompare(
  AppLocalizations l10n,
  String a,
  String b,
  String locale,
) {
  final la = sportLabel(l10n, a);
  final lb = sportLabel(l10n, b);
  // Locale is used by callers for consistency with owner platform sorting.
  return la.compareTo(lb);
}

List<String> sortedVenueSportKeys(
  AppLocalizations l10n,
  String locale, {
  List<String>? keys,
}) {
  final effectiveKeys = keys ?? filterSportKeys;
  final copy = List<String>.from(effectiveKeys);
  copy.sort((a, b) => _sportLabelCompare(l10n, a, b, locale));
  return copy;
}

List<String> sortSportKeysForDisplay(
  List<String> sports,
  AppLocalizations l10n,
  String locale,
) {
  final copy = List<String>.from(sports);
  copy.sort((a, b) => _sportLabelCompare(l10n, a, b, locale));
  return copy;
}

class SportCategoryItem {
  const SportCategoryItem({
    required this.key,
    required this.label,
    required this.icon,
  });

  final String key;
  final String label;
  final IconData icon;
}

List<SportCategoryItem> sortedSportCategories(
  AppLocalizations l10n,
  String locale, {
  List<String>? keys,
}) {
  return sortedVenueSportKeys(l10n, locale, keys: keys)
      .map(
        (key) => SportCategoryItem(
          key: key,
          label: sportLabel(l10n, key),
          icon: sportIcon(key),
        ),
      )
      .toList();
}
