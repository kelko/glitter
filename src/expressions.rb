require 'quoteParser.rb'

class NullExpression

	def evaluate
		nil
	end

	def to_s
		"null"
	end
end

class SimpleExpression

	attr_accessor :value
	
	def evaluate
		return @value
	end
	
	def to_s
		@value.to_s
	end

end

class QuoteExpression

	attr_accessor :fileName
	attr_accessor :processor
	
	def evaluate
		# "lazy" evaluation
		@processor.quoteInput(@fileName, QuoteParser.new)
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
	
	def evaluate
		# "lazy evaluation"
		@processor.processInput(@fileName, BasicStructureParser.new, @parameters)
	end
	
	def to_s
		@fileName
	end
end

class CompoundExpression

	def initialize
		@values = {}
	end
	
	def [](key)
		return @values[key]
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

