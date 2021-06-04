import ipc from 'node-ipc'
import * as util from './util'

export default class Client
	
	constructor id
		self.id = id
		host = null
		
		ipc.connectTo(id) do
			util.log('ipc','started?')
			host = ipc.of[id]
			host.on('connect') do 
				util.log('ipc','connected',arguments)
				emit('pong',Math.random!)
				
			host.on('message') do handle($1,$2)
			
	get ils
		global.ils
	
	def emit event, data = {}
		let payload = {
			type: 'event'
			event: event
			ts: Date.now!
			body: data
		}
		host.emit('message',payload)
	
	def handle e, sock = null
		# util.log('ipc_handle',e)
		if e.type == 'request'
			# util.log('call',e.command,e.arguments)
			util.log("receive request {e.command}")
			let t0 = Date.now!
			if let meth = ils[e.command]
				try
					let res = await meth.apply(ils,e.arguments)
					if res
						util.log("send response {e.command}",Date.now! - t0,e.command,res)
					
					host.emit('message',{
						type: 'response'
						responseRef: e.requestRef
						body: res
						ts: Date.now!
					})
				catch err
					util.log('error','responding',e.command,e.arguments,err)
				
				
			
			
		