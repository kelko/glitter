require 'exceptions.rb'
require 'assignmentParser.rb'
require 'ifParser.rb'

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
