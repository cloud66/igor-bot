#!/usr/bin/env ruby

require 'trollop'

parser = Trollop::Parser.new {
	opt :stack, 'Stack', type: :string
	opt :environment, 'Environment', type: :string
}

parser.educate