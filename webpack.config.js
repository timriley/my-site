const path = require("path")
const ManifestPlugin = require("webpack-manifest-plugin")
const MiniCssExtractPlugin = require("mini-css-extract-plugin")

module.exports = function config(mode, argv) {
  return {
    mode: mode,
    entry: {
      site: [
        "./assets/index.js",
        "./assets/index.css",
      ],
      // Don't process site content for now
      // content: './assets/content.js',
    },
    output: {
      filename: mode === "development" ? "[name].js" : "[name].[chunkhash].js",
      path:
        mode === "development"
          ? path.resolve(__dirname, "./tmp/assets")
          : path.resolve(__dirname, "./build/assets"),
      publicPath:
        mode === "development"
          ? `http://localhost:${process.env.PORT}/assets/`
          : "/assets/",
    },
    plugins: [
      new ManifestPlugin(),
      new MiniCssExtractPlugin({
        // chunkFilename: "[id].css"
        // filename: "[name].[hash:8].css",
        chunkFilename: "[id].[chunkhash].css",
        ignoreOrder: false,
        filename:
          mode === "development" ? "[name].css" : "[name].[chunkhash].css",
      })
    ],
    module: {
      rules: [
        {
          test: /\.css$/,
          use: [
            {
              loader: MiniCssExtractPlugin.loader,
              options: {
                hmr: mode === "development",
              },
            },
            {
              loader: "css-loader",
              options: {
                importLoaders: 1,
              }
            },
            "postcss-loader",
          ]
        },
        {
          test: /\.(gif|jpg|png)$/,
          use: [
            {
              loader: "file-loader",
              options: {
                name:
                  mode === "development"
                    ? "[path][name].[ext]"
                    : "[path][name].[contenthash].[ext]",
              },
            },
          ],
        },
      ],
    },
  }
}
