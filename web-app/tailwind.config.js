/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        alwan: {
          primary: '#1565C0',
          secondary: '#7E57C2',
          accent: '#FFC107',
          dark: {
            bg: '#081C3A',
            surface: '#10294D',
            card: '#17375E',
          },
          gradient: {
            start: '#1565C0',
            end: '#7E57C2',
          },
          live: '#E53935',
        },
      },
      fontFamily: {
        sans: ['Mahmoud Bold Ultra', 'system-ui', 'sans-serif'],
        mahmoud: ['Mahmoud Bold Ultra', 'system-ui', 'sans-serif'],
      },
      animation: {
        'pulse-live': 'pulse-live 2s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'slide-up': 'slide-up 0.3s ease-out',
        'fade-in': 'fade-in 0.3s ease-out',
      },
      keyframes: {
        'pulse-live': {
          '0%, 100%': { opacity: '1' },
          '50%': { opacity: '0.5' },
        },
        'slide-up': {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        'fade-in': {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
      },
    },
  },
  plugins: [require('@tailwindcss/typography')],
};
