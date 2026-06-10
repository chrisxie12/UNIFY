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
        navy: '#0D1B3E',
        orange: {
          DEFAULT: '#FF6B35',
          400: '#FF8C5A',
          500: '#FF6B35',
          600: '#E55A22',
        },
        blue: {
          DEFAULT: '#0D1B3E',
          800: '#162347',
          900: '#0D1B3E',
          950: '#081228',
        },
        accent: {
          DEFAULT: '#A8C4FF',
          400: '#A8C4FF',
          500: '#7AABFF',
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
