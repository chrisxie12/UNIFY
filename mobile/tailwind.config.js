/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/**/*.{ts,tsx}', './components/**/*.{ts,tsx}'],
  presets: [require('nativewind/preset')],
  theme: {
    extend: {
      colors: {
        parchment: '#F4F4F0',
        ink: '#000000',
        'dark-base': '#121212',
        action: '#FFE600',
        brand: '#FF6B35',
        verify: '#00FF66',
        alert: '#FF007A',
        info: '#0066FF',
      },
      fontFamily: {
        display: ['ArchivoBlack'],
        heading: ['SpaceGrotesk_700Bold'],
        body: ['Inter_400Regular'],
        'body-medium': ['Inter_500Medium'],
        'body-bold': ['Inter_700Bold'],
      },
      boxShadow: {
        // Hard 0-blur Neubrutalist offsets
        nb: '4px 4px 0px 0px rgba(0,0,0,1)',
        'nb-sm': '2px 2px 0px 0px rgba(0,0,0,1)',
        'nb-lg': '6px 6px 0px 0px rgba(0,0,0,1)',
      },
      borderRadius: {
        none: '0px',
        md: '4px',
      },
    },
  },
  plugins: [],
};
