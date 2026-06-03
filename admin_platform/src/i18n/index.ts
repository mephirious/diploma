import i18n from 'i18next';
import LanguageDetector from 'i18next-browser-languagedetector';
import { initReactI18next } from 'react-i18next';

import en from './en';
import ru from './ru';
import kk from './kk';

export const SUPPORTED_LOCALES = ['en', 'ru', 'kk'] as const;
export type Locale = (typeof SUPPORTED_LOCALES)[number];

export const localeLabels: Record<Locale, string> = {
  en: 'English',
  ru: 'Русский',
  kk: 'Қазақша',
};

const LOCALE_STORAGE_KEY = 'zs.admin.locale';

void i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources: {
      en: { translation: en },
      ru: { translation: ru },
      kk: { translation: kk },
    },
    fallbackLng: 'en',
    supportedLngs: [...SUPPORTED_LOCALES],
    interpolation: {
      escapeValue: false,
    },
    detection: {
      order: ['localStorage', 'navigator'],
      lookupLocalStorage: LOCALE_STORAGE_KEY,
      caches: ['localStorage'],
    },
  });

export function setAppLocale(locale: Locale) {
  void i18n.changeLanguage(locale);
  try {
    localStorage.setItem(LOCALE_STORAGE_KEY, locale);
  } catch {
    // ignore storage errors (private mode, quota, etc.)
  }
}

export function currentLocale(): Locale {
  const lng = (i18n.language || 'en').slice(0, 2);
  return (SUPPORTED_LOCALES as readonly string[]).includes(lng)
    ? (lng as Locale)
    : 'en';
}

export default i18n;
