class FileProcessor

	include VarNameExpansion

	attr_accessor :glitter
	
	attr_reader :injectionValues
	
	attr_accessor :quoteMode

	def initialize( input, parser, parameters = {} )
		@input = input
		@parserStack = [ ]
		
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
	
	def quoteInput(filename, processor)
		@glitter.startQuoting(filename, processor)
	end
	
	def splitLine(line)
		return line.split(' ')			
	end
	
	def write(line)
		@glitter.write line
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
