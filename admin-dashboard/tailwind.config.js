/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx}',
    './components/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        cosmic: {
          black: '#0A0A0F',
          space: '#12121A',
          purple: '#1A1A2E',
        },
        gold: {
          DEFAULT: '#D4AF37',
          light: '#F4D03F',
        },
      },
    },
  },
  plugins: [],
};
