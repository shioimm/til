require_relative "lexer"
require_relative "token"
require_relative "parser"
require_relative "evaluator"
require_relative "environment"

PROMPT = ">> "

puts "Hello! This is the Ruby Monkey programming language!"
puts "Feel free to type in commands."

loop do
  begin
    print PROMPT
    scanned = $stdin.gets&.chomp
    env = ObjectSystem::Environment.new

    next unless scanned

    lexer = Lexer.new(scanned)
    parser = Parser.new(lexer)
    program = parser.parse_program
    evaluated = Eval.execute!(program, env)

    if evaluated.nil?
      print program.to_s
      puts "\n"
    else
      puts evaluated.inspect
    end
  rescue Interrupt
    puts "!! Ctrl+C is entered. Shutdown..."
    exit 1
  rescue Exception => e
    e.inspect.lines.each{ |s| puts "# #{s}" }
  end
end
