// module.exports = {
//   purge: [
//     "./templates/**/*.html*"
//   ],
//   theme: {
//     extend: {},
//   },
//   variants: {},
//   plugins: [],
// }

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./public/*.html",
    "./app/views/**/*.rb",
    "./app/templates/**/*"
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
