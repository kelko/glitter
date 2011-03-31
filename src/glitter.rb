require 'exceptions'
require 'basicStructureParser.rb'
require 'fileProcessor.rb'

class Glitter

	def initialize
		@inputStack = []
		@output = nil
		@globals = {}
		
	end
	
	def process(inputStream, output)
		@output = output
	
		run fileProcessor( inputStream, BasicStructureParser.new(false))		
	end

	def startProcessing(filePath, startParser, parameters = {} )
		file = (File.open(filePath, 'r'))		
		
		run fileProcessor(file, startParser, parameters)	
	end
	
	def startQuoting(filePath, startParser)
		file = (File.open(filePath, 'r'))		
		
		run fileQuoter( file, startParser )
	end

	def write(line)
		@output.puts line
	end
	
	def fileProcessor(forInput, startingWith, parameters = {})
		fProcessor = FileProcessor.new(forInput, startingWith, parameters )	
		fProcessor.glitter = self
		return fProcessor
	end
	
	def fileQuoter(forInput, startingWith)
		fProcessor = FileProcessor.new(forInput, startingWith )
		fProcessor.glitter = self
		fProcessor.quoteMode = true
		
		return fProcessor
	end
	
	def run(processor)
		@inputStack << processor
		processor.run
		@inputStack.delete_at(-1)
	end
	
	def globals
		@globals
	end

	def globals=(values)
		if @globals.empty?
			@globals = values
		else
			raise WTF
		end
	end
end
