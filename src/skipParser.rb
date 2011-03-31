class SkipParser

	attr_accessor :processor
	
	def initialize()
		@counter = 0
	end
	
	def eofFound
		raise WTF
	end
	
	def parse(line, words)
		
		if words[0] == "if" or	words[0] == "unless" then
			increment
			
		elsif nested? 
			# else in a nested does not do anything
			# so check only for end
			if words[0] == "end"
				decrement
			end

		else
			if words[0] == "else" or  words[0] == "end"
				drop
			end
			
		end
	end
	
	def increment
		@counter += 1
	end

	def decrement
		@counter -= 1
	end
	
	def nested?
		@counter > 0
	end
	
	def drop
		raise NotMyJobException
	end

end
