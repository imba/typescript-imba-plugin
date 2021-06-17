# extend scriptInfo
import fs from 'fs'
import * as util from './util'

import { TokenModifier, TokenType } from './constants'
import Compiler,{Compilation} from './compiler'

import ImbaScriptInfo from './lexer/script'
import Completions from './completions'
import ImbaScriptContext from './context'
import ImbaTypeChecker from './checker'

export default class ImbaScript
	constructor info
		self.info = info
		self.diagnostics = []
		global.hasImbaScripts = yes

		if info.scriptKind == 0
			info.scriptKind = 1
			util.log("had to wake script {fileName}")
			

			
	def getMapper target
		let snap = target ? target.getSourceFile(fileName).scriptSnapshot : info.getSnapshot!
		return snap.mapper
		
	def getText start = 0, end = null
		snapshot.getText(start,end)
		
	def o2d pos, source
		getMapper(source).o2d(pos)
			
	def d2o pos, source
		getMapper(source).d2o(pos)
			
	def typeAt pos
		let tc = getTypeChecker!
		tc.typeAtLocation(pos)
		
	def openedWithContent content
		util.log('openedWithContent',fileName)

	def setup
			
		let orig = info.textStorage.text
		if orig == undefined
			# if this was already being edited?!
			orig = fs.readFileSync(fileName,'utf-8')
			util.log("setup {fileName} - read from disk",orig.length)
		else
			util.log("setup {fileName} from existing source",orig.length,info)

		svc = global.ts.server.ScriptVersionCache.fromString(orig or '')
		svc.currentVersionToIndex = do this.currentVersion
		svc.versionToIndex = do(number) number
		doc = new ImbaScriptInfo(self,svc)
		
		# if global.ils.isSemantic
		# now do the initial compilation?
		try
			let result = lastCompilation = compile!
			let its = info.textStorage
			let snap = its.svc = global.ts.server.ScriptVersionCache.fromString(result.js or '\n')
			its.text = undefined
			its.reload = do(newText)
				util.log('reload',fileName,newText.slice(0,10))
				return false
			util.log('resetting the original file',snap)
			snap.getSnapshot!.mapper = result
			info.markContainingProjectsAsDirty!
		catch e
			util.log('setup error',e,self)

		return self
			
	def lineOffsetToPosition line, offset, editable
		svc.lineOffsetToPosition(line, offset, editable)
		
	def positionToLineOffset pos
		svc.positionToLineOffset(pos)

	def asyncCompile
		util.log('async compile!')
		let snap = svc.getSnapshot!
		let body = snap.getText(0,snap.getLength!)
		let output = new Compilation(info,snap)
		# Compiler.compile(info,body)
		output.compile!
		applyOutput(output)
	
	def applyOutput result
		lastCompilation = result
		diagnostics=result.diagnostics

		if let js = result.js
			let its = info.textStorage
			let end = its.svc.getSnapshot!.getLength!
			util.log('compiled',fileName,end,its)
			its.edit(0, end, result.js)
			let snap = its.svc.getSnapshot!
			snap.mapper = result
			info.markContainingProjectsAsDirty!
			global.session.refreshDiagnostics!
		else
			util.log('errors from compilation!!!',result)
			diagnostics=result.diagnostics
			global.session.refreshDiagnostics!
		self
		
	def getImbaDiagnostics
		
		let mapper = lastCompilation
		let entries = mapper.diagnostics
		let diags = []
		
		if mapper.input.#saved
			util.log('imba diagnostics saved!')
		else
			return []
		
		for entry in entries
			let start = mapper.i2d(entry.range.start.offset)
			let end = mapper.i2d(entry.range.end.offset)
			let diag = {
				category: 1
				code: 2551
				messageText: entry.message
				relatedInformation: []
				start: start
				length: (end - start)
				source: entry.source or 'imba'
			}
			diags.push diag

		return diags

	def editContent start, end, newText
		svc.edit(start,end - start,newText)
		# this should just start asynchronously instead
		if global.ils.isSemantic
			util.delay(self,'asyncCompile',250)

	def compile
		let snap = svc.getSnapshot!
		let output = new Compilation(info,snap)
		# let body = snap.getText(0,snap.getLength!)
		# let result = Compiler.compile(info,body)
		# result.input = snap
		return output.compile!

		
	get snapshot
		svc.getSnapshot!
	
	get content
		let snap = svc.getSnapshot!
		return snap.getText(0,snap.getLength!)
			
	get fileName
		info.path
		
	get ls
		project.languageService
		
	get project
		info.containingProjects[0]
		
	def wake
		yes
		
	def didSave
		try
			snapshot.#saved = yes
		yes
		
	def getTypeChecker sync = no
		try
			let project = project
			let program = project.program
			let checker = program.getTypeChecker!
			return new ImbaTypeChecker(project,program,checker,self)

		
	def getSemanticTokens
		let result\number[] = []
		let typeOffset = 8
		let modMask = (1 << typeOffset) - 1
		
		for tok,i in doc.tokens when tok.symbol
			let sym = tok.symbol
			let typ = TokenType.variable
			let mod = 0
			let kind = sym.semanticKind
			if TokenType[kind] != undefined
				typ = TokenType[kind]
				
			if sym.global?
				mod |= 1 << TokenModifier.defaultLibrary
			
			if sym.static?
				mod |= 1 << TokenModifier.static
			
			if sym.imported?
				typ = TokenType.namespace

			result.push(tok.offset, tok.endOffset - tok.offset, ((typ + 1) << typeOffset) + mod)
		
		# util.log("semantic!",result)
		return result
		
	
		
	def getCompletions pos, options
		util.log('getCompletionsScript',pos,options)
		let ctx = new Completions(self,pos,options)
		return ctx
		
	
	def getCompletionsAtPosition ls, [dpos,opos], prefs
		return null
		
	def getContextAt pos
		# retain context?
		new ImbaScriptContext(self,pos)
	
	def resolveModuleName path
		let res = project.resolveModuleNames([path],fileName)
		return res[0] and res[0].resolvedFileName
		
	def resolveImport path, withAssets = no
		global.ts.resolveImportPath(path,fileName,project,withAssets).resolvedModule..resolvedFileName
		
	def getInfoAt pos, ls
		let ctx = doc.getContextAtOffset(pos)
		let out = {}

		if ctx.after.token == '' and !ctx.before.character.match(/\w/)
			if ctx.after.character.match(/[\w\$\@\#\-]/)
				ctx = doc.getContextAtOffset(pos + 1)
		
		let g = null
		let grp = ctx.group
		let tok = ctx.token or {match: (do no)}
		let checker = getTypeChecker!
		
		out.textSpan = tok.span
		
		let hit = do(sym,typ)
			if typ
				out[typ] = sym
			out.sym ||= sym
		
		# likely a path?
		if ctx.suggest.Path
			let str = tok.value
			util.log('get info for path?!',str)
			# ought to take paths from imbaconfig / jsconfig into account?!
			out.resolvedPath = util.resolveImportPath(fileName,str)
			out.resolvedModule = resolveImport(str,yes)

		if tok.match("style.property.modifier style.selector.modifier")
			let [m,pre,post] = tok.value.match(/^(@|\.+)([\w\-\d]*)$/)

			if pre == '@' or pre == ''
				out.sym ||= checker.sym([checker.cssmodifiers,post])
				
		if g = grp.closest('stylevalue')
			let idx = (ctx..before..group or '').split(' ').length - 1
			let alternatives = checker.getStyleValues(g.propertyName,idx)
			let match = alternatives.find do $1.escapedName == tok.value
			if match
				hit(match,'stylevalue')
				
		
		if g = grp.closest('styleprop')
			hit(checker.sym([checker.cssrule,g.propertyName]),'styleprop')
			# out.sym ||= checker.sym([checker.cssrule,g.propertyName])
			
		if tok.match('tag.event.name')
			let name = tok.value.replace('@','')
			hit(checker.sym("ImbaEvents.{name}"),'event')
			# out.sym ||= 
			
		if tok.match('tag.name')
			let name = tok.value.replace('@','')
			let pascal = util.isPascal(name)
			
			if pascal
				hit(checker.resolve(name),'tag')
			else
				hit(checker.sym("ImbaHTMLTags.{name}"),'tag')
				unless out.sym
					let path = "globalThis.{util.toCustomTagIdentifier(name)}"
					if let typ = checker.type(path)
						hit(typ.symbol,'tag')

		if tok.match('white keyword')
			return {info: {}}
			
		if out.sym
			out.info ||= checker.getSymbolInfo(out.sym)
		
		if out.info
			out.info.textSpan ||= tok.span

		return out
		
	def getDefinitionAndBoundSpan pos, ls
		let out = getInfoAt(pos,ls)
		
		if out.resolvedModule
			return {
				definitions: [{
					fileName: out.resolvedModule
					textSpan: {start: 0, length: 0}
				}]
				textSpan: out.textSpan
			}
		return null
			
		
	def getQuickInfo pos, ls
		let out = getInfoAt(pos,ls)
		
		if out.info
			return out.info

		return null