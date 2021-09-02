import data from './css-data.json'
import {aliases,StyleTheme} from 'imba/src/compiler/styler'
import * as theme from 'imba/src/compiler/theme'
import fs from 'fs'
import {Dts} from './util'


import {reference,parser,propertyReference} from './css-syntax-parser'

# https://github.com/gauthier-scano/CSSFormalSyntaxParser/blob/main/src/reference.js

const styles = new StyleTheme({})
const colorDescs = {
	current: 'The current color'
	transparent: 'Clear'
	clear: 'Clear'
}
const formatCache = {}
def getType format
	let parsed = parser.prototype.parseSyntax(format)
	parsed = parsed.as[0] if parsed.name == ' '
	
	formatCache[format] ||= if true
		let parsed = parser.prototype.parseSyntax(format)
		parsed = parsed.as[0] if parsed.name == ' '

		{
			maxlen: (parsed.quantity or [1,1])[1]
			desc: format
		}

def run
	let pdeep = do(val)
		if val isa Array
			for v in val
				pdeep(v)
			return
		console.log(val.name,val.quantity,val.isRequired,val.value)
		if val.as
			pdeep(val.as)

	let p = do(val)
		let parsed = parser.prototype.parseSyntax(val)
		if parsed.name == ' '
			parsed = parsed.as[0]
		# console.log val, parsed, getType(val)
		# ,parsed,parsed.as[0]
		# pdeep(parsed)
		
	let safeid = do(val)
		if val.indexOf('+') >= 0
			"'{val}'"
		elif val.indexOf('-') >= 0 or val.match(/[\ \-\+]/)
			"'{val}'"
		else
			val

	let props = []
	let types = {}
	
	let dts = new Dts
	let enumdts = new Dts
	
	let idify = do(str)
		str.replace(/\-/g,'Ξ').replace(/\@/g,'α')
		
	let skip = do(item)
		return yes if item.skip
		return yes if item.name.match(/^-(ms|moz|webkit|o)-/)
		return no
		
	let propmap = {}
	for item in data.properties
		propmap[item.name] = item
		
	for own alias,to of aliases
		let target = propmap[to]
		if target
			target.alias = alias
		else
			
	dts.w '/// <reference path="./styles.d.ts" />'
	dts.w '/// <reference path="./styles.theme.d.ts" />'

	dts.push('declare namespace imbacss')

	let patterns = [
		[/^(box-(align|direction|flex|flex-group|orient|lines|pack)|rotate)$/,skip: yes]
		[/^border-.+-width/,kind: 'BorderWidth']
		[/-(right|left|top|bottom|end|start)$/,side: yes]
		[/(padding|margin)/,{}]
		[/(border-.*radius)/,{enum: 'Ψradius'}]
		[/^box-shadow$/,{enum: 'Ψshadow'}]
		[/^font-size$/,{enum: 'Ψfs'}]
	]
	
	let patches = {
		transition: {
			skip: yes
		}
	}
	
	let signgroups = {}
	
	for item in data.properties
		let signature = item.sign = propertyReference[item.name]
		let patch = patches[item.name]
		Object.assign(item,patch) if patch
		# if signature and signature != item.syntax
		#	console.log("signature {item.name} {signature} ||| {item.syntax}")
			
		item.type = try getType(item.sign or item.syntax)
		
		let group = signgroups[item.sign] ||= []
		group.push(item.name)
		
		for [pat,options] in patterns
			if pat.test(item.name)
				Object.assign(item,options)
	
	# console.log "groups {Object.keys(signgroups).length}"

	for item in data.properties
		continue if skip(item)
		let id = idify(item.name)
		let types = item.restrictions
		let argtypes = new Set
		
		if item.enum
			argtypes.add(item.enum)
		
		if item.values..length
			argtypes.add('this')
			
		
		
		for entry in item.restrictions
			if entry == 'enum'
				argtypes.add('this')
			else
				let id = entry.split('(')[0]
				argtypes.add(idify('Ψ' + id))
				
		let alltypes = Array.from(argtypes)
		
		let sign = "val: {alltypes.join(' | ') or 'any'}"

		let len = Math.min(item.type..maxlen or 1,4)
		let nr = 1

		while nr < len
			sign += ", arg{nr++}: any"

		dts.doc!
		dts.w(item.description)
		# dts.br!.w("Syntax: {item.sign}\n") if item.sign
		dts.br!
		let mdn = "https://developer.mozilla.org/en-US/docs/Web/CSS/{item.name}"
		dts.w("[MDN Reference]({mdn})")
		dts.br!
		dts.w("@alias {item.alias}") if item.alias
		dts.undoc!
		
		dts.push("interface {id} extends _")
		dts.w("set({sign}): void;\n")
		
		if item.values..length
			for {name,description} in item.values
				continue if name.match(/['",]/)
				if description
					dts.w("/** {description} */")
				dts.w("{safeid idify name}: ''\n")
		
		# now go through the others
		dts.pop!
		
		if item.alias
			dts.w("/** @proxy {id} */")
			dts.w "interface {idify item.alias} extends {id} \{ \}"

	
	# dts.push("interface css$rule")
	# for item in data.properties
	# 	continue if skip(item)
	# 	dts.w('/**').w(item.description)
	# 	dts.w("@alias {item.alias}") if item.alias
	# 	dts.w('*/')
	# 	dts.w("{safeid item.name}:{item.propid};")
	# 
	# 	if item.alias
	# 		dts.w("/** @proxy {item.name} */")
	# 		dts.w "{safeid item.alias}:{item.propid};"

		
	dts.end!

	let out = String(dts)
	# console.log out
	fs.writeFileSync('../lib/styles.generated.d.ts',out)
	
	# for item in data.properties
	#	console.log item.name, item.syntax
	
run!