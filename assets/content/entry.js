// Import the base CSS, basically our entry point for CSS. If your entry
// doesn't require CSS, you can comment this out or remove it.
import "./index.css";

// Import the base JS, basically our entry point for JS. If your entry
// doesn't require JS, you can comment this out or remove it.
import "./index.js";

// This will inspect all subdirectories from the context (this file) and
// require files matching the regex.
// https://webpack.js.org/guides/dependency-management/#require-context
require.context(".", true, /^\.\/.*\.(jpe?g|png|gif|svg|woff2?|ttf|otf|eot|ico)$/);
