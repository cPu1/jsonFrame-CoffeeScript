jsonRpcClient = require './rpc-client'
net = require 'net'
jFrame = require './json-frame'

tcpJsonRpcClient = Object.create jsonRpcClient

tcpJsonRpcClient.init = (options = {lengthPrefix: 2}) ->
	#lengthPrefix = options? options.lengthPrefix or 2
	@jsonFrame = jFrame options
	jsonTransformer = @jsonFrame.jsonTransformer()
	@_socket = net.connect options
	@_socket.pipe jsonTransformer
	self = @
	jsonTransformer.on 'data', @_handleResponse.bind @
	.on 'parse error', console.log

tcpJsonRpcClient._fnQueue = {}

tcpJsonRpcClient.invoke = (method, params, fn) ->
	isBatch = typeof method is 'function'
	throw Error('Batch request must have a second argument as a callback for result') if isBatch and typeof params isnt 'function'
	if typeof params is 'function'
		[fn, params] = [params, null]
		#fn = params
		#params = null
	else if not Array.isArray(params) and typeof params isnt 'object' and typeof fn isnt 'function'
		throw 'Either params must be an array/object or fn must be a function'
	request = @buildRequest method, params
	@_socket.write @jsonFrame.build request
	id = if isBatch then @lastBatchId else request.id
	if not id? then process.nextTick fn	else @_fnQueue[id] = fn
	

tcpJsonRpcClient._handleResponse = (rpcResponse) ->
	response = @buildResponse rpcResponse
	fnQueue = @_fnQueue
	isBatch = Array.isArray rpcResponse
	id = if isBatch then response[0].id else response.id
	fn = fnQueue[id]

	delete fnQueue[id]

	return fn.apply null, response if isBatch
	fn.call null, response.error or null, response.response or null

tcpJsonRpcClient.notify = (method, params) ->
	notification = {method: method}
	throw Error 'Params must be absent, an array or an object' if params? and typeof params isnt 'object' and not Array.isArray
	notification.params = params if params
	@_socket.write @jsonFrame.build notification


module.exports = (options) ->
	rpcServer = Object.create tcpJsonRpcClient
	rpcServer.init options
	rpcServer
