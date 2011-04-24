class HereDocumentParser

	attr_accessor :processor
	
	def initialize(expression, markerExpansion = "") 
		@expression = expression
		@markerExpansion = markerExpansion
		@stringBuffer = []
	end
	
	def eofFound
		raise WTF
	end
	
	def parse(line, words)
		
		if line =~ /^<<(\w*)\s*$/
			gotExpansion = $1
			if @markerExpansion == gotExpansion
				
				@expression.value = @stringBuffer.join("\n")
				@processor.dropParser
				return
			
			end
		end
		
		
		@stringBuffer << line
		
	end
	
	
end
