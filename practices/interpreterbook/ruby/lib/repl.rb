require_relative "lexer"
require_relative "token"
require_relative "parser"

PROMPT = ">> "

puts "Hello! This is the Ruby Monkey programming language!"
puts "Feel free to type in commands."

loop do
  begin
    print PROMPT
    scanned = $stdin.gets&.chomp

    next unless scanned

    lexer = Lexer.new(scanned)
    parser = Parser.new(lexer)
    program = parser.parse_program
    puts program.to_s
  rescue Interrupt
    puts "!! Ctrl+C is entered. Shutdown..."
    exit 1
  rescue Exception => e
    e.inspect.lines.each{ |s| puts "# #{s}" }
  end
end
