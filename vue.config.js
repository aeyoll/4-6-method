module.exports = {
  publicPath: './',
  chainWebpack: config => {
    config
      .plugin('html')
      .tap(args => {
        args[0].title = 'Tetsu Kasuya 4:6 Brewing Method for V60 Calculator'
        return args
      })
  }
}