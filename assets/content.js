// Inspect all subdirectories from the context (this file) and require files
// matching the regex.
// https://webpack.js.org/guides/dependency-management/#require-context
require.context(".", true, /^\.\/.*\.(jpe?g|png|gif|svg|woff2?|ttf|otf|eot|ico)$/);
