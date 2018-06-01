const ManifestPlugin = require("webpack-manifest-plugin")
const MiniCssExtractPlugin = require("mini-css-extract-plugin")

module.exports = function(env, argv) {
  return {
    entry: {
      site: [
        './assets/index.js',
        './assets/index.css',
      ],
      // Don't process site content for now
      // content: './assets/content.js',
    },
    output: {
      filename: '[name].[hash:8].js',
      path: __dirname + '/build/assets',
    },
    plugins: [
      new ManifestPlugin(),
      new MiniCssExtractPlugin({
        filename: "[name].[hash:8].css",
        chunkFilename: "[id].css"
      })
    ],
    module: {
      rules: [
        {
          test: /\.css$/,
          use: [
            MiniCssExtractPlugin.loader,
            {
              loader: 'css-loader',
              options: {
                importLoaders: 1,
                minimize: argv.mode == 'production',
              }
            },
            'postcss-loader',
          ]
        },
        {
          test: /\.(gif|jpg|png)$/,
          use: [
            {
              loader: 'file-loader',
              options: {
                name: '[name].[hash:8].[ext]',
                useRelativePath: true,
              },
            },
          ],
        },
      ],
    },
  }
}
