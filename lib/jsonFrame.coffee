jsonRpcServer = require './tcp-rpc-server'
jsonRpcClient = require './tcp-rpc-client'
jFrame = require './json-frame'

jsonFrame = (options) ->
	jsonFrameBuilder = jFrame options
	return {
		server: (methods) ->
			options.methods = methods;
			jsonRpcServer(options)
		client: (options) ->
			jsonRpcClient(options)
		jsonTransformer: ->
			jsonFrameBuilder.jsonTransformer()
		build: ->
			jsonFrameBuilder.build.apply jsonFrameBuilder, arguments;
	}

module.exports = jsonFrame;
