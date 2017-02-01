#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
require 'pathname'


module KELKO
	module TOOLS

		#a class for creating the "about"-data of the program
		#follows the singleton-pattern (->GoF, Design Patterns)
		class About
			#the known licenses
				LICENCE_GPL = "GNU General Public Licence"
				LICENCE_LGPL = "GNU Lesser/Library General Public Licence"
				LICENCE_BSD = "BSD-Licence"
				LICENCE_CC = "Creative-Common Licence"
				LICENCE_CC_BY_NC = "Creative-Common Licence BY NC (Non-Commercial)"
				LICENSE_CC_BY_NC_ND = "Creative-Common Licence BY NC ND (Non-Commercial, Non-Derivate)"
				LICENSE_CC_BY_NC_SA = "Creative-Common Licence BY NC SA (Non-Commercial, Share Alike)"
				LICENCE_PD = "Public Domain"
				LICENCE_OWN = "Own licence, see COPYRIGHT.txt"
				
				KEY_NAME = "name"
				KEY_DESC = "desc"
				KEY_AUTHOR = "author"
				KEY_MAIL = "mail"
				KEY_VERSION = "version"
				KEY_LICENSE = "license"

			private
				@@instance = nil
				
				#the constructor
				def initialize
					#default-informations
					#of cause mine ;-)
					@about = {'name'=>nil,'desc'=>nil, 'author'=>":kelko:",'mail'=>"kelko@anakrino.de",'version'=>0.1,'licence'=>About::LICENCE_GPL}
				end	
		
			public
				
				#-> singleton-pattern
				def About.getInstance
					@@instance = About.new unless @@instance
					@@instance
				end
		
				#get the information "key"
				#one of the KEY_ constants can be used
				def get(key)
					@about[key]
				end
		
				#set the information "key" to the value "val"
				def set(key,val)
					@about[key] = val
					self
				end
				
				#prints out the about-data
				def to_s
					msg = "About "
					msg += "#{@about['name']}" if @about['name']
					msg += "#{$0}" unless @about['name']
					msg += ":\n\tDescription:\t#{@about['desc']}" if @about['desc']
					msg += "\n\tAuthor:\t\t#{@about['author']} (#{@about['mail']})\n\tVersion:\t#{@about['version']}\n\tLicence:\t#{@about['licence']}\n"
					
				end
		
				#imports a about-hashtable
				#does not check anything
				def <<(newAbout)
					@about = newAbout
					newAbout
				end
		
				#returns the information as array
				def to_a
					output = [
						@about['name'],
						@about['desc'],
						@about['author'],
						@about['mail'],
						@about['version'],
						@about['licence']
					]
					output
				end
		
				#returns the hashtable
				def to_h
					@about
				end
		
		end
		#the 'result' of the CommandLineParser
		#holds all the things the CLP parsed from the arguments
		
		class ParsedArguments
		
			#constructor
			def initialize
				@flags = {}
				@params = {}
				@options = {}
			end

			#set the named flag to the value
			def newFlag(name,val)
				@flags[name] = val
				self
			end

			#set the named parameter to a value
			def newParam(name,val)
				@params[name] = val
				self
			end

			#set the named option to a value
			def newOption(name,val)
				@options[name] = val
				self
			end

			#checks whether the flag is set
			def flagSet?(flag)
				@flags[flag]
			end
			
			#checks whether the option is set
			def optionSet?(option)
				@options[option] != nil
			end

			#gets the value of the named parameter
			def getParam(name)
				@params[name]
			end
			
			#gets the value of the named parameter
			def paramSet?(name)
				@params[name] != nil
			end

			#gets the value of the named option
			def getOption(name)
				@options[name]
			end

		end

		
		#a parser for commandline arguments in a style inspired by the
		#gnu commandline options
		
		#three types of arguments can be defined:
		# flag 
		# option
		# parameter
	
		#a flag is a boolean value, the flag is set or it isn't
		
		#the option is quite a mix between boolean value an string-value
		#there can be the option set, but it must not
		#and the option has, if set, a value which can be get
		
		#a parameter is .. well ... an argument of the programm
		#the thinks you work with
		#there are required parameter which must not be missing
		#but there can be optional parameters as well which may
		#be missing

		#follows the singleton-pattern (->GoF, Design Patterns)
		class CommandLineParser
		private 

			@startMessage = nil
			@endMessage = nil

			@@instance = nil
			def initialize
				#the default-flags set by the CLP
				@flags = [
					{'name'=>"help",'option'=>"h",'longoption'=>"help",'desc'=>"Shows the help-message and quits", 'quit'=>false},
					{'name'=>"version",'option'=>nil,'longoption'=>"version",'desc'=>"Prints the version and quits", 'quit'=>false},
					{'name'=>"about",'option'=>nil,'longoption'=>"about",'desc'=>"Prints the About-data and quits", 'quit'=>false}
				]
				@options = []
				@params = []
			end

			#print the help (called  by --help)
			def print_help
				puts self
			end

			#print the version (called by --version)
			def print_version
				puts "#{About.getInstance.get('version')}\n"
			end

			#print the about-data (called by --about)
			def print_about
				puts About.getInstance
			end

		public 
			#prints an error that occured
			def print_error(errmsg)
				puts("\n\nError: #{errmsg}\n\n")
				puts self
			end

			attr_reader :flags, :options, :params
			attr_writer :flags, :options, :params, :startMessage, :endMessage

			#the possible types of the parameters
			PARAM_REQUIRED = 1
			PARAM_OPTIONAL = 0
			PARAM_MULTI = 2 
			#may be only 1 multi-param
			
			# -> singleton-pattern
			def CommandLineParser.getInstance
				@@instance = CommandLineParser.new unless @@instance
				return @@instance
			end

			#allow the named flag, save the description (for --help)
			#autoQuit means: if this flag is parsed do not parse any
			#further but go back to the caller of "parseArguments"
			
			# -flag --longflag
			# flag shall be just one char
			def allowFlag(name,flag, longflag, desc, autoQuit = false)
				@flags << {'name'=>name,'option'=>flag,'longoption'=>longflag,'desc'=>desc, 'quit'=>autoQuit}
				return self
			end

			#disallow the named flag
			def disallowFlag(name)
				@flags.delete_if do |flag|
					flag['name'] == name
				end
			end

			#allow the named option, save the description for --help
			
			# -option=val --longopt=val
			# option shall be just one char
			def allowOption(name, option, longopt, desc)
				@options << {'name'=>name,'option'=>option,'longoption'=>longopt,'desc'=>desc}
				return self
			end

			#disallow the named option
			def disallowOption(name)
				 @options.delete_if do |option|
					option['name'] == name
				end
			end

			#allow a parameter, save the description for --help and
			#the type of the parameter
			def allowParam(name, desc, type = CommandLineParser::PARAM_OPTIONAL)
				@params << {'name'=>name,'desc'=>desc,'type'=>type}
				return self
			end

			#disallow the named parameter
			def disallowParam(name)
				@params.delete_if do |param|
					param['name'] == name
				end
			end


			#the --help output, simply prompts the well-known
			#--help informations, consisting of:
			def to_s
				msg = ""
				#a start message from the author of the prog
				msg += "#{@startMessage}\n" if @startMessage
				#how to use
				msg += "USAGE: #{$0.split(/\//).reverse[0]} [Flags] [Options] PARAMS\n"

				#the allowed flags
				msg += "\nWith Flags:\n"
				@flags.each do |flag|
					msg += "-#{flag['option']}" if flag['option']
					msg += "\t"
					msg += "--#{flag['longoption']}" if flag['longoption']
					msg += "\t\t"
					msg += flag['desc']
					msg += "\n"
				end

				#the allowed options
				msg += "\nWith Options:\n"
				@options.each do |option|
					msg += "-#{option['option']}" if option['option']
					msg += "\t"
					msg += "--#{option['longoption']}" if option['longoption']
					msg += "\t\t"
					msg += option['desc']
					msg += "\n"
				end

				#the allowed parameter
				msg += "\nWith PARAMS: (in this order)\n"
				@params.each do |param|
					msg += "#{param['name']}\t#{param['desc']}"
					msg += " (Required) " if param['type'] == CommandLineParser::PARAM_REQUIRED
					msg += " (Multi-param) " if param['type'] == CommandLineParser::PARAM_MULTI
					msg += "\n"
				end
				
				msg += "\n"
				#an end message from the author of the prog
				msg += "#{@endMessage}\n" if @endMessage
				

				return msg
			end

			#do the work
			#parse the argument-array and create the 
			#ParsedArguments-object
			def parseArguments(argv)
				#but don't do that if called by the irb
				if $0 == 'irb' then return nil end
				
				
				begin
					#the result
					pa = ParsedArguments.new
					
					#if already parsing parameter no
					#option or flag may occure
					atParams = false
					#at which parameter are you?
					paramNr = 0
					multi = []
			
					
					argv.each do |arg|
						
						if !atParams then #flags and options
							case arg
								when /^-{1,1}(\w)=(.+)$/ then
								#a seems-option occured (with 1 dash -> option)
									found = false
									@options.each do |option|
										#is there a option with this char
										found = option['name'] if option['option'] == $1
									end
									
									pa.newOption(found, $2) if found
									raise "#{$1} is no valid option" unless found
								
								when /^-{2,2}(\w[\w\-]+)=(.+)$/ then
								#a seems-option occured (with 2 dashes -> longopt)
									found = false
									@options.each do |option|
										#is there a option with this longopt
										found = option['name'] if option['longoption'] == $1
									end
									
									pa.newOption(found, $2) if found
									raise "#{$1} is no valid option" unless found
								
								when /^-{1,1}(\w+)$/ then
								#a seems-flag (with one dash)
									$1.scan(/(.)/) do |char| 
										found = false
										@flags.each do |flag|
											found = flag if flag['option'] == char[0]
											break if found
										end
										
										if found then
											pa.newFlag(found['name'], true)
											#quit parsing if set "autoQuit"
											raise ArgumentError, 'quit' if found['quit']
										else
											raise "#{char[0]} is no valid flag"
										end
										
									end
								
								when /^-{2,2}(\w[\w\-]+)$/ then
								#a seems-flag (with two dashes)
									found = false
									@flags.each do |flag|
										found = flag if flag['longoption'] == $1
										break if found
									end
									
									if found then
										pa.newFlag(found['name'], true)
										#quit parsing if set "autoQuit"
										raise ArgumentError, 'quit' if found['quit']
									else
										raise "#{$1} is no valid flag"
									end
									 
								
								else
									atParams = true
									redo
							end
							
						else #parameter
							if paramNr >= @params.length  then 
								#wow, so many arguments are not allowed
								raise "Too much arguments passed"
								
							elsif @params[paramNr]['type'] == CommandLineParser::PARAM_MULTI then
								#all parameter coming now are put together into the array
								multi << arg
							else 
								#new parameter found
								pa.newParam(@params[paramNr]['name'], arg)
								paramNr = paramNr.next
								
							end
							
							
						end
						
						#the three shortcircut-validation
						#print the message for that flag
						#and quit
						if pa.flagSet?('help') then 
							print_help
							raise ArgumentError
						elsif pa.flagSet?('about') 
							then print_about
							raise ArgumentError
						elsif pa.flagSet?('version') 
							then print_version
							raise ArgumentError
						end
					end
					
					#save the multi-parameter
					pa.newParam(@params[paramNr]['name'],multi) if multi.length > 0
					
					#haven't parsed enough arguments!
					#some required-arguments are not set
					raise 'Not enough arguments passed' if @params.length > paramNr and @params[paramNr]['type'] == CommandLineParser::PARAM_REQUIRED
					
					
					return pa
					
				rescue RuntimeError => error
					#some error occured
					print_error(error)
					return nil
					
				rescue ArgumentError => arg
					#autoQuit
					return pa if arg.message == 'quit'
					#shortcircut-validation
					return nil 
				end
			end
		end
	
	end
end


class NotMyJobException < Exception
end

class OnlySimpleExpressionsHere < Exception
end

class WTF < Exception
end


class QuoteParser

	attr_accessor :processor

	def eofFound
	end
	
	def parse(line, words)
		@processor.write line
	end

end


class NullExpression

	def evaluate
		nil
	end

	def to_s
		"null"
	end
end

class SimpleExpression

	attr_accessor :value
	
	def evaluate
		return @value
	end
	
	def to_s
		@value.to_s
	end

end

class QuoteExpression

	attr_accessor :fileName
	attr_accessor :processor
	
	def evaluate
		# "lazy" evaluation
		@processor.quoteInput(@fileName, QuoteParser.new)
	end
	
	def to_s
		@fileName
	end

end

class ImportExpression
	attr_accessor :fileName
	attr_accessor :parameters
	attr_accessor :processor
	
	def initialize
		@parameters = {}
	end
	
	def evaluate
		# "lazy evaluation"
		@processor.processInput(@fileName, BasicStructureParser.new, @parameters)
	end
	
	def to_s
		@fileName
	end
end

class CompoundExpression

	def initialize
		@values = {}
	end
	
	def [](key)
		return @values[key]
	end
	
	def []=(key, value)
		@values[key] = value
	end
	
	def evaluate
		return @values
	end
	
	def to_s
		msg = "{\n"
		
		@values.each do |key, val| 
			msg << "#{key}: #{val}\n"
		end
		
		msg += "}\n"
		
		return msg
	end

end



module VarNameExpansion

	def varNameSplitter 
		/([\w]*)\.(.*)/
	end

	def expandCompoundVarName(varName, varDeposit)
	
		if varName =~ varNameSplitter
			key = $1
			rest = $2
			
			expression = varDeposit[key]
			
			if expression.is_a?(CompoundExpression)
				return expandCompoundVarName(rest, expression.evaluate)
			
			else
				puts varName
				p varDeposit
				p expression
				raise WTF
			end
		
		else
			return varDeposit[varName]
			
		end
	
	end
	
end


class LoadParser

	include VarNameExpansion

	attr_accessor :processor
	
	def initialize( valueStore )
		@valueStore = valueStore
	end

	def eofFound
	end
	
	def parse(line, words)
		
		case words[0]				
			when "if", "unless"
				processIfOrUnless(line, words)
				
			when "else", "end"
				raise NotMyJobException
				
			else
				parser = LoadAssignmentParser.new
				
				parser.processor = @processor
				key, val = parser.parseSingleLine(line)
				
				@valueStore[key] = val
				@processor.define(key, val)
		end
	end

	def dup
		LoadParser.new(@valueStore)
	end

	def processIfOrUnless(line, words)
		ifParser = IfParser.new( LoadParser.new(@valueStore) )
		@processor.registerParser(ifParser)
		ifParser.parse(line, words)
		
	end

end


class HereDocumentParser

	attr_accessor :processor
	
	def initialize(expression, markerExpansion = "") 
		@expression = expression
		@markerExpansion = markerExpansion
		@stringBuffer = []
	end
	
	def eofFound
		raise WTF
	end
	
	def parse(line, words)
		
		if line =~ /^<<(\w*)\s*$/
			gotExpansion = $1
			if @markerExpansion == gotExpansion
				
				@expression.value = @stringBuffer.join("\n")
				@processor.dropParser
				return
			
			end
		end
		
		
		@stringBuffer << line
		
	end
	
	
end


class GlobalParser

	attr_accessor :processor
	
	def initialize(skip = false)
		@skip = skip
		@valueStore = {}
	end

	def eofFound
		raise WTF
	end	
	
	def parse(line, words)
		
		case line
			when /\-\slocal\s\-/, /\-\sinjection\s\-/
				@processor.defineGlobals(@valueStore) unless @skip
				raise NotMyJobException
				
			when /\-\stemplate\s\-/
				raise WTF
		end

		return if @skip
		
		parser = LoadAssignmentParser.new
				
		parser.processor = @processor
		key, val = parser.parseSingleLine(line)
				
		@valueStore[key] = val
	end

end


class LoadAssignmentParser

	attr_accessor :processor
	
	def initialize(valueStore = CompoundExpression.new)
		@values = valueStore
	end

	def eofFound
	end	
	
	def whenFinished (&block)
		@whenFinished = block
	end
		
	def parseSingleLine(line)
		process partsOf(line)
		return assignedVariable
	end
	
	def parse(line, words)
		
		if words[0] == "}" or words[0] == "},"
		
			if @whenFinished
				@whenFinished.call
			end
			
			@processor.dropParser
			return		
		end
		
		process partsOf(line)
	end
	
	def process(parts)
		variable = parts[0]
		expression = parts[1]
		
		case expression.strip
			
			when "end", "else"
				raise NotMyJobException
			
			when "{"
				parseCompound(variable)
			
			when /(\w*)>>/
				expansion = $1
				parseHereDocument(variable, expansion)
		
			when /"(.*[^\\])"/, /'(.*[^\\])'/
				value = $1
				setVariable(variable, value)
				
			when /([A-Za-z][\w\.]*)/
				value = @processor.valueFor($1)
				@values[variable] = value
			
			when /(\d+\.\d+)/
				value = Float($1)
				setVariable(variable, value)
			
			when /(\d+)/
				value = Integer($1)
				setVariable(variable, value)
				
			else
				raise WTF

		end
	end
	
	
	def partsOf(line)
		unless line.strip =~ /^(\w[\w\d]*):\s+(.*)$/
			raise WTF
		end
		return $1, $2
	end
	
	def assignedVariable
		key = @values.evaluate.keys[0]
		value = @values[key]
		
		return key, value
	end	
	
	def setVariable(varName, value)
		
		sE = SimpleExpression.new
		sE.value = value
		
		@values[varName] = sE
	end
	
	def parseHereDocument(varName, markerExpansion = "")
		sExp = SimpleExpression.new
		@values[varName] = sExp;
		
		@processor.registerParser HereDocumentParser.new(sExp, markerExpansion)
	end
	
	def parseCompound(varName)
		cExp = CompoundExpression.new
		@values[varName] = cExp
		
		@processor.registerParser self.class.new(cExp)
	end

end

class GlobalAssignmentParser < LoadAssignmentParser

	def initialize(valueStore = CompoundExpression.new)
		super(valueStore)
	end
	
	def process(parts)
		variable = parts[0]
		expression = parts[1]
		
		case expression.strip
				
			when /load\("(.*)"\)\s\{/
				fileName = $1
				loadFileWithParameters(variable, fileName)
				
			when /load\("(.*)"\)/
				fileName = $1
				loadFile(variable, fileName)
				
			else
				super(parts)

		end
	end
	
	def loadFile(varName, fileName)
		cExp = CompoundExpression.new		
		@values[varName] = cExp
		
		@processor.processInput( fileName, LoadParser.new(cExp))
	end
	
	def loadFileWithParameters(varName, fileName)
		# the compound for parameters for load()
		cExp = CompoundExpression.new
		aParser = AssignmentParser.new(cExp)
		
		# the compound for results of load
		innerCExp = CompoundExpression.new	
		# assigned now, filled with content later
		@values[varName] = innerCExp
		
		aParser.whenFinished do
			# filled with content now
			@processor.processInput( fileName, LoadParser.new(innerCExp), cExp.evaluate)
		end
		
		@processor.registerParser aParser
	end
	
end

class AssignmentParser < GlobalAssignmentParser

	def initialize(valueStore = CompoundExpression.new)
		super(valueStore)
	end

	def process(parts)
		variable = parts[0]
		expression = parts[1]
		
		case expression.strip
		
			when /quote\("(.*)"\)/
				fileName = $1
				quoteFile(variable, fileName)
				
			when /import\("(.*)"\)\s\{/
				fileName = $1
				importFileWithParameters(variable, fileName)
				
			when /import\("(.*)"\)/
				fileName = $1
				importFile(variable, fileName)
				
			else
				super(parts)

		end
	end
	
	def quoteFile(varName, fileName)
		qExp = QuoteExpression.new
		qExp.processor = @processor
		qExp.fileName = fileName
		
		@values[varName] = qExp
	end	
	
	def importFile(varName, fileName)
		iExp = ImportExpression.new
		iExp.processor = @processor
		iExp.fileName = fileName
		@values[varName] = iExp
		
		return iExp
	end
	
	def importFileWithParameters(varName, fileName)
		# the compound for parameters for import()
		cExp = CompoundExpression.new
		aParser = AssignmentParser.new(cExp)
		
		iExp = importFile(varName, fileName)
		
		aParser.whenFinished do
			iExp.parameters = cExp.evaluate
		end
		
		@processor.registerParser aParser
	end

end


class SkipParser

	attr_accessor :processor
	
	def initialize()
		@counter = 0
	end
	
	def eofFound
		raise WTF
	end
	
	def parse(line, words)
		
		if words[0] == "if" or	words[0] == "unless" then
			increment
			
		elsif nested? 
			# else in a nested does not do anything
			# so check only for end
			if words[0] == "end"
				decrement
			end

		else
			if words[0] == "else" or  words[0] == "end"
				drop
			end
			
		end
	end
	
	def increment
		@counter += 1
	end

	def decrement
		@counter -= 1
	end
	
	def nested?
		@counter > 0
	end
	
	def drop
		raise NotMyJobException
	end

end


class IfParser

	attr_accessor :processor
	
	def initialize(parserPrototype)
		@parserPrototype = parserPrototype
		@processed_a_block = false
	end
	
	def eofFound
		raise WTF
	end
	
	def parse(line, words)
	
		case words[0]
			when "if", "unless"
				processIf(words)
				
			when "else"
			
				if @processed_a_block
					@processor.registerParser( SkipParser.new )
					
				elsif words.size > 1
					processIf(words[1..-1])
					
				else
					@processor.registerParser( @parserPrototype.dup )
					@processed_a_block = true
				
				end
				
			when "end"
				@processor.dropParser
				
			else
				puts line
				raise WTF
		end
	end
	
	def processIf(words)
	
		if expressionEvalsTrue(words) then
			@processed_a_block = true
			@processor.registerParser( @parserPrototype.dup )
			
		else
			@processor.registerParser( SkipParser.new )
			
		end
	end
	
	def expressionEvalsTrue(words)
	
		case words.size
			when 3
				return interpretDefined(words)
			
			when 4
				return interpretComparison(words)
				
			else
				raise WTF
		end
	
	
		
	end
	
	def interpretDefined(words)
		raise WTF unless words[1] == "defined?"
		
		evalResult = @processor.defined?(words[2])
	
		return !evalResult if words[0] == "unless"
		return evalResult
	end
	
	def interpretComparison(words)
		leftSide = words[1]
		operator = words[2]
		rightSide = words[3]
		
		evalResult = interpretExpression( 
			@processor.valueFor(leftSide).evaluate, 
			operator, 
			interpretValue(rightSide) )
		
		return !evalResult if words[0] == "unless"
		return evalResult
	end
	
	def interpretValue(expression)
		case expression
			when /"(.*)"/, /'(.*)'/
				return $1
				
			when /^(\d+\.\d+)$/
				return Float($1)
				
			when /^(\d+)$/
				return Integer($1)
				
			else
				@processor.valueFor(expression).evaluate
		end
	end
	
	def interpretExpression(leftValue, operator, rightValue)
	
		case operator
			when "="
				return leftValue == rightValue
				
			when "!=", "<>"
				return leftValue != rightValue
				
			when ">"
				return leftValue > rightValue
			
			when "<"
				return leftValue < rightValue
				
			when ">="
				return leftValue >= rightValue
				
			when "<="
				return leftValue <= rightValue
				
			else
				raise WTF
		end
	end

end


class LocalParser

	attr_accessor :processor

	def eofFound
		raise WTF
	end
	
	def parse(line, words)
		
		if line =~ /\-\sinjection\s\-/
			raise NotMyJobException
		end
		
		case words[0]
				
			when "if", "unless"
				processIfOrUnless(line, words)
				
			when "else", "end"
				raise NotMyJobException
				
			else
				parser = AssignmentParser.new
				
				parser.processor = @processor
				key, val = parser.parseSingleLine(line)
				
				@processor.define(key, val)
		end
	end

	def dup
		LocalParser.new
	end

	def processIfOrUnless(line, words)
		ifParser = IfParser.new(LocalParser.new )
		@processor.registerParser(ifParser)
		ifParser.parse(line, words)
		
	end
	
end


class InjectionParser
	
	attr_accessor :processor
	
	def initialize
		@multiplier = 1
	end
	
	def eofFound
		raise WTF
	end
	
	def subParserFinished
	
		@multiplier.times do
			@processor.addInjectionValues @cExp
		end

	end
	
	def parse(line, words)
		
		if line =~ /\-\stemplate\s\-/ then
			raise NotMyJobException
		end
		
		case words[0]
				
			when /(\d+)x/
				@multiplier = Integer($1)
				
				if words[1] == "{" then
					startAssignmentParsing
				else
					raise WTF
				end
				
			when "{"
				@multiplier = 1
				startAssignmentParsing

			else
				raise WTF
		
		end
		
	end
	
	def startAssignmentParsing
	   @cExp = CompoundExpression.new
	   @processor.registerParser( AssignmentParser.new(@cExp) )
	end
	
end


class TemplateProcessor

	attr_accessor :fileProcessor
	attr_accessor :injectionValues
	
	def process(line)
	
		if line =~ /^\*\> (.*)/
			import $1.strip
		
		else			
			@fileProcessor.write( expand(line) )
			
		end
		
	end
	
	def import(variable)
		expression = expandCompoundVarName(variable, injectionValues)
		return expression.evaluate
	end
	
	def expand(line)
		return line.gsub( /\*?\*\{\s*(\$?[\w\d\.]*\s*)\}/ ) do |varName|
				evaluate varName
			end
	end
		
	def evaluate(variable)
	
		if variable =~ /\*\{\s*(\$[\w\.]*)\s*\}/
			key = $1
			return injectionValues[key]
			
			
		elsif variable =~ /\*\*\{\s*([\w\.]*)\s*\}/
			expression = expandCompoundVarName($1, injectionValues)
			
			unless expression.is_a?(SimpleExpression)
				raise OnlySimpleExpressionsHere
			end
			
			return expand( expression.evaluate )
	
		elsif variable =~ /\*\{\s*([\w\.]*)\s*\}/
			expression = expandCompoundVarName($1, injectionValues)
			
			unless expression.is_a?(SimpleExpression)
				raise OnlySimpleExpressionsHere
			end
			
			return expression.evaluate
		else
			raise WTF
		end
		
	end
	
	
	def expandCompoundVarName(variable, varDeposit)
	
		if variable =~ /([\w]*)\.(.*)/
			key = $1
			rest = $2
			
			expression = varDeposit[key]
			
			if expression.is_a?(CompoundExpression)
				return expandCompoundVarName(rest, expression.evaluate)
			
			else
				raise WTF
			end
		
		else
			return varDeposit[variable]
			
		end
	
	end
	
end

class AllBodyTemplateParser
	attr_accessor :processor
	
	def initialize(lineBuffer)
		@lineBuffer = lineBuffer
	end
	
	def eofFound
	end
	
	def parse(line, words)
		@lineBuffer << line
	end
end

class HBFTemplateParser

	attr_accessor :processor
	
	def initialize(lineBuffer, markerExpansion = "")
		@markerExpansion = markerExpansion
		@lineBuffer = lineBuffer
	end
	
	def eofFound
		raise WTF
	end
	
	def parse(line, words)
		
		if line =~ /^<<(\w*)\s*$/
			gotExpansion = $1
			
			if @markerExpansion == gotExpansion
				@processor.quoteMode = false
				@processor.dropParser
				return
			
			end
		end
		
		
		@lineBuffer << line
	end
	
	
end


class TemplateParser

	attr_accessor :processor
	
	def initialize
		@header = []
		@body = []
		@footer = []
		@firstLine = true
	end

	def eofFound
		
		tProcessor = TemplateProcessor.new
		tProcessor.fileProcessor = @processor
		
		writeHeader(tProcessor)
		writeBody(tProcessor)
		writeFooter(tProcessor)
		
	end
	
	def parse(line, words)
	
		case words[0]
			
			when "header:"
				setupHBFParser(line, words, @header)

			when "body:"
				setupHBFParser(line, words, @body)
				
			when "footer:"
				
				if @firstLine
					raise WTF
					
				else
					setupHBFParser(line, words, @footer)
					
				end
			
			else
				if @firstLine 
					setupAllBodyParser(line, words)
					
				else
					raise WTF
				end
			
		end
		
		@firstLine = false
	end
	
	def setupAllBodyParser(line, words)
		newParser = AllBodyTemplateParser.new(@body)
		
		@processor.quoteMode = true
		@processor.registerParser newParser
		
		newParser.parse(line, words)
	end
	
	def setupHBFParser(line, words, lineBuffer)

		if words.length < 2 then
			raise WTF
		end

		if words[1] =~ /(\w*)>>/
			markerExpansion = $1
			
			newParser = HBFTemplateParser.new(
					lineBuffer,
					markerExpansion)

			@processor.quoteMode = true
			@processor.registerParser newParser

		else
			restOfLine = words.slice(1..-1).join(" ")
			if restOfLine.strip =~ /quote\("(.*)"\)/ then
				templateFile = $1

				@processor.quoteInput(templateFile, QuoteParser.new) {
					|line|
					lineBuffer << line
				}

			else
				raise WTF
			end

		end
	
	end
	
	def writeHeader(tProcessor)
		process(tProcessor, @processor.injectionValues[0], @header)
	end
	
	def writeBody(tProcessor)
		@processor.injectionValues.each do |valueSet|
			process(tProcessor, valueSet, @body)
		end
	end
	
	def writeFooter(tProcessor)
		process(tProcessor, @processor.injectionValues[0], @footer)
	end
	
	def process(tProcessor, valueSet, lines) 
		tProcessor.injectionValues = valueSet

		lines.each do |line|
			tProcessor.process line
		end
	end

end


class BasicStructureParser

	attr_accessor :processor
	
	def initialize(secondary = true)
		@secondary = secondary
		
		@step = 0
	end
	
	def eofFound
	end
	
	def parse(line, words)
		
		case line			
			when /\-\sglobal\s\-/
				if @step > 0 then
					raise "global may not come at this point"
				end
				
				@step = 1
				@processor.registerParser( GlobalParser.new( @secondary ) )	
				
				
			when /\-\slocal\s\-/
				if @step > 1 then
					raise "local may not come at this point"
				end
				
				@step = 2
				@processor.registerParser(LocalParser.new)	
				
			when /\-\sinjection\s\-/
				if @step > 2 then
					raise "injection may not come at this point"
				end
				
				@step = 3
				@processor.registerParser(InjectionParser.new)
			
			when /\-\stemplate\s\-/
				if @step > 3 then
					raise "template may not come at this point"
				end
				
				@step = 4
				@processor.registerParser(TemplateParser.new)
				
			else
				raise WTF
				
		end
		
	end

end


class FileProcessor

	include VarNameExpansion

	attr_accessor :glitter
	
	attr_reader :injectionValues
	
	attr_accessor :quoteMode

	def initialize( input, parser, parameters = {}, writeTarget = nil )
		@input = input
		@parserStack = [ ]
		@writeTarget = writeTarget
		
		@injectionValues = []
		@localValues = parameters
		@quoteMode = false
		
		registerParser( parser )
	end
	
	def run
		loop do
		
			if @input.eof? then
				
				broadcastEOF
				return
				
			end
			
			line = @input.gets
			
			if skip? line
				next
			end
			
			words = splitLine(line)
			
			wasHandled = false
			begin
				begin	
					currentParser.parse(line, words)
					wasHandled = true
					
				rescue NotMyJobException
					dropParser
					wasHandled = false
				
				end
				
			end until wasHandled
				
			
		end
	end
	
	def skip?(line)
		
		return false if @quoteMode
		
		return true if line.strip.empty?
		return true if line.strip.start_with? "//"
		
		return false
	end
	
	def broadcastEOF
	
		@parserStack.reverse.each do |parser|
			parser.eofFound
			dropParser
		end
		
	end
	
	def currentParser
		@parserStack[-1]
	end
	
	def registerParser(parser)
		@parserStack <<  parser
		parser.processor = self
	end
	
	def dropParser
		@parserStack.delete_at(-1)
		if currentParser.respond_to? :subParserFinished
			currentParser.subParserFinished
		end
	end
	
	def processInput(filename, processor, parameters = {})
		@glitter.startProcessing(filename, processor, parameters)
	end
	
	def quoteInput(filename, processor, &block)
		@glitter.startQuoting(filename, processor, block)
	end
	
	def splitLine(line)
		return line.split(' ')			
	end
	
	def write(line)
		if @writeTarget then
			@writeTarget.call line
		else 
			@glitter.write line
		end
		
	end
	
	def addInjectionValues(values)
		values["$iteration"] = @injectionValues.size + 1
		
		if @input.is_a?(File) then
			values["$file"] = @input.path
		else
			values["$file"] = "stdin"
		end
		
		@injectionValues << values
	end

	def defined?(varName)
		value = findValue(varName)
		return value != nil
	end
	
	def valueFor(varName)
	
		value = findValue(varName)
		
		return NullExpression.new unless value
		return value
	end
	
	def findValue(varName)
		if varName =~ varNameSplitter then
			baseVariable = $1
			
			return expandCompoundVarName(varName, depositContainingVar(baseVariable))
			
		else
			return depositContainingVar(varName)[varName]
		end
	end
	
	def depositContainingVar(varName)
	
		if @glitter.globals.include?(varName) then
			return @glitter.globals
			
		elsif @localValues.include?(varName)
			return @localValues
		end
		
		return {}
	end
	
	def define(varName, value)
		@localValues[varName] = value
	end
	
	def defineGlobals(valueStore)
		@glitter.globals = valueStore
	end
	
	def dumpVars
		p @glitter.globals
		p @localValues
	end

end


class Glitter

	def initialize
		@inputStack = []
		@wdStack = []
		@output = nil
		@globals = {}
		
	end
	
	def processInputFile(inputFile, output)
		@output = output
	
		run( 
			opening(inputFile) do |file| 
				fileProcessor( file, BasicStructureParser.new(false))
			end
		)
	end
	
	def processInputStream(inputStream, output)
		@output = output
	
		run fileProcessor( inputStream, BasicStructureParser.new(false))		
	end

	def startProcessing(filePath, startParser, parameters = {}, writeTarget = nil )
		run( opening(filePath) { |file| fileProcessor(file, startParser, parameters, writeTarget) } )
	end
	
	def startQuoting(filePath, startParser, writeTarget = nil)
		run( opening(filePath) { |file| fileQuoter( file, startParser, writeTarget ) } )
	end
	
	def opening(filePath)
		pn = cleanAbsolutePath(filePath)
		@wdStack << Pathname.pwd
		
		Dir.chdir(pn.dirname)		
		file = (File.open(pn.basename, 'r'))
		
		return yield(file)
	end

	def write(line)
		@output.puts line
	end
	
	def fileProcessor(forInput, startingWith, parameters = {}, writeTarget = nil)
		fProcessor = FileProcessor.new(forInput, startingWith, parameters, writeTarget )	
		fProcessor.glitter = self
		return fProcessor
	end
	
	def fileQuoter(forInput, startingWith, writeTarget = nil)
		fProcessor = FileProcessor.new(forInput, startingWith, {}, writeTarget )
		fProcessor.glitter = self
		fProcessor.quoteMode = true
		
		return fProcessor
	end
	
	def run(processor)
	
		@inputStack << processor
		processor.run
		@inputStack.delete_at(-1)

		if (@wdStack.size > 0) then
			Dir.chdir(@wdStack[-1])
			@wdStack.delete_at(-1)
		end
	end
		
	def cleanAbsolutePath(path)
		p = Pathname.new(path)
		p = Pathname.pwd + p unless p.absolute?
		return p.cleanpath
	end
	
	def globals
		@globals
	end

	def globals=(values)
		if @globals.empty?
			@globals = values
		else
			raise WTF
		end
	end
end

about = {'name'=>"glitter", 'desc'=>'Template Processing', 'author'=>":kelko:",'mail'=>"kelko@anakrino.de",'licence'=>KELKO::TOOLS::About::LICENSE_CC_BY_NC_SA,'version'=>"0.1"}
KELKO::TOOLS::About.getInstance << about

clp = KELKO::TOOLS::CommandLineParser.getInstance
clp.startMessage = 'Glitter, a template processor, see https://github.com/kelko/glitter'

clp.allowParam('INPUT' , 'The input file to process, - means STDIN', KELKO::TOOLS::CommandLineParser::PARAM_OPTIONAL)
clp.allowParam('OUTPUT' , 'The file the output shall be written into, - means STDOUT', KELKO::TOOLS::CommandLineParser::PARAM_OPTIONAL)


pa = clp.parseArguments(ARGV)

if pa then

	glitter = Glitter.new
	
	if pa.paramSet?("INPUT")
	
		if pa.paramSet?("OUTPUT")
			outFile = File.open(ARGV[1], 'w+')
			glitter.processInputFile( ARGV[0], outFile)
		
		else
			glitter.processInputFile( ARGV[0], $stdout)
			
		end
	
	else
		glitter.processInputStream( $stdin, $stdout )
	
	end
	
end
