#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'expressions.rb'
require 'glitter.rb'

glitter = Glitter.new

glitter.process( File.new(ARGV[0], 'r'), $stdout)
