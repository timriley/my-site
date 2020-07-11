const cssnano = require("cssnano")
const postcssImport = require("postcss-import")
const postcssUrl = require("postcss-url")
const tailwindcss = require("tailwindcss")

module.exports = ({ env }) => ({
  plugins: [
    // Add module-like @import support to our CSS. This sets the context for all imports
    // to be the base entry point.
    postcssImport,
    // postcss-url "rebases" any `url()` references in CSS to their original relative
    // position on the filesystem (so that postcss-import doesn't break things)
    postcssUrl(),
    tailwindcss,
    env === "production"
      ? cssnano({preset: "default"})
      : false,
  ]
})
