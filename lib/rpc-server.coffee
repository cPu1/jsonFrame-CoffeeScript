jsonRpcServer =
	isValidRpc: (rpc) ->
		params = rpc.params
		rpc.jsonrpc is '2.0' and typeof rpc.method is 'string' and (not rpc.hasOwnProperty('id') or typeof rpc.id is 'number') and (not params or Array.isArray params or typeof params is 'object') or (Array.isArray rpc and rpc.length)

	_invokeRpc: (rpc) ->
		methods = @methods
		method = rpc.method
		args = rpc.params
		id = rpc.id

		throw Error('request') if not @isValidRpc rpc
		if typeof methods[method] is 'function'
			try
				args = [args] if not Array.isArray args
				result = methods[method].apply methods, args
				result = null if typeof result is 'undefined'
				response =
					response: result
					id: id
			catch err
				response = @_buildError 'params', id
				response.error.data = err.stack
		else
			response = @_buildError 'method', id
		response.jsonrpc = '2.0'
		response if id

	_invokeBatch: (batchRequest) ->
		try
			console.log 'invoking batch', batchRequest
			batchResponse = (rpcRequest for rpcRequest in batchRequest when (rpcRequest = @_invokeRpc(rpcRequest))?)
		catch err
			batchResponse = @_buildError err.message

	_handleRpc: (rpcRequest) ->
		isBatch = Array.isArray rpcRequest
		if isBatch
			console.log 'invoking batcch', rpcRequest
			response = @_invokeBatch rpcRequest
		else
			try
				response = @_invokeRpc rpcRequest
			catch err
				console.log 'err', err
				response = @_buildError(err.message)
		response


	_buildError: (err, id) ->
		error = jsonRpcServer.errors[err]
		return {error: error, id: id or null}

jsonRpcServer.errors = 
	'parse': {message: 'Parse error', code: -32700}
	'request': {message: 'Invalid Request', code: -32600}
	'method': {message: 'Method not found', code: -32601}
	'params': {message: 'Invalid params', code: -32602}

module.exports = jsonRpcServer