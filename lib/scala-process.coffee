ChildProcess = require 'child_process'

module.exports=
class ScalaProcess
  setBlockCallback: (blockCallback)->
    @blockCallback = blockCallback

  initialize: (readyCallback, blockCallback)->
    @scala = ChildProcess.spawn 'scala'
    @scala.stdout.on 'data', (data) => @processOut data
    @scala.stderr.on 'data', (data) => @processErr data
    @scala.stdout.on 'close', (res) => @processClose res
    @readyCallback = readyCallback

    @waitingFirstLine = true

  buffer: ""
  error_buffer: ""

  constants:
    END_OF_BLOCK: "//[SCALA_WORKSHEET_END_OF_DATA]\n"

  writeBlock: (block)->
    @scala.stdin.write block
    @scala.stdin.write "\n"
    @scala.stdin.write @constants.END_OF_BLOCK

  processResultBlock: (resultBlock) ->
    if @waitingFirstLine
      @waitingFirstLine = false
      @readyCallback()
    else
      @blockCallback resultBlock

  processOut: (data) ->
    str = data.toString('utf-8')
    @buffer += str
    if str.contains "\n"
      blocks = @buffer.split @constants.END_OF_BLOCK
      @buffer = blocks.pop()
      # console.log "buffer now: #{@buffer}"
      # console.log blocks
      @processResultBlock block for block in blocks


  processErr: (data) ->
    error_buffer += data.toString('utf-8')

  processClose: (res) ->
    console.log "scala process closed with res: #{res}"
