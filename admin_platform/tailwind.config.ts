import type { Config } from 'tailwindcss';

/**
 * Design tokens mirror the Flutter mobile app (see `frontend/lib/core/theme/app_colors.dart`)
 * so that any UI/design change on the owner web stays visually aligned with the customer app.
 */
const config: Config = {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  darkMode: 'class',
  theme: {
    container: {
      center: true,
      padding: '1rem',
    },
    extend: {
      colors: {
        brand: {
          DEFAULT: '#00BFA5', // colorMain
          50: '#E6FAF6',
          100: '#C6F3EA',
          200: '#8EE6D4',
          300: '#56D9BF',
          400: '#2FCCAD',
          500: '#00BFA5',
          600: '#009F8A',
          700: '#00806F',
          800: '#1B5E4B', // colorSecondary
          900: '#0D3B2E',
        },
        admin: {
          DEFAULT: '#5C6BC0',
          50: '#ECEEF9',
          100: '#C5CAF0',
          200: '#9FA7E7',
          300: '#7984DE',
          400: '#6673D9',
          500: '#5C6BC0',
          600: '#4C59A8',
          700: '#3D4890',
          800: '#2E3778',
          900: '#1F2560',
        },
        accent: {
          DEFAULT: '#00E5CC',
        },
        // Functional
        success: '#43A047',
        warning: '#FFA726',
        info: '#29B6F6',
        danger: '#E53935',
        // Sport accents
        football: '#4CAF50',
        basketball: '#FF9800',
        tennis: '#FFC107',
        volleyball: '#2196F3',
        swimming: '#00BCD4',
        gym: '#9C27B0',
        // Theme surfaces
        'surface-light': '#FFFFFF',
        'surface-dark': '#1A2737',
        'bg-light': '#F5F7FA',
        'bg-dark': '#0F1923',
        'text-light': '#1A1A2E',
        'muted-light': '#6B7280',
        'text-dark': '#F1F5F9',
        'muted-dark': '#94A3B8',
      },
      fontFamily: {
        sans: [
          'Roboto',
          'Inter',
          'system-ui',
          '-apple-system',
          'Segoe UI',
          'sans-serif',
        ],
      },
      borderRadius: {
        sm: '8px',
        md: '12px',
        lg: '16px',
        xl: '24px',
      },
      boxShadow: {
        card: '0 6px 18px rgba(16, 24, 40, 0.06)',
        'card-hover': '0 12px 32px rgba(16, 24, 40, 0.10)',
        brand: '0 10px 24px rgba(0, 191, 165, 0.28)',
        admin: '0 10px 24px rgba(92, 107, 192, 0.28)',
      },
      backgroundImage: {
        'brand-gradient':
          'linear-gradient(135deg, #00897B 0%, #00BFA5 100%)',
        'brand-gradient-soft':
          'linear-gradient(135deg, rgba(148,218,204,1) 0%, rgba(28,122,100,1) 100%)',
        'dark-gradient':
          'linear-gradient(135deg, #0D3B2E 0%, #1B5E4B 100%)',
      },
      keyframes: {
        'fade-in': {
          '0%': { opacity: '0', transform: 'translateY(4px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        'scale-in': {
          '0%': { opacity: '0', transform: 'scale(0.96)' },
          '100%': { opacity: '1', transform: 'scale(1)' },
        },
      },
      animation: {
        'fade-in': 'fade-in 0.25s ease-out both',
        'scale-in': 'scale-in 0.2s ease-out both',
      },
    },
  },
  plugins: [],
};

export default config;
