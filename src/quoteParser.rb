class QuoteParser

	attr_accessor :processor

	def eofFound
	end
	
	def parse(line, words)
		@processor.write line
	end

end
