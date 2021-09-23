
import * as util from './util'
import Context from './context'

import {Sym as ImbaSymbol,CompletionTypes as CT} from './lexer'
import type ImbaScript from './script'


const Globals = "global imba module window document exports console process parseInt parseFloat setTimeout setInterval setImmediate clearTimeout clearInterval clearImmediate globalThis isNaN isFinite __dirname __filename".split(' ')

const Keywords = "and await begin break by case catch class const continue css debugger def get set delete do elif else export extend false finally for if import in instanceof is isa isnt let loop module new nil no not null of or require return self static super switch tag then this throw true try typeof undefined unless until when while yes".split(' ')

###
CompletionItemKind {
		Text = 0,
		Method = 1,
		Function = 2,
		Constructor = 3,
		Field = 4,
		Variable = 5,
		Class = 6,
		Interface = 7,
		Module = 8,
		Property = 9,
		Unit = 10,
		Value = 11,
		Enum = 12,
		Keyword = 13,
		Snippet = 14,
		Color = 15,
		Reference = 17,
		File = 16,
		Folder = 18,
		EnumMember = 19,
		Constant = 20,
		Struct = 21,
		Event = 22,
		Operator = 23,
		TypeParameter = 24
	}
###

export class Completion
	
	data = {}
	label = {}
	exportInfo = null

	constructor symbol, context\Completions, options = {}
		#cache = {}
		#context = context
		#options = options
		sym = #symbol = symbol
		weight = options.weight or 1000
		
		item = {data: data, label: label, sortText: ""}
		load(symbol,context,options)
		kind = options.kind if options.kind
	
		setup!
		triggers options.triggers
		
	def load symbol, context, options = {}
		yes
		self
		
	def setup
		Object.assign(item,sym)
		
	get id
		return #nr if #nr >= 0
		#nr = #context.items.indexOf(self)
		
	
	
	get checker
		#context.checker
		
	get program
		checker.program
	
	get script
		checker.script

	get #type
		#symbol.type or #symbol.type_
		
	get weight
		#weight or #options.weight
	
	set weight val
		#weight = val
		
	def resolveAutoImport
		let info = exportInfo
		return unless info
		let alias = info.importName or info.name
		let name = info.importKind == 1 ? 'default' : alias
		let edits = doc.createImportEdit(info.source,name,alias)
		
		if edits.alias
			item.insertText = edits.alias
			ns = edits.alias

		elif edits.changes.length
			item.additionalTextEdits = edits.changes
		self
		
	get doc
		#context.doc
		
	def triggers chars = ''
		return self unless chars
		let list = item.commitCharacters ||= []
		for chr of chars
			list.push(chr) unless list.indexOf(chr) >= 0
		return self
	
	def #resolve
		if #resolved =? yes
			# console.log 'resolving item',self
			resolve!
		return item
	
	def resolve
		self

	get completion
		self
		
	get source
		null

	set kind kind
		item.kind = kind
	
	get kind
		item.kind

	set name val do label.name = val
	get name do label.name
		
	set type val do label.type = val
	get type do label.type

	set detail val
		item.detail = val

	set ns val
		if val isa Array
			val = val[0]
		
		if val and val.text
			val = val.text

		label.qualifier = val
	
	get ns
		label.qualifier
	
	set documentation val
		item.documentation = val

	get uniqueName
		#uniqueName or item.insertText or name
		
	get filterName
		item.insertText or name
		
	def shouldBeIncluded stack
		yes

	def serialize stack = {}
		let o = #options

		let key = uniqueName
		
		if sym.isInternal
			return null
			
		unless shouldBeIncluded(stack)
			return null
		
		if stack[key]
			return null

		if o.matchRegex
			return null unless o.matchRegex.test(filterName)

		stack[key] = self
		
		if o..commitCharacters
			item.commitCharacters = o.commitCharacters
		if #weight != undefined
			item.sortText ||= util.zerofill(#weight)
			data.nr = id
		# item.data.id ||= "{#context.file.id}|{#context.id}|{id}"
		return item
		
	def resolveImportEdits
		if let ei = exportInfo
			let asType = ei.exportedSymbolIsTypeOnly or #options.kind == 'type'
			let path = ei.packageName or util.normalizeImportPath(script.fileName,ei.modulePath)

			let alias = ei.importName or ei.exportName
			let name = (ei.exportKind == 1 or ei.exportKind == 2) ? 'default' : ei.exportName
			if ei.exportKind == 3
				name = '*'

			let edits = script.doc.createImportEdit(path,util.toImbaIdentifier(name),util.toImbaIdentifier(alias),asType)
			
			if edits.changes.length
				item.additionalTextEdits = edits.changes
				# ns = "from '{path}'"
		self

export class SymbolCompletion < Completion
	
	get symName
		sym.imbaName

	def setup
		let cat = #options.kind
		let par = sym.parent
		let tags = sym.imbaTags or {}
		let o = #options
		let f = sym.flags
		let ei = exportInfo

		name = symName
		item.cat = cat
		data.kind = cat

		try
			Object.assign(item,checker.getSymbolKind(sym))
			
		if #options.range
			item.range = #options.range
		
		# let pname = sym.parent..escapedName
		if cat == 'styleprop'
			#uniqueName = name

			if tags.alias and #options.abbr
				item.insertText = ns = tags.alias
			elif tags.proxy
				ns = tags.proxy
			triggers ':@.'
			kind = 9

		elif cat == 'styleval'
			weight = name[0] == '-' ? 2000 : 1000
			triggers ' '
			# let type = sym.parent.escapedName.slice(4)
			let desc = sym.getDocumentationComment! or []
			if desc[0] and desc[0].text
				ns = desc[0].text
			
			if tags.color
				kind = 15
				let shade = name.slice(-1)
				
				if shade == '4'
					item.sortText = "color-0-{name}"
				else
					item.sortText = "color-1-{name}"

				item.filterText = "{name}_{name}"

				detail = tags.color
			else
				kind = 'enum'
				
		elif cat == 'stylemod'
			ns = tags.detail
			# name = name.slice(1)
			kind = 'event'
			triggers ': '
			# name = '@' + name # always?
			# anem = name
		
		elif cat == 'tagevent'
			triggers '.='
			kind = 'event'
			name = '@' + name
		
		elif cat == 'tageventmod'
			triggers '.='
			# check signatures?
			if tags.detail..match(/^\(/)
				triggers '('

		elif cat == 'tagname'
			triggers '> .[#'
			kind = 'value'

		elif cat == 'tag'
			triggers ' '
			kind = 'value'
			item.filterText = name
			name = item.insertText = "<{name}>"
		elif cat == 'type'
			type = 'type'
			triggers ' [=,|&'
		else
			type = item.kind
			triggers '!(,.['
			
		if cat == 'implicitSelf'
			# item.insertText = item.filterText = name
			# name = "self.{name}"
			# ns = "self"
			yes
			
		if tags.snippet
			let snip = tags.snippet
			if cat == 'tag'
				snip = "<{snip}>"
			item.insertSnippet = snip
			type = 'snippet'
			if snip.indexOf('$') >= 0
				item.commitCharacters = []
				
		if tags.detail
			ns ||= tags.detail
		
		# check export info
		if ei
			if ei.packageName
				ns = "import from {ei.packageName}"
			else
				ns = "import from {util.normalizeImportPath(script.fileName,ei.modulePath)}"
			item.source = ns.slice(12)
			if ei.exportName == '*'
				ns = ns.replace(/^import /,'import * ')
			
			# dont be trigger-happy with commitCharacters for imports
			item.commitCharacters = item.commitCharacters.filter do(item)
				".!([, ".indexOf(item) == -1
			
			# make filter-text longer for imports to let variables rank eariler
			item.filterText = (item.filterText or name) + "        "
	
	def resolve
		let details = checker.getSymbolDetails(sym)
		
		item.markdown = details.markdown

		if let docs = details.documentation
			item.documentation = docs # global.session.mapDisplayParts(docs,checker.project)

		if let dp = details.displayParts
			item.detail = util.displayPartsToString(dp)
		# documentation: this.mapDisplayParts(details.documentation, project),
		# tags: this.mapJSDocTagInfo(details.tags, project, useDisplayParts),
		# item.documentation = details.documentation
		# item.documentation = details.documentation
		resolveImportEdits!
		self
		
export class AutoImportCompletion < SymbolCompletion
	
	def load symbol, context, options = {}
		exportInfo = symbol
		sym = symbol.symbol
		self
		
	get symName
		util.toImbaIdentifier(exportInfo.importName or exportInfo.exportName)
		
	get importPath
		exportInfo.packagName or exportInfo.modulePath
		
	get uniqueName
		symName + importPath
		
	def shouldBeIncluded stack
		# if there is a variable or other property with this name
		if stack[symName]
			return no
		return yes
		
export class ImbaSymbolCompletion < Completion
	
	def setup
		name = sym.name
		
export class KeywordCompletion < Completion
	def setup
		name = sym.name
		triggers ' '
		

export default class Completions
	
	constructor script\ImbaScript, pos, prefs
		self.script = script
		self.pos = pos
		self.prefs = prefs
		self.ls = ls or script.ls
		self.meta = {}
		self.config = global.ils.getConfig('suggest',{})

		#prefix = ''
		#added = {}
		#uniques = new Map
		
		items = []
		resolve!
		
	get opos
		#opos ??= script.d2o(pos)
		
	get checker
		# should we choose configured project or?
		#checker ||= script.getTypeChecker!
	
	get autoimporter
		checker.autoImports
		
	get triggerCharacter
		prefs.triggerCharacter
			
	def resolve
		ctx = script.doc.getContextAtOffset(pos)
		tok = ctx.token
		flags = ctx.suggest.flags
		prefix = ''

		if tok.match('identifier')
			prefix = ctx.before.token
			
		if ctx.suggest.prefix
			prefix = ctx.suggest.prefix
		
		if prefix
			prefixRegex = new RegExp("^[\#\_\$\<]*{prefix[0] or ''}")
		
		util.log('resolveCompletions',self,ctx,tok,prefix)
		
		if triggerCharacter == '=' and !tok.match('operator.equals.tagop')
			return
		
		# only show completions directly after : in styles	
		if triggerCharacter == ':' and !tok.match('style.property.operator')
			return
		
		if flags & CT.TagName
			util.log('resolveTagNames',ctx)
			add('tagnames',kind: 'tagname')
			
		if flags & CT.StyleModifier
			add checker.stylemods, kind: 'stylemod', range: ctx.suggest.stylemodRange
			
		if flags & CT.StyleSelector
			add checker.props('ImbaHTMLTags',yes), kind: 'stylesel'
		
		if flags & CT.StyleProp
			let cfg = config.preferAbbreviatedStyleProperties
			let inline = !ctx.group.closest('rule')
			let abbr = cfg != 'never' and (inline or cfg != 'inline')
			add checker.styleprops, kind: 'styleprop',abbr: abbr
			
		if flags & CT.StyleValue
			add 'stylevalue', kind: 'styleval'
			
		if flags & CT.Decorator
			add 'decorators', kind: 'decorator'
			
		if flags & CT.TagEvent
			add checker.props("ImbaEvents"), kind: 'tagevent'
			
		if flags & CT.TagEventModifier
			add checker.getEventModifiers(ctx.eventName), kind: 'tageventmod'
			# props("ImbaEvents.{ctx.eventName}.MODIFIERS"), kind: 'tageventmod'
			
		if flags & CT.TagProp
			add('tagattrs',name: ctx.tagName)
			
		if flags & CT.Type
			add('types',kind: 'type')
			
		if flags & CT.Access
			if ctx.target == null
				let selfpath = ctx.selfPath
				let selfprops = checker.props(selfpath)
				# || checker.props(loc.thisType)
				add(selfprops,kind: 'implicitSelf', weight: 300, matchRegex: prefixRegex)
			else	
				let typ = checker.inferType(ctx.target,script.doc)
				util.log('inferred type??',typ)
				if typ
					let props = checker.props(typ).filter do !$1.isWebComponent
					add props, kind: 'access', matchRegex: prefixRegex
		
		if flags & CT.Value
			add('values')
			
		if flags & CT.ClassBody
			yes
		
		if triggerCharacter == '<' and ctx.after.character == '>'
			add completionForItem({
				commitCharacters: [' ','<','=']
				filterText: ''
				preselect: yes
				sortText: "0000"
				kind: 'snippet'
				textEdit: {start: pos, length: 1, newText: ''}
				label: {name: ' '}
				action: 'cleanAngleBrackets'
			})
		# if triggerCharacter == '.' and tok.match('operator.access') and items.length
		# 	add completionForItem({
		# 		filterText: ''
		# 		commitCharacters: []
		# 		preselect: yes
		# 		sortText: "0000"
		# 		textEdit: {start: pos, length:0, newText: ''}
		# 		kind: 'snippet'
		# 		label: {name: ' '}
		# 	})
		self
		
	def stylevalue o = {}
		# let node = ctx.group.closest('styleprop')
		let name = ctx.suggest.styleProperty
		# let name = node..propertyName
		let before = ctx..before..group
		let nr = before ? (before.split(' ').length - 1) : 0
		
		let symbols = checker.stylevalues(name,nr)
		add symbols,o
		self
		
	def decorators o = {}
		# should include both global (auto-import) and local decorators
		# just do the locals for now?
		let vars = script.doc.varsAtOffset(pos).filter do $1.name[0] == '@'
		add(vars,o)
		
		let imports = checker.autoImports.getExportedDecorators!
		add(imports, o)
		self
		
	def tagnames o = {}
		let html = checker.props('HTMLElementTagNameMap')
		add(html,o)
		
		let locals = checker.sourceFile.getLocalTags!
		
		add(locals,o)
		add(checker.getGlobalTags!,o)
		
		util.log "local tags",locals

		
		try
			let autoTags = autoimporter.getExportedTags!
			add(autoTags,o)
		catch e
			util.log "autoimport error",e

		add(checker.snippets('tags'),o)
		
	def types o = {}
		add(checker.snippets('types'),o)
		# all globally available types
		let typesymbols = checker.getSymbols('Type')
		add(typesymbols,o)
		add(autoimporter.getExportedTypes!,{kind: 'type', weight: 2000})
		
	def tagattrs o = {}
		# console.log 'check',"ImbaHTMLTags.{o.name}"
		let sym = checker.sym("HTMLElementTagNameMap.{o.name}")
		# let attrs = checker.props("ImbaHTMLTags.{o.name}")
		let pascal = o.name[0] == o.name[0].toUpperCase!
		let globalPath = pascal ? o.name : util.toCustomTagIdentifier(o.name)

		unless sym
			sym = try checker.sym("{globalPath}.prototype")

		if sym
			# this is a native tag
			let attrs = checker.props(sym).filter do(item)
				let par = item.parent..escapedName
				return no if par == "GlobalEventHandlers"
				return no if item.escapedName.match(/className|(__$)/)
				return item.isTagAttr
			
			add(attrs,{...o, commitCharacters: ['=']})
		yes
		
	def values
		let vars = script.doc.varsAtOffset(pos)
		let symbols = []
		
		# find our location - want to walk to find a decent alternative
		# walk backwards to find the closest location known by typescript
		# let loc = checker.getLocation(pos,opos)
	
		for item in vars
			# hide decorators
			continue if item.name[0] == '@'

			let found = checker.findExactSymbolForToken(item.node)
			symbols.push(found or item)

		add(symbols,kind: 'var', weight: 200)
		
		# keywords
		
		if ctx.group.closest('tagcontent') and !ctx.group.closest('tag')
			add('tagnames',kind: 'tag',weight: 300)

		try
			let selfpath = ctx.selfPath
			let selfprops = checker.props(selfpath)
			# || checker.props(loc.thisType)
			add(selfprops,kind: 'implicitSelf', weight: 300, matchRegex: prefixRegex)
		
		# add('variables',weight: 70)
		# could also go from the old shared checker?
		add(checker.globals,weight: 500,matchRegex: prefixRegex, implicitGlobal: yes)

		if prefixRegex
			let imports = checker.autoImports.getVisibleExportedValues!
			imports = imports.filter do prefixRegex.test($1.importName or $1.exportName)
			add(imports, weight: 2000)
			
			# check for the export paths as well

		# variables should have higher weight - but not the global variables?
		# add('properties',value: yes, weight: 100, implicitSelf: yes)
		# add('keywords',weight: 650,startsWith: prefix)
		# add('autoimports',weight: 700,startsWith: prefix, autoImport: yes)
		
		if ctx.before.line.match(/^[a-z]*$/)
			add(checker.snippets('root'),kind: 'snippet')

		add(Keywords.map(do new KeywordCompletion({name: $1},self,kind: 'keyword', weight: 800)))
		self
		
	def completionForItem item, opts = {}
		if item isa Completion
			return item
		
		if item.#tsym
			item = item.#tsym

		let entry = #uniques.get(item)
		return entry if entry

		if item isa global.SymbolObject
			entry = new SymbolCompletion(item,self,opts)
		elif item isa ImbaSymbol
			entry = new ImbaSymbolCompletion(item,self,opts)
		elif item.hasOwnProperty('exportName')
			entry = new AutoImportCompletion(item,self,opts)
		elif item.label
			entry = new Completion(item,self,opts)

		#uniques.set(item,entry)
		return entry
		
	def add type, options = {}
		
		if type isa Completion
			items.push(type) unless items.indexOf(type) >= 0
			return self
		
		if type isa Array
			for item in type
				add(completionForItem(item,options))
			return self

		return self if #added[type] 
		#added[type] = []
		
		let t = Date.now!
		let results = self[type](options)
		
		util.log "called {type}",Date.now! - t

		if results isa Array
			for item in results
				add(completionForItem(item,options))
				# items.push(completionForItem(item))
			util.log "added {results.length} {type} in {Date.now! - t}ms"

		#added[type] = results or true
		return self

	def serialize
		let entries = []
		let stack = {}
		# util.time(&,'serializing') do
		for item in items
			let entry = item.serialize(stack)
			entries.push(entry) if entry

		# devlog 'serialized',entries,items
		return entries
		
	def find item
		items.find do $1.name == item