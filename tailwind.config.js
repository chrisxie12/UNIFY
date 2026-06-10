/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        navy: '#0F0E17',
        amber: {
          DEFAULT: '#F4C430',
          300: '#FFE082',
          400: '#F4C430',
          500: '#D4A820',
          800: '#7B5800',
          900: '#4A3500',
          950: '#2A1E00',
        },
        purple: {
          DEFAULT: '#7B2FBE',
          400: '#9B4DCA',
          600: '#6A1FA8',
        },
        cyan: {
          DEFAULT: '#00F5D4',
          400: '#00F5D4',
          500: '#00D4B8',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      animation: {
        ticker: 'ticker 35s linear infinite',
        blink: 'blink 2s ease-in-out infinite',
      },
      keyframes: {
        ticker: {
          '0%':   { transform: 'translateX(0)' },
          '100%': { transform: 'translateX(-50%)' },
        },
        blink: {
          '0%, 100%': { opacity: '1' },
          '50%':      { opacity: '0.4' },
        },
      },
    },
  },
  plugins: [],
};
