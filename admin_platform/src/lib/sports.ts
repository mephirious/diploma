/** Canonical sport keys stored on venues (snake_case). */
export const VENUE_SPORT_KEYS = [
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
] as const;

export type VenueSportKey = (typeof VENUE_SPORT_KEYS)[number];

/** Legacy / seed data variants mapped to translation keys. */
const SPORT_ALIASES: Record<string, VenueSportKey | 'other'> = {
  table_tennis: 'tabletennis',
};

export function sportTranslationKey(key: string): string {
  const alias = SPORT_ALIASES[key];
  if (alias) return alias;
  if ((VENUE_SPORT_KEYS as readonly string[]).includes(key)) return key;
  return 'other';
}

export function sportLabel(
  t: (key: string, opts?: { defaultValue?: string }) => string,
  key: string,
): string {
  const trKey = sportTranslationKey(key);
  return t(`sports.${trKey}`, { defaultValue: key });
}

/** Sport keys for filters (excludes generic "other"). */
export const FILTER_SPORT_KEYS = VENUE_SPORT_KEYS.filter((k) => k !== 'other');

export function sortedVenueSportKeys(
  t: (key: string, opts?: { defaultValue?: string }) => string,
  locale?: string,
  keys: readonly string[] = VENUE_SPORT_KEYS,
): string[] {
  return [...keys].sort((a, b) =>
    sportLabel(t, a).localeCompare(sportLabel(t, b), locale, { sensitivity: 'base' }),
  );
}

export function sortedSportOptions(
  t: (key: string, opts?: { defaultValue?: string }) => string,
  locale?: string,
  keys: readonly string[] = VENUE_SPORT_KEYS,
): Array<{ value: string; label: string }> {
  return sortedVenueSportKeys(t, locale, keys).map((key) => ({
    value: key,
    label: sportLabel(t, key),
  }));
}

/** Sort raw API sport keys by localized label for display. */
export function sortSportKeysForDisplay(
  sports: string[],
  t: (key: string, opts?: { defaultValue?: string }) => string,
  locale?: string,
): string[] {
  return [...sports].sort((a, b) =>
    sportLabel(t, a).localeCompare(sportLabel(t, b), locale, { sensitivity: 'base' }),
  );
}

/** Maps API/legacy sport keys to canonical keys for forms and filters. */
export function canonicalSportKeys(sports: string[]): string[] {
  const out: string[] = [];
  for (const s of sports) {
    const k = sportTranslationKey(s);
    if (!out.includes(k)) out.push(k);
  }
  return out;
}

/** @deprecated Use VENUE_SPORT_KEYS */
export const SPORT_KEYS = VENUE_SPORT_KEYS;

export type SportKey = VenueSportKey;
