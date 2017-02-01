class GlobalParser

	attr_accessor :processor
	
	def initialize()
		@valueStore = {}
	end

	def eofFound
		@processor.defineGlobals(@valueStore)
	end
	
	def parse(line, words)
		parser = BasicAssignmentParser.new

		parser.processor = @processor
		key, val = parser.parseSingleLine(line)
				
		@valueStore[key] = val
	end

end
