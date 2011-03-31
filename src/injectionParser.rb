require 'exceptions.rb'
require 'expressions.rb'
require 'assignmentParser.rb'

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
		
		case words[0]
		
			when "template:", "template"
				raise NotMyJobException
				
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
