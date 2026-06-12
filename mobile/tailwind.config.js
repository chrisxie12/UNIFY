/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/**/*.{js,jsx}', './components/**/*.{js,jsx}'],
  presets: [require('nativewind/preset')],
  theme: {
    extend: {
      colors: {
        // 90% canvas
        parchment: '#F4F4F0',
        ink: '#000000',
        'dark-base': '#121212',
        // 10% loud accents
        action: '#FFE600',
        brand: '#FF6B35',
        verify: '#00FF66',
        alert: '#FF007A',
      },
      fontFamily: {
        display: ['ArchivoBlack'],
        heading: ['SpaceGrotesk_700Bold'],
        body: ['Inter_400Regular'],
        'body-medium': ['Inter_500Medium'],
        'body-bold': ['Inter_700Bold'],
      },
      borderRadius: {
        none: '0px',
        md: '4px',
      },
    },
  },
  plugins: [],
};
