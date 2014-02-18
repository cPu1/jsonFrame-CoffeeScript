jFrame = require './jsonFrame'
jsonFrame = jFrame({lengthPrefix: 2})
methods = require './methods'
jsonRpcServer = jsonFrame.server methods
jsonRpcClient = jsonFrame.client {host: 'localhost', port: 3000}

jsonRpcServer.listen 3000

jsonRpcClient.invoke 'add', [123123, 5235888.213], (err, res) ->
	err || console.log res