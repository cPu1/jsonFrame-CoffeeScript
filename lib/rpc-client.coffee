jsonRpcClient = 
  batchIds: []
  
  buildRequest: (method, params) ->
	  id = Math.ceil Math.random() * 1000
	  isBatch = typeof method is 'function'
	  batchBuilder = @batchBuilder
	  batchIds = @batchIds

	  throw Error 'First argument must be a method name or batch callback' if typeof method isnt 'string' and not isBatch

	  throw Error 'Params must be absent, an array of positional parameters or a structured object' if params? and not Array.isArray(params) and typeof params isnt 'object'

	  if isBatch
	    batchBuilder.rpc = @
	    method batchBuilder
	    rpcRequest = batchBuilder.build()
	    throw Error 'Cannot build an empty batch. Requests must be added to batch using add or notify' if not rpcRequest.length
	    batchIds = batchIds.concat batchBuilder._batchIds
	    @lastBatchId = batchBuilder.batchId()
	    batchBuilder.clear()
	  else
	    rpcRequest = {method: method, id: id, jsonrpc: '2.0'}
	    rpcRequest.params = params if params?
	  return rpcRequest

  buildResponse: (rpcResponse) ->
  	isBatch = Array.isArray rpcResponse
  	batchIds = @batchIds

  	if isBatch
  		rpcResponse.sort (res1, res2) ->
  			batchIds.indexOf res1.id - batchIds.indexOf res2.id
  		startAt = batchIds.indexOf rpcResponse[0].id
  		batchIds.splice startAt, rpcResponse.length if ~startAt
  	rpcResponse

  buildNotification: (method, params) ->
  	throw 'Method must be a string and params must either be an array or absent' if typeof method isnt 'string' and params? and not Array.isArray params and typeof params isnt 'object'
  	request = {method: method, jsonrpc: '2.0'}
  	request.params = params if params?
  	request

  batchBuilder:
  	_batch: []
  	_batchIds: []
  	add: (method, params) ->
  		request = @rpc.buildRequest(method, params)
  		@lastBatchId = request.id if not @lastBatchId?
  		@_batch.push request
  		@_batchIds.push request.id
  		@
  	notify: (method, params) ->
  		@_batch.push(@rpc._buildNotification(method, params))
  		@
  	clear: ->
  		@_batch = []
  		@_batchIds = []
  		delete @lastBatchId
  	build: ->
  		@_batch
  	batchId: ->
  		@lastBatchId

module.exports = jsonRpcClient