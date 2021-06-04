import * as util from './util'

const userPrefs = {
	includeCompletionsForModuleExports:true
	importModuleSpecifierPreference: "shortest"
	importModuleSpecifierEnding: "minimal"
	includePackageJsonAutoImports:"on"
	includeAutomaticOptionalChainCompletions:false
}

const ambientMap = {
	fs: 'fs'
	child_process: 'cp'
	os: 'os'
	crypto: 'crypto'
}

export default class AutoImportContext
	
	constructor c
		checker = c
		tsc = checker.checker
		script = c.script
		self
		
	get ts
		global.ts
		
	get ils
		global.ils
		
	get ps
		global.ils.ps
		
	get exportInfoMap
		unless ts.codefix.getSymbolToExportInfoMap isa Function
			return #exportInfoMap ||= new Map()
		
		# @ts-ignore
		#exportInfoMap ||= ts.codefix.getSymbolToExportInfoMap(checker.sourceFile,checker.project,checker.program)
	
	get exportInfoEntries
		return #exportInfoEntries if #exportInfoEntries
		let map = exportInfoMap
		let out = #exportInfoEntries = []
		for [key,[info]] of map
			let [name,ref,ns] = key.split('|')
			continue if ns.match(/^imba_/)
			let path = getResolvePathForExportInfo(info) or ns
			info.modulePath = path
			info.packageName = getPackageNameForPath(path)
			info.#key = key
			info.exportName = name
			
			let isTag = try info.symbol.exports..has('$$TAG$$')
			info.isTag = isTag
			out.push(info)
		return out
		
	def getExportedValues
		exportInfoEntries.filter do !$1.exportedSymbolIsTypeOnly
		
	def getExportedTypes
		exportInfoEntries.filter do
			$1.exportedSymbolIsTypeOnly or ($1.symbol.flags & ts.SymbolFlags.Type)
	
	def getExportedTags
		exportInfoEntries.filter do $1.isTag
			
	def getPackageNameForPath path
		let m
		if m = path.match(/\@types\/([\w\.\-]+)\/index\.d\.ts/)
			return m[1]
			
		if m = path.match(/\/node_modules\/([\w\.\-]+)\//)
			return m[1]
		
		# @ts-ignore
		if !ts.pathIsAbsolute(path)
			return path
					
		return null
		
	def getPackageJsonsVisibleToFile
		ps.getPackageJsonsVisibleToFile(script.fileName)
	
	def getVisiblePackages
		let jsons = getPackageJsonsVisibleToFile(script.fileName)
		let packages = {}
		while let pkg = jsons.pop!
			let deps = Object.fromEntries(pkg.dependencies)
			let devDeps = Object.fromEntries(pkg.devDependencies or new Map)
			Object.assign(packages,deps,devDeps)
		return packages
		
	def getModuleSpecifierForBestExportInfo info
		# @ts-ignore
		let result = ts.codefix.getModuleSpecifierForBestExportInfo(info,checker.sourceFile,checker.program,checker.project,userPrefs)
		return result
		
	def getResolvePathForExportInfo info
		if let ms = info.moduleSymbol
			let path = ms.valueDeclaration..fileName
			path ||= util.unquote(ms.escapedName or '')
			return path
		return null
