require 'pathname'

source = Pathname.new(ARGV[0]).file? ? File.read(ARGV[0]) : ARGV[0].to_s
_,
major_version,
minor_version,
_,
misc,
label,
path,
absolute_path,
first_lineno,
type,
locals,
args,
catch_table,
bytecode = RubyVM::InstructionSequence.compile(source).to_a

pp(major_version: major_version,
   minor_version: minor_version,
   misc: misc,
   label: label,
   path: path,
   absolute_path: absolute_path,
   first_lineno: first_lineno,
   type: type,
   locals: locals,
   args: args,
   catch_table: catch_table,
   bytecode: bytecode)
