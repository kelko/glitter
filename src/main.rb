#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
require 'pathname'

require_relative 'exceptions.rb'
require_relative 'quoteParser.rb'
require_relative 'expressions.rb'
require_relative 'varNameExpansion.rb'
require_relative 'loadParser.rb'
require_relative 'hereDocumentParser.rb'
require_relative 'globalParser.rb'
require_relative 'assignmentParser.rb'
require_relative 'skipParser.rb'
require_relative 'ifParser.rb'
require_relative 'localParser.rb'
require_relative 'injectionParser.rb'
require_relative 'templateParser.rb'
require_relative 'basicStructureParser.rb'
require_relative 'fileProcessor.rb'
require_relative 'glitter_class.rb'

glitter = Glitter.new

case ARGV.count

	when 0
		glitter.processInputStream( $stdin, $stdout )
		
	when 1
		glitter.processInputFile( ARGV[0], $stdout)
		
	when 2
		outFile = File.open(ARGV[1], 'w+')
		glitter.processInputFile( ARGV[0], outFile)
	
	else
		raise WTF
end
