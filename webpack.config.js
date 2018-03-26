const MiniCssExtractPlugin = require("mini-css-extract-plugin");

module.exports = function(env, argv) {
  return {
    entry: {
      site: [
        './assets/index.js',
        './assets/index.css',
      ],
      content: './assets/content.js',
    },
    output: {
      filename: '[name].js',
      path: __dirname + '/build/assets',
    },
    plugins: [
      new MiniCssExtractPlugin({
        filename: "[name].css",
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
                name: '[path][name].[hash:8].[ext]',
              },
            },
          ],
        },
      ],
    },
  }
}
