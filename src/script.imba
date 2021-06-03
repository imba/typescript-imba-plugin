# extend scriptInfo
import fs from 'fs'
import * as util from './util'

import { TokenModifier, TokenType } from './constants'
import Compiler from './compiler'

import ImbaScriptInfo from './lexer/script'
import Completions from './completions'
import ImbaScriptContext from './context'
import ImbaTypeChecker from './checker'

export default class ImbaScript
	constructor info
		self.info = info

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

	def setup
		util.log("setup {fileName}",info.textStorage.text)	
		let orig = info.textStorage.text
		if orig == undefined
			orig = fs.readFileSync(fileName,'utf-8')

		svc = TS.server.ScriptVersionCache.fromString(orig or '')
		svc.currentVersionToIndex = do this.currentVersion
		svc.versionToIndex = do(number) number
		doc = new ImbaScriptInfo(self,svc)
		
		# now do the initial compilation?
		let result = compile!
		let its = info.textStorage
		let snap = its.svc = TS.server.ScriptVersionCache.fromString(result.js or '\n')
		its.text = undefined
		its.reload = do(newText)
			util.log('reload',fileName,newText)
			return false

		snap.getSnapshot!.mapper = result
		return self
		
	def lineOffsetToPosition line, offset, editable
		svc.lineOffsetToPosition(line, offset, editable)
		
	def positionToLineOffset pos
		svc.positionToLineOffset(pos)

	def asyncCompile
		util.log('async compile!')
		let snap = svc.getSnapshot!
		let body = snap.getText(0,snap.getLength!)
		let output = Compiler.compile(info,body)
		output.input = snap

		if output.js
			applyOutput(output)
	
	def applyOutput result
		let its = info.textStorage
		let end = its.svc.getSnapshot!.getLength!
		util.log('compiled',fileName,end,its)

		its.edit(0, end, result.js)
		let snap = its.svc.getSnapshot!
		snap.mapper = result
		info.markContainingProjectsAsDirty!
		# probably dont want to do this while editing all the time?
		global.session.refreshDiagnostics!

	def editContent start, end, newText
		svc.edit(start,end - start,newText)
		# this should just start asynchronously instead
		if global.ils.isSemantic
			util.delay(self,'asyncCompile',250)

	def compile
		let snap = svc.getSnapshot!
		let body = snap.getText(0,snap.getLength!)
		let result = Compiler.compile(info,body)
		result.input = snap
		return result
		
	get snapshot
		svc.getSnapshot!
	
	get content
		let snap = svc.getSnapshot!
		return snap.getText(0,snap.getLength!)
			
	get fileName
		info.path
		
	get ls
		info.containingProjects[0].languageService
		
	def wake
		yes
		
	def getTypeChecker sync = no
		try
			let project = info.containingProjects[0]
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
		util.log('imba_getCompletionsAtPosition',[dpos,opos],prefs)
		let ctx = new Completions(self,[dpos,opos],prefs,ls)
		return ctx.getResults!
	
	def getContextAt pos
		# retain context?
		new ImbaScriptContext(self,pos)
		
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
		
		let hit = do(sym,typ)
			if typ
				out[typ] = sym
			out.sym ||= sym 
	

		if tok.match("style.property.modifier style.selector.modifier")
			let [m,pre,post] = tok.value.match(/^(@|\.+)([\w\-\d]*)$/)

			if pre == '@' or pre == ''
				out.sym ||= checker.sym([checker.cssmodifiers,post])
				
		if g = grp.closest('stylevalue')
			let idx = (ctx..before..group or '').split(' ').length - 1
			let alternatives = checker.getStyleValues(g.propertyName,idx)
			let match = alternatives.find do $1.escapedName == tok.value
			if match
				hit(match,'value')
		
		if g = grp.closest('styleprop')
			out.sym ||= checker.sym([checker.cssrule,g.propertyName])
			
		if tok.match('tag.event.name')
			let name = tok.value.replace('@','')
			hit(checker.sym("ImbaEvents.{name}"),'event')
			# out.sym ||= 
			
		if tok.match('tag.name')
			let name = tok.value.replace('@','')
			hit(checker.sym("ImbaHTMLTags.{name}"),'tag')
		
		if tok.match('white keyword')
			return {}
			
		if out.sym
			out.info = checker.getSymbolInfo(out.sym)
		
		if out.info
			out.info.textSpan ||= tok.span

		return out
			
		
	def getQuickInfo pos, ls
		let out = getInfoAt(pos,ls)
		
		if out.info
			return out.info

		return null