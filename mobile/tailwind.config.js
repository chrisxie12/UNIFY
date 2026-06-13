/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './store/**/*.{ts,tsx}',
    './theme/**/*.{ts,tsx}',
  ],
  presets: [require('nativewind/preset')],
  theme: {
    extend: {
      colors: {
        // Surfaces
        white:    '#FFFFFF',
        surface:  '#F8F9FA',
        tertiary: '#F0F7FF',
        // Text
        primary:   '#FFFFFF',
        secondary: '#374151',
        tertxt:    '#9CA3AF',
        // Accents
        blue:   '#0066FF',
        orange: '#FF6B35',
        green:  '#10B981',
        red:    '#EF4444',
        // UI
        'btn-primary': '#1F2937',
        border:  '#E5E7EB',
        // Backwards-compat aliases used in existing components
        charcoal: '#1F2937',
        muted:    '#6B7280',
        subtle:   '#9CA3AF',
        divider:  '#E5E7EB',
        accent:   '#0066FF',
        notif:    '#FF6B35',
      },
      fontFamily: {
        display:      ['ArchivoBlack'],
        heading:      ['SpaceGrotesk_700Bold'],
        'heading-md': ['SpaceGrotesk_500Medium'],
        body:         ['Inter_400Regular'],
        'body-medium':['Inter_500Medium'],
        'body-semi':  ['Inter_600SemiBold'],
        'body-bold':  ['Inter_700Bold'],
      },
      boxShadow: {
        card:    '0px 1px 8px rgba(0,0,0,0.06)',
        'card-md':'0px 4px 16px rgba(0,0,0,0.09)',
        'card-lg':'0px 8px 32px rgba(0,0,0,0.12)',
      },
    },
  },
  plugins: [],
};
