const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*'
  ],
    safelist: [
    'bg-red-700',
    'bg-slate-700',
    'bg-sky-700',
    'bg-emerald-700',
    'bg-sky-500',
    'bg-rose-500',
    'bg-card-blue',
    'bg-violet-500',],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        'light-brown': '#DC9B7B',
        'card-blue': '#49475B',
        'glow-green': '#C3F73A',
        'blackish': '#14080E'
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
}
