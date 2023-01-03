require_relative "lexer"
require_relative "token"

PROMPT = ">> "

puts "Hello! This is the Ruby Monkey programming language!"
puts "Feel free to type in commands."

loop do
  begin
    print PROMPT
    scanned = $stdin.gets&.chomp

    next unless scanned

    lexer = Lexer.new(scanned)

    while (token = lexer.next_token).type != Token::EOF
      puts "<Token: type=\"#{token.type}\" literal=\"#{token.literal}\">"
    end
  rescue Interrupt
    puts "!! Ctrl+C is entered. Shutdown..."
    exit 1
  rescue Exception => e
    e.inspect.lines.each{ |s| puts "# #{s}" }
  end
end
