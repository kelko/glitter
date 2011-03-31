require 'varNameExpansion.rb'

class LoadParser

	include VarNameExpansion

	attr_accessor :processor
	
	def initialize( valueStore )
		@valueStore = valueStore
	end

	def eofFound
	end
	
	def parse(line, words)
		
		case words[0]				
			when "if", "unless"
				processIfOrUnless(line, words)
				
			when "else", "end"
				raise NotMyJobException
				
			else
				parser = LoadAssignmentParser.new
				
				parser.processor = @processor
				key, val = parser.parseSingleLine(line)
				
				@valueStore[key] = val
				@processor.define(key, val)
		end
	end

	def dup
		LoadParser.new(@valueStore)
	end

	def processIfOrUnless(line, words)
		ifParser = IfParser.new( LoadParser.new(@valueStore) )
		@processor.registerParser(ifParser)
		ifParser.parse(line, words)
		
	end

end
