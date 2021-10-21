import np from 'path'
import nfs from 'fs'

import * as ts from 'typescript/lib/tsserverlibrary'
import marked from 'marked'
import * as util from '../src/util'

const mdrenderer = new marked.Renderer
let codeblocknr = 0
let mdstate = {}

def mdrenderer.code code, lang, opts = {}
	
	let escaped = code.replace(/\</g,'&lt;').replace(/\>/g,'&gt;')
	let nr = ++codeblocknr
	return String(<app-code-block data-path="/docs"> <code data-name="{nr}.imba" data-lang=lang> escaped)

def mdrenderer.codespan code
	let m
	let o = {}
	
	if m = code.match(/^(\@\w+)$/)
		o.kind = 'event'
	elif m = code.match(/^(\@\w+)\.([\w\-]+)$/)
		o.kind = 'eventmodifier'
		
	if o.kind
		return String(<api-link name=code> code)

	let escaped = code.replace(/\</g,'&lt;').replace(/\>/g,'&gt;')
	return String(<app-code-inline data-lang='unknown'> escaped)

def mdrenderer.heading text, level
	mdstate[text] = yes
	return "<h{level}>{text}</h{level}>"
	
def toMarkdown str, meta
	mdstate = meta or {}
	marked(str,{renderer: mdrenderer})
###
export interface Logger {
        close(): void;
        hasLevel(level: LogLevel): boolean;
        loggingEnabled(): boolean;
        perftrc(s: string): void;
        info(s: string): void;
        startGroup(): void;
        endGroup(): void;
        msg(s: string, type?: Msg): void;
        getLogFileName(): string | undefined;
    }
###
class Logger
	def close
		yes
		
	def hasLevel lebel
		yes
		
	def loggingEnabled
		yes
		
	def perftrc
		yes
		
	def info str
		console.log str
	
	def startGroup
		console.group()
	
	def endGroup
		console.groupEnd()
		
	def msg str, type = null
		console.log str
	
	def getLogFileName
		undefined

let options = {
	host: ts.sys
	logger: new Logger
	pluginProbeLocations: [np.resolve(__dirname,'docs')]
	globalPlugins: ['typescript-imba-plugin']
	LanguageServiceMode: ts.LanguageServiceMode.Semantic
}

console.log options.pluginProbeLocations

let project = new ts.server.ProjectService(options)
let root = np.resolve(__dirname,'docs')
let abs = do(...parts) np.resolve(__dirname,'docs',...parts)
	
console.log root
project.openClientFile(abs('index.imba'))
console.log !!global.ils

# now go through and generate stuff?

let script = global.ils.getImbaScript('index.imba')
let checker = script.getTypeChecker!

def write name, data
	let dest = np.resolve(__dirname,'..','..','imba.io','public',name + '.json')
	nfs.writeFileSync(dest,JSON.stringify(data,null,2),'utf8')
	

def getDocs item,meta
	let raw = item.getDocumentationComment(checker.checker)
	let md = ''
	let docs = raw.map do(item)
		let text = item.text
		md += item.text
		return item
	
	# remove mdn reference for css props
	md = md.replace(/\[MDN Reference\].*\)/,'').trim!
	
	# if md.indexOf('MDN Reference') >= 0
	# 	console.log "MD",md
	# 	throw yes
		
	if md == ''
		return []
	
	return [toMarkdown(md,meta)]
	return docs

const api = {events: [],entries: []}

def generate-events
	console.log !!global.ils,!!script
	
	
	const paths = []
	
	def crawl item, suggestedKind
		return item.#doc if item.#doc
		item.#doc = {}
		# let type = checker.type("{name}.prototype")

		let type = checker.type(item)
		let base = checker.checker.getBaseTypes(type)
		let props = checker.props(type)
		let ref = type.symbol.escapedName
		let name = ref
		
		let up = base[0] ? crawl(base[0]).name : null
		let meta = {}
		
		let kind = 'interface'
		
		if checker.member(type,'stopImmediatePropagation') or name == 'ImbaTouch'
			kind = 'eventinterface'
		
		let doc = {
			name: ref
			kind: kind
			extends: up
			meta: meta
			members: []
			docs: getDocs(type.symbol,meta)
			tags: type.symbol.imbaTags or {}
		}

		api.entries.push(doc)
		paths[ref] = doc

		# doc
		# let props = checker.props(type)
		# let mods = props.filter do $1.escapedName != 'αoptions' and $1.escapedName[0] == 'α'
		let mods = props
		
		for item,i in mods
			let par = item.parent
			
			if i == 0
				console.log par.escapedName
				
			continue unless par.escapedName == name

			let tags = item.imbaTags
			
			continue if tags.deprecated

			let itemname = item.imbaName
			let meta = {}
			let docs = getDocs(item,meta)
			
			let kind = 'property'
			
			if item.method?
				kind = 'method'
			
			if itemname[0] == '@'
				kind = 'eventmodifier'
	
			let entry = {
				name: itemname
				meta: meta
				kind: kind
				tags: tags
				docs: docs
			}
			
			doc.members.push(entry)
			
		return item.#doc = type.#doc = doc

	
	let types = ['PointerEvent','DragEvent','KeyboardEvent','ImbaIntersectEvent','ImbaResizeEvent','ImbaTouch','ImbaElement']
	
	for name in types
		crawl(checker.type("{name}.prototype"))

	for item in checker.getEvents()
		let name = item.imbaName
		let type = checker.type(item)
		let typename = type.symbol.name
		
		let meta = {}
		let docs = getDocs(item,meta)
		let tags = item.imbaTags
		# check for other potential docs from ts
		let handler = checker.sym("GlobalEventHandlers.on{name}")
		if handler
			# console.log 'found handler',getDocs(handler,{})
			let docs2 = getDocs(handler,{})[0]
			if docs2 and !tags.summary
				tags.summary = docs2
		
		if paths[typename]
			
			let doc = {	
				name: name
				kind: 'event'
				type: typename
				meta: meta
				docs: docs
				tags: tags
			}

			api.entries.push(doc)
	
	# console.log api
	
	# let dest = np.resolve(__dirname,'..','..','imba.io','public','api.json')
	# nfs.writeFileSync(dest,JSON.stringify(api,null,2),'utf8')
	
def generate-styles
	let script = global.ils.getImbaScript('index.imba')
	let checker = script.getTypeChecker!
	
	let patterns = [
		[/^(box-(align|direction|flex|flex-group|orient|lines|pack)|rotate)$/,skip: yes]
		[/(border-.*radius)/,{radius: 1}]
		[/shadow/,{shadow: 1}]
		[/^text-/,{text: 1}]
		[/^font-/,{font: 1}]
		[/^border-/,{border: 1}]
		[/^grid-/,{grid: 1}]
		[/^flex\b/,{flex: 1}]
		[/^(padding|px|py)/,{padding: 1}]
		[/^(margin|mx|my)/,{margin: 1}]
		[/^(background)/,{bg: 1}]
		[/^(-background)/,{color: 1}]
		[/^overflow\b/,{layout: 1}]
		[/^(transform|x|y|z|skew(-[xyz])?|rotate|scale(-[xyz])?)\b/,{transform: 1}]
	]
	
	let map = {}
	# let api = {entries: []}
	
	for sym in checker.styleprops
		let name = sym.imbaName
		let tags = sym.imbaTags
		let key = sym.escapedName

		# let aliased = tags.proxy and util.toImbaIdentifier(tags.proxy)
		if tags.proxy
			if map[tags.proxy]
				map[tags.proxy].alias = name
				continue
			else
				map[tags.proxy] = {
					alias: name
					#alias: sym
				}
				continue
			

		let meta = {}
		
		for [pat,options] in patterns
			if pat.test(name)
				Object.assign(tags,options)

		let item = {
			name: name
			meta: meta
			kind: 'styleprop'
			tags: tags
			docs: getDocs(sym,meta)
		}
		
		if map[key]
			item = Object.assign(map[key],item)

		map[key] = item
		
		api.entries.push(item)
		
	for sym in checker.stylemods
		let name = sym.imbaName
		let tags = sym.imbaTags
		let key = sym.escapedName
		let meta = {}
		let cat = 'custom'
		let media = checker.member(sym,'media')
		let native = checker.member(sym,'name')
		let detail = tags.detail or ''
		
		if detail.match(/width|height/)
			tags.breakpoint = 1
		
		if media
			# cat = 'media'
			tags.media = 1
		elif detail.match(/^\:\:/)
			tags.pseudoelement = 1
		elif native
			tags.pseudoclass = 1
		else
			tags.custom = 1
		
		let item = {
			name: name
			meta: meta
			kind: 'stylemod'
			tags: tags
			docs: getDocs(sym,meta)
		}
		api.entries.push(item)

	console.log api.entries
	# write('api.css',api)

generate-events!
generate-styles!

write('api',api)
