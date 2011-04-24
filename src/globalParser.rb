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
