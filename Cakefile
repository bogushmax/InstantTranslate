{print} = require 'util'
{spawn} = require 'child_process'
fs      = require 'fs'

printResult = (process) ->
  process.stdout.on 'data', (data) -> print data.toString()
  process.stderr.on 'data', (data) -> print data.toString()

task 'build::coffee', 'Build .coffee files', ->
  options = ['-c', '-o', 'libraries', 'sources/coffee']
  coffee = spawn 'coffee', options
  printResult coffee

task 'build::less', 'Build .less files', ->
  for file in fs.readdirSync 'sources/less'
    options = ['sources/less/' + file, 'stylesheets/*']
    lessc = spawn 'lessc', options
    printResult lessc

task 'build::full', 'Build scripts and stylesheets', ->
  invoke 'build::coffee'
  invoke 'build::less'

task 'build::pack', 'Pack extension into .crx', ->
  console.log 'pack'
