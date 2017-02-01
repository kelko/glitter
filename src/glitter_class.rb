class Glitter

	def initialize
		@inputStack = []
		@wdStack = []
		@output = nil
		@globals = {}
		
	end
	
	def processInputStream(inputStream, output)
		@output = output
	
		run fileProcessor( inputStream, BasicStructureParser.new)		
	end
	
	def processInputFile(inputFile, output)
		@output = output

		loadGlobals()
		startProcessing(inputFile, BasicStructureParser.new)
	end

	def loadGlobals()
		opening("globals.gloss") do |file|
			run(fileProcessor(file, GlobalParser.new))
		end
	end

	def startProcessing(filePath, startParser, parameters = {}, writeTarget = nil )
		run( opening(filePath) { |file| fileProcessor(file, startParser, parameters, writeTarget) } )
	end
	
	def startQuoting(filePath, startParser, writeTarget = nil)
		run( opening(filePath) { |file| fileQuoter( file, startParser, writeTarget ) } )
	end
	
	def opening(filePath)
		pn = cleanAbsolutePath(filePath)
		return unless File.exist?(pn.to_s)

		@wdStack << Pathname.pwd
		
		Dir.chdir(pn.dirname)		
		file = (File.open(pn.basename, 'r'))
		
		return yield(file)
	end

	def write(line)
		@output.puts line
	end
	
	def fileProcessor(forInput, startingWith, parameters = {}, writeTarget = nil)
		fProcessor = FileProcessor.new(forInput, startingWith, parameters, writeTarget )	
		fProcessor.glitter = self
		return fProcessor
	end
	
	def fileQuoter(forInput, startingWith, writeTarget = nil)
		fProcessor = FileProcessor.new(forInput, startingWith, {}, writeTarget )
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
