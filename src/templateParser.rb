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
