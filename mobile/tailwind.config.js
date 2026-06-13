/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './context/**/*.{ts,tsx}',
    './theme/**/*.{ts,tsx}',
  ],
  presets: [require('nativewind/preset')],
  theme: {
    extend: {
      colors: {
        // Clean Bold palette
        white: '#FFFFFF',
        surface: '#F3F4F6',
        charcoal: '#1F2937',
        muted: '#6B7280',
        subtle: '#9CA3AF',
        divider: '#E5E7EB',
        accent: '#0066FF',  // blue — active states & send buttons only
        notif: '#FF6B35',   // orange — notifications & decorative marks only
        // Timetable slot accents — soft tinted backgrounds
        'slot-red': '#FEE2E2',
        'slot-blue': '#DBEAFE',
        'slot-green': '#D1FAE5',
        'slot-yellow': '#FEF3C7',
        'slot-red-fg': '#B91C1C',
        'slot-blue-fg': '#1D4ED8',
        'slot-green-fg': '#047857',
        'slot-yellow-fg': '#B45309',
        // Keep 'parchment' alias → white so existing bg-parchment references work
        parchment: '#FFFFFF',
        ink: '#1F2937',
      },
      fontFamily: {
        display: ['ArchivoBlack'],
        heading: ['SpaceGrotesk_700Bold'],
        body: ['Inter_400Regular'],
        'body-medium': ['Inter_500Medium'],
        'body-bold': ['Inter_700Bold'],
      },
      boxShadow: {
        card: '0px 1px 8px rgba(0,0,0,0.07)',
        'card-md': '0px 4px 16px rgba(0,0,0,0.09)',
        'card-lg': '0px 8px 24px rgba(0,0,0,0.12)',
      },
    },
  },
  plugins: [],
};
