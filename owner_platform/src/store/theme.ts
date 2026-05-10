import { useEffect } from 'react';
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export type ThemeMode = 'light' | 'dark' | 'system';

type ThemeState = {
  mode: ThemeMode;
  setMode: (mode: ThemeMode) => void;
};

export const useTheme = create<ThemeState>()(
  persist(
    (set) => ({
      mode: 'system',
      setMode: (mode) => set({ mode }),
    }),
    { name: 'zs.owner.theme', version: 1 },
  ),
);

/** Resolves the theme mode to a concrete `light` / `dark` class on <html>. */
export function useApplyTheme() {
  const mode = useTheme((s) => s.mode);

  useEffect(() => {
    const root = document.documentElement;

    function apply(resolved: 'light' | 'dark') {
      root.classList.toggle('dark', resolved === 'dark');
      root.style.colorScheme = resolved;
    }

    if (mode === 'light' || mode === 'dark') {
      apply(mode);
      return;
    }

    const mql = window.matchMedia('(prefers-color-scheme: dark)');
    apply(mql.matches ? 'dark' : 'light');

    function onChange(e: MediaQueryListEvent) {
      apply(e.matches ? 'dark' : 'light');
    }
    mql.addEventListener('change', onChange);
    return () => mql.removeEventListener('change', onChange);
  }, [mode]);
}
