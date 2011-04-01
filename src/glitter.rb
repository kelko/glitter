require 'exceptions'
require 'basicStructureParser.rb'
require 'fileProcessor.rb'
require 'pathname'

class Glitter

	def initialize
		@inputStack = []
		@wdStack = []
		@output = nil
		@globals = {}
		
	end
	
	def processInputFile(inputFile, output)
		@output = output
	
		run( 
			opening(inputFile) do |file| 
				fileProcessor( file, BasicStructureParser.new(false))
			end
		)
	end
	
	def processInputStream(inputStream, output)
		@output = output
	
		run fileProcessor( inputStream, BasicStructureParser.new(false))		
	end

	def startProcessing(filePath, startParser, parameters = {} )
		run( opening(filePath) { |file| fileProcessor(file, startParser, parameters) } )
	end
	
	def startQuoting(filePath, startParser)
		run( opening(filePath) { |file| fileQuoter( file, startParser ) } )
	end
	
	def opening(filePath)
		pn = cleanAbsolutePath(filePath)
		@wdStack << Pathname.pwd
		
		Dir.chdir(pn.dirname)		
		file = (File.open(pn.basename, 'r'))
		
		return yield(file)
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

		if (@wdStack.size > 0) then
			Dir.chdir(@wdStack[-1])
			@wdStack.delete_at(-1)
		end
	end
		
	def cleanAbsolutePath(path)
		p = Pathname.new(path)
		p = Pathname.pwd + p unless p.absolute?
		return p.cleanpath
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
