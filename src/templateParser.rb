require 'exceptions.rb'
require 'expressions.rb'

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
		return line.gsub( /\*\{\s*([\w\d\.]*\s*)\}/ ) do |varName|
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

class TemplateParser

	attr_accessor :processor
	
	def initialize
		@stringBuffer = []
	end

	def eofFound
		
		tProcessor = TemplateProcessor.new
		tProcessor.fileProcessor = @processor
		iter = 1
		
		@processor.injectionValues.each do |valueSet|
			
			tProcessor.injectionValues = valueSet
			
			@stringBuffer.each do |line|
				tProcessor.process line
			end
			
			iter = iter.succ			
		end
		
	end
	
	def parse(line, words)
		@stringBuffer << line
	end
	
	
end
