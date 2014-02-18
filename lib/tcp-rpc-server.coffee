jsonRpcServer = require('./rpc-server')
jFrame = require('./json-frame')
net = require 'net'

tcpJsonRpcServer = Object.create jsonRpcServer
tcpJsonRpcServer.init = (options) -> 
	@methods = options.methods
	jsonFrame = jFrame {lengthPrefix: options.lengthPrefix or 2}
	jsonTransformer = jsonFrame.jsonTransformer()
	self = @
	@_rpcServer = net.createServer (socket) ->
		socket.pipe jsonTransformer

		jsonTransformer.on 'data', (json) ->
			response = self._handleRpc json
			console.log 'handled', response
			socket.write jsonFrame.build response if Array.isArray(response) and response.length or response.id
		.on 'parse error', (err) ->
			parseError = self._buildError err
			socket.write jsonFrame.build parseError

tcpJsonRpcServer.listen = (port) ->
	@_rpcServer.listen port

module.exports = (options) ->
	rpcServer = Object.create tcpJsonRpcServer
	rpcServer.init(options)
	rpcServer