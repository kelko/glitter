class BasicAssignmentParser

	attr_accessor :processor
	
	def initialize(valueStore = CompoundExpression.new)
		@values = valueStore
	end

	def eofFound
	end	
	
	def whenFinished (&block)
		@whenFinished = block
	end
		
	def parseSingleLine(line)
		process partsOf(line)
		return assignedVariable
	end
	
	def parse(line, words)
		
		if words[0] == "}" or words[0] == "},"
		
			if @whenFinished
				@whenFinished.call
			end
			
			@processor.dropParser
			return		
		end
		
		process partsOf(line)
	end
	
	def process(parts)
		variable = parts[0]
		expression = parts[1]
		
		case expression.strip
			
			when "end", "else"
				raise NotMyJobException
			
			when "{"
				parseCompound(variable)
			
			when /(\w*)>>/
				expansion = $1
				parseHereDocument(variable, expansion)
		
			when /"(.*[^\\])"/, /'(.*[^\\])'/
				value = $1
				setVariable(variable, value)
				
			when /([A-Za-z][\w\.]*)/
				value = @processor.valueFor($1)
				@values[variable] = value
			
			when /(\d+\.\d+)/
				value = Float($1)
				setVariable(variable, value)
			
			when /(\d+)/
				value = Integer($1)
				setVariable(variable, value)
				
			else
				raise WTF

		end
	end
	
	
	def partsOf(line)
		unless line.strip =~ /^(\w[\w\d]*):\s+(.*)$/
			raise WTF
		end
		return $1, $2
	end
	
	def assignedVariable
		key = @values.evaluate.keys[0]
		value = @values[key]
		
		return key, value
	end	
	
	def setVariable(varName, value)
		
		sE = SimpleExpression.new
		sE.processor = @processor
		sE.value = value
		
		@values[varName] = sE
	end
	
	def parseHereDocument(varName, markerExpansion = "")
		sExp = SimpleExpression.new
		sExp.processor = @processor
		@values[varName] = sExp;
		
		@processor.registerParser HereDocumentParser.new(sExp, markerExpansion)
	end
	
	def parseCompound(varName)
		cExp = CompoundExpression.new
		@values[varName] = cExp
		
		@processor.registerParser self.class.new(cExp)
	end

end

class AssignmentParser < BasicAssignmentParser

	def initialize(valueStore = CompoundExpression.new)
		super(valueStore)
	end

	def process(parts)
		variable = parts[0]
		expression = parts[1]
		
		case expression.strip
				
			when /load\("(.*)"\)\s\{/
				fileName = $1
				loadFileWithParameters(variable, fileName)
				
			when /load\("(.*)"\)/
				fileName = $1
				loadFile(variable, fileName)
		
			when /quote\("(.*)"\)/
				fileName = $1
				quoteFile(variable, fileName)
				
			when /import\("(.*)"\)\s\{/
				fileName = $1
				importFileWithParameters(variable, fileName)
				
			when /import\("(.*)"\)/
				fileName = $1
				importFile(variable, fileName)
				
			else
				super(parts)

		end
	end
	
	def quoteFile(varName, fileName)
		qExp = QuoteExpression.new
		qExp.processor = @processor
		qExp.fileName = fileName
		
		@values[varName] = qExp
	end	
	
	def importFile(varName, fileName)
		iExp = ImportExpression.new
		iExp.processor = @processor
		iExp.fileName = fileName
		@values[varName] = iExp
		
		return iExp
	end
	
	def importFileWithParameters(varName, fileName)
		# the compound for parameters for import()
		cExp = CompoundExpression.new
		aParser = AssignmentParser.new(cExp)
		
		iExp = importFile(varName, fileName)
		
		aParser.whenFinished do
			iExp.parameters = cExp.evaluate
		end
		
		@processor.registerParser aParser
	end

	def loadFile(varName, fileName)
		cExp = CompoundExpression.new		
		@values[varName] = cExp
		
		@processor.processInput( fileName, LoadParser.new(cExp))
	end
	
	def loadFileWithParameters(varName, fileName)
		# the compound for parameters for load()
		cExp = CompoundExpression.new
		aParser = AssignmentParser.new(cExp)
		
		# the compound for results of load
		innerCExp = CompoundExpression.new	
		# assigned now, filled with content later
		@values[varName] = innerCExp
		
		aParser.whenFinished do
			# filled with content now
			@processor.processInput( fileName, LoadParser.new(innerCExp), cExp.evaluate)
		end
		
		@processor.registerParser aParser
	end
end
