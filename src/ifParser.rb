require 'exceptions.rb'
require 'localParser.rb'
require 'skipParser.rb'

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
