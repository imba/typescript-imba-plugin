import np from 'path'
import Compiler from './compiler'
import * as util from './util'
import Bridge from './bridge'
import ipc from 'node-ipc'

import {DefaultConfig} from './constants'

let libDir = np.resolve(__realname,'..','..','lib')

global.dirPaths = [__dirname,__filename,__realname]
global.libDir = libDir



export default class Service
	setups = []
	bridge = null
	ipcid
	
	get ts
		global.ts
	
	get configuredProjects
		Array.from(ps.configuredProjects.values())
		
	get cp
		configuredProjects[0]
		
	get ip
		ps.inferredProjects[0]
		
	get isSemantic
		ps.serverMode == 0
		
		
	def i i
		let d = m.im.doc
		let t = m.im.getTypeChecker!
		return {
			i: i
			d: d
			t: t
			c: d.getContextAtOffset(i)
			x: t.getMappedLocation(i)
		}
		
	def getCompletions file,pos,ctx
		let script = getImbaScript(file)
		util.log('getCompletions',file,pos,ctx,script)
		let res = #lastCompletions = script.getCompletions(pos,ctx)
		return res.serialize!
		
	def onDidChangeTextEditorSelection file,opts = {}
		util.log('onDidChangeTextEditorSelection',file,opts)
		return null
		
	def onDidSaveTextDocument file
		util.log('onDidSaveTextDocument',file)
		
	def resolveCompletionItem item, data
		util.log('resolveCompletionItem',item,data)
		if let ctx = #lastCompletions
			if let item = ctx.items[data.nr]
				item.resolve!
				return item.serialize!
		return 
		
	def getExternalFiles proj
		if proj.#gotImbaFiles =? true
			# maybe follow up on the configured projects?
			let files = ps.host.readDirectory(cwd,['.imba'],['node_modules'],[],4)
			util.log "GET EXTERNAL FILES!!!",arguments,files
			return files
		return []	
		
		
	def handleRequest {id,data}
		# util.log('handleRequest',data)
		bridge ||= new Bridge(id)
		bridge.handle(data)
		
	def ensureConfiguredProject
		let file = JSON.stringify(DefaultConfig,null,2)
		let src = resolvePath('jsconfig.json')
		ps.openClientFile(src,file,ts.ScriptKind.JSON,cwd)
		
	def prepareProjectForImba proj
		# host.readDirectory(project.currentDirectory,null,['node_modules'],['*.imba'],4)
		let inferred = proj isa ts.server.InferredProject
		let opts = proj.getCompilerOptions!
		let libs = opts.lib or ["esnext","dom","dom.iterable"]

		opts.lib =  libs.concat([np.resolve(libDir,'imba.d.ts')])
		
		if inferred
			opts.checkJs = true

		for lib,i in opts.lib
			let mapped = ts.libMap.get(lib)
			if mapped
				opts.lib[i] = mapped

		proj.setCompilerOptions(opts)
		util.log('compilerOptions',proj,opts)
		return proj

	def create info
		#cwd ||= info.project.currentDirectory
		util.log('create',info)
		setups.push(info)

		self.info = info
		self.project = info.project
		self.ps = project.projectService
		
		let proj = info.project
		
		# let inferred = proj isa ts.server.InferredProject
		# intercept options for inferred project
		prepareProjectForImba(proj) if proj
			
			
		setup! if ps.#patched =? yes
			
		info.ls = info.languageService
		# ps.ensureConfiguredImbaProjects!
		return decorate(info.languageService)
		
	def convertSpan span, ls, filename, kind = null
		if util.isImba(filename) and span.#ostart == undefined
			span.#ostart = span.start
			span.#olength = span.length
			let mapper = ls.getProgram!.getSourceFile(filename)
			let [start,end] = mapper.o2d(span)
			span.start = start
			span.length = end - start
		return span
		
		
	def convertLocationsToImba res, ls, filename
		if res isa Array
			for item in res
				convertLocationsToImba(item,ls,item.fileName)
		
		if !res
			return res

		if util.isImba(filename)
			for key in ['text','context','trigger','applicable']
				if let span = res[key + 'Span']
					convertSpan(span,ls,filename,key)
			# if res.textSpan
			# 	convertSpan(res.textSpan,ls,filename,'text')
			# if res.contextSpan
			# 	convertSpan(res.contextSpan,ls,filename,'context')
			# if res.triggerSpan
			# 	convertSpan(res.triggerSpan,ls,filename,'trigger')
			# if res.applicableSpan
			# 	convertSpan(res.applicableSpan,ls,filename,'trigger')
			if res.textChanges
				for item in res.textChanges
					# this is an imba-native version!!
					if item.span == undefined and item.start != undefined
						item.span = {start: item.start, length: item.length}
						item.span.#ostart = 0
					else
						convertSpan(item.span,ls,res.fileName or filename,'edit')
		
		if res.changes
			convertLocationsToImba(res.changes, ls,filename)
			
		if res.references
			convertLocationsToImba(res.references, ls)
		
		if res.defintion
			convertLocationsToImba(res.defintion, ls,res.fileName)
			
		if res.definitions
			for item in res.definitions
				convertLocationsToImba(item,ls,item.fileName or item.file)
				
		if res.fileName and typeof res.name == 'string'
			res.name = util.toImbaString(res.name)
			
		if res.displayParts
			for dp,i in res.displayParts
				if dp.text.indexOf('$') >= 0
					dp.text = util.toImbaString(dp.text,dp,res.displayParts)

		return res
		
	def getFileContext filename, pos, ls
		let script = getImbaScript(filename)
		let opos = script ? script.d2o(pos,ls.getProgram!) : pos
		return {script: script, filename: filename, dpos: pos, opos: opos}
		
		
	def decorate ls
		if ls.#proxied
			return ls

		let intercept = Object.create(null)
		ls.#proxied = yes
		# no need to recreate this for every new languageservice?!
		
		intercept.getEncodedSemanticClassifications = do(filename,span,format)
			if util.isImba(filename)
				let script = getImbaScript(filename)
				let spans = script.getSemanticTokens!
				return {spans: spans, endOfLineState: ts.EndOfLineState.None}

			return ls.getEncodedSemanticClassifications(filename,span,format)
		
		intercept.getEncodedSyntacticClassifications = do(filename,span)
			return ls.getEncodedSyntacticClassifications(filename,span)
			
		intercept.getQuickInfoAtPosition = do(filename,pos)
			let {script,dpos,opos} = getFileContext(filename,pos,ls)
			if script
				# let convpos = script.d2o(pos,ls.getProgram!)
				let out = script.getQuickInfo(dpos,ls)
				util.log('getQuickInfo',filename,dpos,opos,out)
				if out
					return out

			let res = ls.getQuickInfoAtPosition(filename,opos)
			return convertLocationsToImba(res,ls,filename)
			
		intercept.getDefinitionAndBoundSpan = do(filename,pos)
			let {script,dpos,opos} = getFileContext(filename,pos,ls)
			let res = ls.getDefinitionAndBoundSpan(filename,opos)
			res = convertLocationsToImba(res,ls,filename)
			
			if script and res and res.definitions
				let hasImbaDefs = res.definitions.some do util.isImba($1.fileName)
				if hasImbaDefs
					res.definitions = res.definitions.filter do util.isImba($1.fileName)

			# for convenience - hide certain definitions
			util.log('getDefinitionAndBoundSpan',script,dpos,opos,filename,res)
			return res
			
		intercept.getDocumentHighlights = do(filename,pos,filesToSearch)
			return if util.isImba(filename)
			return ls.getDocumentHighlights(filename,pos,filesToSearch)
			
			
		intercept.getRenameInfo = do(file, pos, o = {})
			# { allowRenameOfImportPath: this.getPreferences(file).allowRenameOfImportPath }
			let {script,dpos,opos} = getFileContext(file,pos,ls)
			let res = convertLocationsToImba(ls.getRenameInfo(file,opos,o),ls,file)
			
			return res
			
		intercept.findRenameLocations = do(file,pos,findInStrings,findInComments,prefs)
			let {script,dpos,opos} = getFileContext(file,pos,ls)
			let res = ls.findRenameLocations(file,opos,findInStrings,findInComments,prefs)
			res = convertLocationsToImba(res,ls)
			return res
			# (location.fileName, location.pos, findInStrings, findInComments, hostPreferences.providePrefixAndSuffixTextForRename)
		
		intercept.getEditsForFileRename = do(oldPath, newPath, fmt, prefs)
			let res = ls.getEditsForFileRename(oldPath, newPath, fmt, prefs)
			res = convertLocationsToImba(res,ls)
			return res
		
		intercept.getSignatureHelpItems = do(file, pos, args)
			let {script,dpos,opos} = getFileContext(file,pos,ls)
			let res = ls.getSignatureHelpItems(file,opos,args)
			res = convertLocationsToImba(res,ls,file)
			return res
		
		intercept.getCompletionsAtPosition = do(file,pos,prefs)
			let {script,dpos,opos} = getFileContext(file,pos,ls)
			
			if script
				let res = script.getCompletionsAtPosition(ls,[dpos,opos],prefs)
				return res

			let res = ls.getCompletionsAtPosition(file,opos,prefs)
			return res
			
		intercept.getNavigationTree = do(file)
			if util.isImba(file)
				let script = getImbaScript(file)
				let res1 = ls.getNavigationTree(file)
				let res2 = script.doc.getOutline!
				util.log('navtree',res1,res2)
				return res2

			let res = ls.getNavigationTree(file)
			return res
			
		intercept.getOutliningSpans = do(file)
			if util.isImba(file)
				let script = getImbaScript(file)
				return null
			return ls.getOutliningSpans(file)
		
		intercept.getCompletionEntryDetails = do(file,pos,name,fmt,source,prefs,data)
			let {script,dpos,opos} = getFileContext(file,pos,ls)
			let res = ls.getCompletionEntryDetails(file,opos,name,fmt,source,prefs,data)
			return res

		intercept.getCodeFixesAtPosition = do(file,start,end,code,fmt,prefs)
			let {script,dpos,opos} = getFileContext(file,start,ls)
			let {opos: endopos} = getFileContext(file,end,ls)

			let res = ls.getCodeFixesAtPosition(file,opos,endopos,code,fmt,prefs)
				
			# "Add 'TextField' to existing import declaration from "./tags/field""
			# "Import 'TextField' from module "./tags/field.imba""
			# 
			for fix in res
				let m
				# rewrite import codefix
				if script and fix.fixName == 'import'
					let name = fix.description.split("'")[1]
					let path = fix.description.split('"')[1].replace(/\.imba$/,'')
					fix._name = name
					fix._path = path
					# experimental
					let edit = script.doc.createImportEdit(path,name,name)
					fix._changes = edit.changes
					fix.changes[0].textChanges = edit.changes

			res = convertLocationsToImba(res,ls,file)
			return res
		
		# const res = project.getLanguageService().getCombinedCodeFix({ type: "file", fileName: file }, fixId, this.getFormatOptions(file), this.getPreferences(file));
		# getCombinedCodeFix(scope: CombinedCodeFixScope, fixId: {}, formatOptions: FormatCodeSettings, preferences: UserPreferences): CombinedCodeActions;
		intercept.getCombinedCodeFix = do(scope,fixId,fmt,prefs)
			let res = ls.getCombinedCodeFix(scope,fixId,fmt,prefs)
			if res.changes
				convertLocationsToImba(res.changes,ls)
				util.log('getCombinedCodeFix',arguments,res)
			return res
			
		intercept.getNavigateToItems = do(val\string, max\number, file\string, excludeDtsFiles\boolean)
			let res = ls.getNavigateToItems(val,max,file,excludeDtsFiles)
			convertLocationsToImba(res,ls)
			return res
		
		# fileName: string, positionOrRange: number | TextRange, preferences: UserPreferences | undefined, triggerReason?: RefactorTriggerReason, kind?: string
		intercept.getApplicableRefactors = do(...args)
			let res = ls.getApplicableRefactors(...args)
			return res
			
		intercept.findReferences = do(file,pos)
			let {script,dpos,opos} = getFileContext(file,pos,ls)
			let res = ls.findReferences(file,opos)
			res = convertLocationsToImba(res,ls)
			util.log('findReferences',file,dpos,opos,res)
			return res


		if true
			for own k,v of intercept
				let orig = v
				intercept[k] = do
					try
						let res = v.apply(intercept,arguments)
						util.log(k,arguments,res)
						return res
					catch e
						util.log('error',k,e)

		
		return new Proxy(ls, {get: do(target,key) return intercept[key] || target[key]})
	
	def rewriteInboundMessage msg
		msg
		
	def setup
		for script in imbaScripts
			script.wake!
		self
	
	def getScriptInfo src
		ps.getScriptInfo(resolvePath(src))
		
	def getImbaScript src
		getScriptInfo(src)..im
	
	def getSourceFile src
		let info = getScriptInfo(src)
		info..cacheSourceFile..sourceFile
		
	get scripts
		Array.from(ps.filenameToScriptInfo.values())
		
	get imbaScripts
		# scripts.filter(do(script) util.isImba(script.fileName)).map(do(script) script.imba)
		scripts.map(do $1.#imba).filter(do $1)

	get cwd
		#cwd ||= normalizePath(process.env.VSCODE_CWD or process.env.IMBASERVER_CWD)
	
	get m
		getScriptInfo('main.imba')
			
	get u
		getScriptInfo('util.imba')
	
	def getExt src
		src.substr(src.lastIndexOf("."))

	def normalizePath src
		src.split(np.sep).join(np.posix.sep)
		
	def resolvePath src
		normalizePath(np.resolve(cwd,src || '__.js'))