class BasicStructureParser

	attr_accessor :processor
	
	def initialize()		
		@step = 0
	end
	
	def eofFound
	end
	
	def parse(line, words)
		
		case line			
	
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
