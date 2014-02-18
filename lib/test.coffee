rpcClient = require './rpc-client'
rpcServer = require './rpc-server'
tcpRpcServer = require './tcp-rpc-server'
tcpRpcClient = require './tcp-rpc-client'
methods = require './methods'

console.log(rpcClient.buildRequest('createUser', {name: 'asdf'}))


console.log rpcServer.isValidRpc {method: 'asdf', jsonrpc: '2.0', id: 123}

tcpRpcServer = tcpRpcServer({lengthPrefix: 2, methods: methods})
tcpRpcClient = tcpRpcClient({lengthPrefix: 2, host: 'localhost', port: 3000})

tcpRpcClient.invoke 'add', [1,2,3,4], (err, res) ->
	console.log('asfasdf', err, res)

tcpRpcClient.invoke 'findVowels', [['a', '2', 'o']], console.log

tcpRpcClient.invoke (batch) ->
	batch.add 'add', [1,11]
		.add 'add', [22, 20]
, (res1, res2) ->
	console.log 'batch resultttt', res1, res2

tcpRpcServer.listen 3000

