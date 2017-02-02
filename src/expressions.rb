class SimpleExpression

	attr_accessor :value
	attr_accessor :processor
	
	def evaluate
		return @value
	end

	def writeOutContent
		@processor.write(@value.to_s)
	end

	def 
	
	def to_s
		@value.to_s
	end

end

class CompoundExpression

	def initialize
		@values = {}
	end
	
	def [](key)
		result = @values[key]

		unless result
			result = @values["$_prior"][key] if @values["$_prior"] 
		end

		return result
	end
	
	def []=(key, value)
		@values[key] = value
	end
	
	def evaluate
		return @values
	end
	
	def to_s
		msg = "{\n"
		
		@values.each do |key, val| 
			msg << "#{key}: #{val}\n"
		end
		
		msg += "}\n"
		
		return msg
	end

end

class QuoteExpression

	attr_accessor :fileName
	attr_accessor :processor
	
	def writeOutContent
		# "lazy" evaluation
		@processor.quoteInput(@fileName, QuoteParser.new)
	end

	def evaluate
		result = []
		@processor.quoteInput(@fileName, QuoteParser.new) do |line|
			result << line
		end

		return result.join("")
	end
	
	def to_s
		@fileName
	end

end

class ImportExpression
	attr_accessor :fileName
	attr_accessor :parameters
	attr_accessor :processor
	
	def initialize
		@parameters = {}
	end
	
	def writeOutContent
		# "lazy evaluation"
		@processor.processInput(@fileName, BasicStructureParser.new, @parameters)
	end
	
	def to_s
		@fileName
	end
end



