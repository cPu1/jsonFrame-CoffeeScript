Transform = require('stream').Transform

jsonFrame = (options) ->
  lengthPrefix = options.lengthPrefix
  throw Error 'Frame size must be one of 1, 2, 4' if lengthPrefix? and lengthPrefix not in [1, 2, 4]
  
  lengthPrefix ?= 2

  writeBytes = 
    1: 'writeUInt8'
    2: 'writeUInt16BE'
    4: 'writeUInt32BE'
  
  writeBytes = writeBytes[lengthPrefix]

  maxBytes = (1 << lengthPrefix * 8) - lengthPrefix

  jFrame = 
    build: (o) ->
      str = if typeof o is 'object' then JSON.stringify o else o
      len = Buffer.byteLength str
      throw Error "Object cannot be larger than #{maxBytes} bytes" if len > maxBytes
      buffer = new Buffer lengthPrefix + len
      buffer[writeBytes] len, 0
      buffer.write str, lengthPrefix
      buffer

    jsonTransformer: ->
      new JsonTransformer lengthPrefix: lengthPrefix

class JsonTransformer extends Transform
  constructor: (options) ->
    if not (@ instanceof JsonTransformer)
      new JsonTransformer options
    Transform.call this, objectMode: true
    @buffer = new Buffer 0
    @lengthPrefix = options.lengthPrefix || 2
    _readBytes = 
      1: 'readUInt8'
      2: 'readUInt16BE'
      4: 'readUInt32BE'

    @readBytes = _readBytes[@lengthPrefix]
      
transform = ->
  buffer = @buffer
  lengthPrefix = @lengthPrefix

  if buffer.length > lengthPrefix
    @bytes = buffer[@readBytes] 0
    if buffer.length >= @bytes + lengthPrefix
      json = buffer.slice lengthPrefix, @bytes + lengthPrefix
      @buffer = buffer.slice @bytes + lengthPrefix
      try
        @push JSON.parse json
      catch err
        @emit 'parse error', err

      transform.call @

JsonTransformer::_transform = (chunk, encoding, next) ->
  @buffer = Buffer.concat [@buffer, chunk]
  transform.call @

JsonTransformer::_flush = ->
  console.log 'Flushed...'


module.exports = jsonFrame