require 'pathname'

source = Pathname.new(ARGV[0]).file? ? File.read(ARGV[0]) : ARGV[0].to_s
puts RubyVM::InstructionSequence.compile(source).disasm
