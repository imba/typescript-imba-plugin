import {aliases,StyleTheme} from 'imba/src/compiler/styler'
import * as theme from 'imba/src/compiler/theme'
import fs from 'fs'
import {Dts} from './util'

import '../src/util'

# import {reference,parser,propertyReference} from './css-syntax-parser'

# https://github.com/gauthier-scano/CSSFormalSyntaxParser/blob/main/src/reference.js

const styles = new StyleTheme({})
const colorDescs = {
	current: 'The current color'
	transparent: 'Clear'
	clear: 'Clear'
}

def run
	let dts = new Dts
	
	dts.ind 'declare namespace imbacss' do
		
		# add colors first
		dts.ind 'interface Ψcolor' do
			for own name,value of styles.palette
				continue if name.match(/^grey\d/)
				
				if colorDescs[name]
					dts.w "/** {colorDescs[name]} */"
					dts.w "{name}: '{name}';"
				else
					let hsla = "hsla({parseInt(value.h)},{parseInt(value.s)}%,{parseInt(value.l)}%,{parseFloat(value.a) / 100})"
					dts.w "/** @color {hsla} */"
					dts.w "{name}: '{hsla}';"
					
				if name.match(/^blue\d/)
					let hsla = "hsla({parseInt(value.h)},{parseInt(value.s)}%,{parseInt(value.l)}%,{parseFloat(value.a) / 100})"
					dts.w "/** @color {hsla} */"
					dts.w "hue{name.slice(4)}: '{hsla}';"
		
		dts.ind 'interface Ψhue' do
			for own name,value of styles.palette
				continue if name.match(/^grey\d/) or !name.match(/^\w+4/)
				
				let hsla = "hsla({parseInt(value.h)},{parseInt(value.s)}%,{parseInt(value.l)}%,{parseFloat(value.a) / 100})"
				dts.w "/** @color {hsla} */"
				dts.w "{name.slice(0,-1)}: '{hsla}';"
				
			
		dts.ind "interface Ψfs" do
			for own name,value of theme.variants['font-size']
				continue unless name.match(/[a-z]/)
				let size = value isa Array ? value[0] : value
				dts.w "/** {size} */"
				dts.w "'{name}': '{size}';"
				
		dts.ind "interface Ψshadow" do
			for own name,value of theme.variants['box-shadow']
				continue unless name.match(/[a-z]/)
				let size = value isa Array ? value[0] : value
				dts.w "/** {size} */"
				dts.w "'{name}': '{size}';"
		
		dts.ind "interface Ψradius" do
			for own name,value of theme.variants.radius
				continue unless name.match(/[a-z]/)
				let size = value isa Array ? value[0] : value
				dts.w "/** {size} */"
				dts.w "'{name}': '{size}';"
		
		dts.ind "interface ΨtimingΞfunction" do
			for own name,value of theme.variants.easings
				continue unless name.match(/[a-z]/)
				let size = value isa Array ? value[0] : value
				dts.w "/** @easing {size} */"
				dts.w "{name.tojs!}: '{size}';"
			
	
	fs.writeFileSync('../lib/styles.theme.d.ts',String(dts))

	
run!