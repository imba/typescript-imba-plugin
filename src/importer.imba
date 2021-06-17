import * as util from './util'
import np from 'path'
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
		let groups = {}
		let out = #exportInfoEntries = []
		
		let t = Date.now!
		for [key,[info]] of map
			let [name,ref,ns] = key.split('|')
			continue if ns.match(/^imba_/)
			let path = getResolvePathForExportInfo(info) or ns
			info.modulePath = path
			info.packageName = getPackageNameForPath(path)
			info.#key = key
			info.exportName = name
			
			let gid = info.packageName or info.modulePath
			let group = groups[gid] ||= {
				symbol: info.moduleSymbol
				modulePath: gid,
				name: util.pathToImportName(gid)
				exports: []
			}
			
			group.exports.push(info)
			
			if info.exportKind == 2 or info.exportKind == 1
				group.default = info
				
			if group.exports.length == 2
				# now we are ready to add a shared export for this whole file
				let ginfo = {
					exportKind: 3
					exportName: '*'
					importName: group.name
					modulePath: info.modulePath
					packageName: info.packageName
					symbol: info.moduleSymbol
					exportedSymbolIsTypeOnly: false
				}
				out.push(ginfo)
			
			let isTag = try info.symbol.exports..has('$$TAG$$')
			info.isTag = isTag
			out.push(info)
			
			if info.exportKind == 2
				info.exportName = util.pathToImportName(info.packageName or info.modulePath)
				
		util.log "exportInfoEntries in {Date.now! - t}"
		return out
		
	get exportPaths
		let packages = getVisiblePackages!
		let entries = exportInfoEntries
		
		let map = {}

		for entry in entries
			continue if entry.packageName and !packages[entry.packageName]
			let src = entry.packageName or entry.modulePath
			let source = map[src] ||= {
				modulePath: src,
				name: entry.packageName or np.basename(src).replace(/\.(d\.ts|tsx?|imba|jsx?)$/)
				exports: []
			}
			source.exports.push(entry)
			if entry.exportKind == 2 or entry.exportKind == 1
				source.default = entry
		
		let items = Object.values(map)
		items.#map = map
		return items
		
	def getExportedValues
		let entries = exportInfoEntries.filter do !$1.exportedSymbolIsTypeOnly
	
	def getVisibleExportedValues
		let entries = getExportedValues!
		let packages = getVisiblePackages!
		entries.filter do(entry)
			!entry.packageName or packages[entry.packageName]
		
	def getExportedTypes
		exportInfoEntries.filter do
			$1.exportedSymbolIsTypeOnly or ($1.symbol.flags & ts.SymbolFlags.Type)
	
	def getExportedTags
		exportInfoEntries.filter do $1.isTag
			
	def getPackageNameForPath path
		let m
		if m = path.match(/\@types\/((?:\@\w+\/)?[\w\.\-]+)\/index\.d\.ts/)
			return m[1]
			
		if m = path.match(/\/node_modules\/((?:\@\w+\/)?[\w\.\-]+)\//)
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
