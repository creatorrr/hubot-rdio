require 'flour'

{readdirSync} = require 'fs'

task 'build', 'Compile .coffee files in src/ to lib/', ->
  isCoffee = (file) -> /\.(coffee|litcoffee|coffee\.md)$/.test file

  for file in files = readdirSync 'src' when isCoffee file
    compile "src/#{ file }", "lib/#{ compiled = file.replace /(coffee)$/, 'js' }"

task 'compile', 'Alias: build', -> invoke 'build'

task 'watch', 'Watch and compile .coffee files.', ->
  watch 'src/*.*', -> invoke 'build'
