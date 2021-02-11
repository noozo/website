const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = (env, options) => ({
    optimization: {
        minimizer: [
            new TerserPlugin({
                cache: true,
                parallel: true,
                sourceMap: true, // Must be set to true if using source-maps in production
                terserOptions: {
                    // https://github.com/webpack-contrib/terser-webpack-plugin#terseroptions
                }
            }),
            new OptimizeCSSAssetsPlugin({})
        ]
    },
    entry: {
        'app': glob.sync('./vendor/**/*.js').concat(['./js/app.js']),
        'landing': glob.sync('./vendor/**/*.js').concat(['./js/landing.js'])
    },
    output: {
        filename: '[name].js',
        path: path.resolve(__dirname, '../priv/static/js')
    },
    module: {
        rules: [{
                test: /\.js$/,
                exclude: /node_modules/,
                use: {
                    loader: 'babel-loader'
                }
            },
            {
                test: /\.s?css$/,
                use: [MiniCssExtractPlugin.loader, 'css-loader', 'postcss-loader', 'sass-loader']
            }
        ]
    },
    plugins: [
        new MiniCssExtractPlugin({ filename: '../css/[name].css' }),
        new CopyWebpackPlugin({ patterns: [{ from: 'static/', to: '../' }] })
    ]
});