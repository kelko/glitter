require 'exceptions.rb'
require 'globalParser.rb'
require 'localParser.rb'
require 'injectionParser.rb'
require 'templateParser.rb'

class BasicStructureParser

	attr_accessor :processor
	
	def initialize(secondary = true)
		@secondary = secondary
		
		@step = 0
	end
	
	def eofFound
	end
	
	def parse(line, words)
		
		case words[0]			
			when "global:"
				if @step > 0 then
					raise "global may not come at this point"
				end
				
				@step = 1
				@processor.registerParser( GlobalParser.new( @secondary ) )	
				
				
			when "local:"
				if @step > 1 then
					raise "local may not come at this point"
				end
				
				@step = 2
				@processor.registerParser(LocalParser.new)	
				
			when "injection:"
				if @step > 2 then
					raise "injection may not come at this point"
				end
				
				@step = 3
				@processor.registerParser(InjectionParser.new)
			
			when "template:"
				if @step > 3 then
					raise "template may not come at this point"
				end
				
				@step = 4
				@processor.quoteMode = true
				@processor.registerParser(TemplateParser.new)
				
			else
				raise WTF
				
		end
		
	end

end
