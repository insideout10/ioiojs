fs     = require 'fs'
{exec} = require 'child_process'

appFiles  = [
  # omit src/ and .coffee to make the below lines a little shorter
  'ioiojs/activeElement'
  'ioiojs/arrowScroller'
  'ioiojs/fillify'
  'ioiojs/mapify'
  'ioiojs/menufy'
  'ioiojs/playerToolbar'
  'ioiojs/slidingMenu'
]

outputFilename = "ioio"

getVersion = ->
  packageJson = JSON.parse fs.readFileSync "#{__dirname}/package.json", 'utf-8'
  packageJson.version

task 'build', 'Build single application file from source files', ->
  version = do getVersion

  appContents = new Array remaining = appFiles.length
  for file, index in appFiles then do (file, index) ->
    fs.readFile "src/#{file}.coffee", 'utf8', (err, fileContents) ->
      throw err if err
      appContents[index] = fileContents.replace( /{{ VERSION }}/g, version )
      process() if --remaining is 0

  process = ->
    appContentsNoDebug = ""

    for fileContents, index in appContents
      for line, index in fileContents.split("\n")
        appContentsNoDebug += "#{line}\n" if -1 is line.indexOf("debug.log")

    fs.writeFile "lib/#{outputFilename}-#{version}.debug.coffee", appContents.join('\n\n'), 'utf8', (err) ->
      throw err if err
      exec "coffee --compile lib/#{outputFilename}-#{version}.debug.coffee", (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr
        fs.unlink "lib/#{outputFilename}-#{version}.debug.coffee", (err) ->
          throw err if err

    fs.writeFile "lib/#{outputFilename}-#{version}.coffee", appContentsNoDebug, 'utf8', (err) ->
      throw err if err
      exec "coffee --compile lib/#{outputFilename}-#{version}.coffee", (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr
        fs.unlink "lib/#{outputFilename}-#{version}.coffee", (err) ->
          throw err if err

    console.log 'Done.'
  
task 'minify', 'Minify the output file.', ->
  version = do getVersion
    
  exec "uglifyjs -o lib/#{outputFilename}-#{version}.min.js lib/#{outputFilename}-#{version}.js", (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
    console.log 'Done.'