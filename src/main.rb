#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'expressions.rb'
require 'glitter.rb'

glitter = Glitter.new

if ARGV[0] == "-" then
	glitter.processInputStream( $stdin, $stdout )
else
	glitter.processInputFile( ARGV[0], $stdout)
end


