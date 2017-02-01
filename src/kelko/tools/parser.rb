		#the 'result' of the CommandLineParser
		#holds all the things the CLP parsed from the arguments
		
		class ParsedArguments
		
			#constructor
			def initialize
				@flags = {}
				@params = {}
				@options = {}
			end

			#set the named flag to the value
			def newFlag(name,val)
				@flags[name] = val
				self
			end

			#set the named parameter to a value
			def newParam(name,val)
				@params[name] = val
				self
			end

			#set the named option to a value
			def newOption(name,val)
				@options[name] = val
				self
			end

			#checks whether the flag is set
			def flagSet?(flag)
				@flags[flag]
			end
			
			#checks whether the option is set
			def optionSet?(option)
				@options[option] != nil
			end

			#gets the value of the named parameter
			def getParam(name)
				@params[name]
			end
			
			#gets the value of the named parameter
			def paramSet?(name)
				@params[name] != nil
			end

			#gets the value of the named option
			def getOption(name)
				@options[name]
			end

		end

		
		#a parser for commandline arguments in a style inspired by the
		#gnu commandline options
		
		#three types of arguments can be defined:
		# flag 
		# option
		# parameter
	
		#a flag is a boolean value, the flag is set or it isn't
		
		#the option is quite a mix between boolean value an string-value
		#there can be the option set, but it must not
		#and the option has, if set, a value which can be get
		
		#a parameter is .. well ... an argument of the programm
		#the thinks you work with
		#there are required parameter which must not be missing
		#but there can be optional parameters as well which may
		#be missing

		#follows the singleton-pattern (->GoF, Design Patterns)
		class CommandLineParser
		private 

			@startMessage = nil
			@endMessage = nil

			@@instance = nil
			def initialize
				#the default-flags set by the CLP
				@flags = [
					{'name'=>"help",'option'=>"h",'longoption'=>"help",'desc'=>"Shows the help-message and quits", 'quit'=>false},
					{'name'=>"version",'option'=>nil,'longoption'=>"version",'desc'=>"Prints the version and quits", 'quit'=>false},
					{'name'=>"about",'option'=>nil,'longoption'=>"about",'desc'=>"Prints the About-data and quits", 'quit'=>false}
				]
				@options = []
				@params = []
			end

			#print the help (called  by --help)
			def print_help
				puts self
			end

			#print the version (called by --version)
			def print_version
				puts "#{About.getInstance.get('version')}\n"
			end

			#print the about-data (called by --about)
			def print_about
				puts About.getInstance
			end

		public 
			#prints an error that occured
			def print_error(errmsg)
				puts("\n\nError: #{errmsg}\n\n")
				puts self
			end

			attr_reader :flags, :options, :params
			attr_writer :flags, :options, :params, :startMessage, :endMessage

			#the possible types of the parameters
			PARAM_REQUIRED = 1
			PARAM_OPTIONAL = 0
			PARAM_MULTI = 2 
			#may be only 1 multi-param
			
			# -> singleton-pattern
			def CommandLineParser.getInstance
				@@instance = CommandLineParser.new unless @@instance
				return @@instance
			end

			#allow the named flag, save the description (for --help)
			#autoQuit means: if this flag is parsed do not parse any
			#further but go back to the caller of "parseArguments"
			
			# -flag --longflag
			# flag shall be just one char
			def allowFlag(name,flag, longflag, desc, autoQuit = false)
				@flags << {'name'=>name,'option'=>flag,'longoption'=>longflag,'desc'=>desc, 'quit'=>autoQuit}
				return self
			end

			#disallow the named flag
			def disallowFlag(name)
				@flags.delete_if do |flag|
					flag['name'] == name
				end
			end

			#allow the named option, save the description for --help
			
			# -option=val --longopt=val
			# option shall be just one char
			def allowOption(name, option, longopt, desc)
				@options << {'name'=>name,'option'=>option,'longoption'=>longopt,'desc'=>desc}
				return self
			end

			#disallow the named option
			def disallowOption(name)
				 @options.delete_if do |option|
					option['name'] == name
				end
			end

			#allow a parameter, save the description for --help and
			#the type of the parameter
			def allowParam(name, desc, type = CommandLineParser::PARAM_OPTIONAL)
				@params << {'name'=>name,'desc'=>desc,'type'=>type}
				return self
			end

			#disallow the named parameter
			def disallowParam(name)
				@params.delete_if do |param|
					param['name'] == name
				end
			end


			#the --help output, simply prompts the well-known
			#--help informations, consisting of:
			def to_s
				msg = ""
				#a start message from the author of the prog
				msg += "#{@startMessage}\n" if @startMessage
				#how to use
				msg += "USAGE: #{$0.split(/\//).reverse[0]} [Flags] [Options] PARAMS\n"

				#the allowed flags
				msg += "\nWith Flags:\n"
				@flags.each do |flag|
					msg += "-#{flag['option']}" if flag['option']
					msg += "\t"
					msg += "--#{flag['longoption']}" if flag['longoption']
					msg += "\t\t"
					msg += flag['desc']
					msg += "\n"
				end

				#the allowed options
				msg += "\nWith Options:\n"
				@options.each do |option|
					msg += "-#{option['option']}" if option['option']
					msg += "\t"
					msg += "--#{option['longoption']}" if option['longoption']
					msg += "\t\t"
					msg += option['desc']
					msg += "\n"
				end

				#the allowed parameter
				msg += "\nWith PARAMS: (in this order)\n"
				@params.each do |param|
					msg += "#{param['name']}\t#{param['desc']}"
					msg += " (Required) " if param['type'] == CommandLineParser::PARAM_REQUIRED
					msg += " (Multi-param) " if param['type'] == CommandLineParser::PARAM_MULTI
					msg += "\n"
				end
				
				msg += "\n"
				#an end message from the author of the prog
				msg += "#{@endMessage}\n" if @endMessage
				

				return msg
			end

			#do the work
			#parse the argument-array and create the 
			#ParsedArguments-object
			def parseArguments(argv)
				#but don't do that if called by the irb
				if $0 == 'irb' then return nil end
				
				
				begin
					#the result
					pa = ParsedArguments.new
					
					#if already parsing parameter no
					#option or flag may occure
					atParams = false
					#at which parameter are you?
					paramNr = 0
					multi = []
			
					
					argv.each do |arg|
						
						if !atParams then #flags and options
							case arg
								when /^-{1,1}(\w)=(.+)$/ then
								#a seems-option occured (with 1 dash -> option)
									found = false
									@options.each do |option|
										#is there a option with this char
										found = option['name'] if option['option'] == $1
									end
									
									pa.newOption(found, $2) if found
									raise "#{$1} is no valid option" unless found
								
								when /^-{2,2}(\w[\w\-]+)=(.+)$/ then
								#a seems-option occured (with 2 dashes -> longopt)
									found = false
									@options.each do |option|
										#is there a option with this longopt
										found = option['name'] if option['longoption'] == $1
									end
									
									pa.newOption(found, $2) if found
									raise "#{$1} is no valid option" unless found
								
								when /^-{1,1}(\w+)$/ then
								#a seems-flag (with one dash)
									$1.scan(/(.)/) do |char| 
										found = false
										@flags.each do |flag|
											found = flag if flag['option'] == char[0]
											break if found
										end
										
										if found then
											pa.newFlag(found['name'], true)
											#quit parsing if set "autoQuit"
											raise ArgumentError, 'quit' if found['quit']
										else
											raise "#{char[0]} is no valid flag"
										end
										
									end
								
								when /^-{2,2}(\w[\w\-]+)$/ then
								#a seems-flag (with two dashes)
									found = false
									@flags.each do |flag|
										found = flag if flag['longoption'] == $1
										break if found
									end
									
									if found then
										pa.newFlag(found['name'], true)
										#quit parsing if set "autoQuit"
										raise ArgumentError, 'quit' if found['quit']
									else
										raise "#{$1} is no valid flag"
									end
									 
								
								else
									atParams = true
									redo
							end
							
						else #parameter
							if paramNr >= @params.length  then 
								#wow, so many arguments are not allowed
								raise "Too much arguments passed"
								
							elsif @params[paramNr]['type'] == CommandLineParser::PARAM_MULTI then
								#all parameter coming now are put together into the array
								multi << arg
							else 
								#new parameter found
								pa.newParam(@params[paramNr]['name'], arg)
								paramNr = paramNr.next
								
							end
							
							
						end
						
						#the three shortcircut-validation
						#print the message for that flag
						#and quit
						if pa.flagSet?('help') then 
							print_help
							raise ArgumentError
						elsif pa.flagSet?('about') 
							then print_about
							raise ArgumentError
						elsif pa.flagSet?('version') 
							then print_version
							raise ArgumentError
						end
					end
					
					#save the multi-parameter
					pa.newParam(@params[paramNr]['name'],multi) if multi.length > 0
					
					#haven't parsed enough arguments!
					#some required-arguments are not set
					raise 'Not enough arguments passed' if @params.length > paramNr and @params[paramNr]['type'] == CommandLineParser::PARAM_REQUIRED
					
					
					return pa
					
				rescue RuntimeError => error
					#some error occured
					print_error(error)
					return nil
					
				rescue ArgumentError => arg
					#autoQuit
					return pa if arg.message == 'quit'
					#shortcircut-validation
					return nil 
				end
			end
		end