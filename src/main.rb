#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
require 'pathname'

require 'exceptions.rb'
require 'quoteParser.rb'
require 'expressions.rb'
require 'varNameExpansion.rb'
require 'loadParser.rb'
require 'hereDocumentParser.rb'
require 'globalParser.rb'
require 'assignmentParser.rb'
require 'skipParser.rb'
require 'ifParser.rb'
require 'localParser.rb'
require 'injectionParser.rb'
require 'templateParser.rb'
require 'basicStructureParser.rb'
require 'fileProcessor.rb'
require 'glitter_class.rb'

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
