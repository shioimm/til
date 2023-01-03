class Lexer
  def initialize(input)
    @input = input
    @current_pos = 0
    @next_pos = 0
    @char = nil
  end

  def next_token
    read_char if @current_pos.zero?

    skip_whitespace
    token = Token.new

    case @char
    when "="
      if peek_char == "="
        read_char
        token.type = Token::EQ
        token.literal = "=="
      else
        token.type = Token::ASSIGN
        token.literal = @char
      end
    when "!"
      if peek_char == "="
        read_char
        token.type = Token::NOT_EQ
        token.literal = "!="
      else
        token.type = Token::BANG
        token.literal = @char
      end
    when "+"
      token.type = Token::PLUS
      token.literal = @char
    when "-"
      token.type = Token::MINUS
      token.literal = @char
    when "*"
      token.type = Token::ASTERISK
      token.literal = @char
    when "/"
      token.type = Token::SLASH
      token.literal = @char
    when "<"
      token.type = Token::LT
      token.literal = @char
    when ">"
      token.type = Token::GT
      token.literal = @char
    when "("
      token.type = Token::LPAREN
      token.literal = @char
    when ")"
      token.type = Token::RPAREN
      token.literal = @char
    when "{"
      token.type = Token::LBRACE
      token.literal = @char
    when "}"
      token.type = Token::RBRACE
      token.literal = @char
    when ","
      token.type = Token::COMMA
      token.literal = @char
    when ";"
      token.type = Token::SEMICOLON
      token.literal = @char
    when ""
      token.type = Token::EOF
      token.literal = @char
    else
      if letter?(@char)
        token.literal = read_indentifier
        token.type = Token.lookup_identifier(token.literal)
        return token
      elsif digit?(@char)
        token.literal = read_number
        token.type = Token::INT
        return token
      else
        token.literal = @char
        token.type = Token::ILLEGAL
      end
    end

    read_char && token
  end

  private

  def read_char
    if @next_pos >= @input.size
      @char = ""
    else
      @char = @input[@next_pos]
    end

    @current_pos = @next_pos
    @next_pos += 1
  end

  def peek_char
    if @next_pos >= @input.size
      ""
    else
      @input[@next_pos]
    end
  end

  def read_indentifier
    pos = @current_pos
    read_char while letter?(@char)
    @input[pos..@current_pos - 1]
  end

  def read_number
    pos = @current_pos
    read_char while digit?(@char)
    @input[pos..@current_pos - 1]
  end

  def skip_whitespace
    read_char while [" ", "\t", "\n", "\r"].include? @char
  end

  def letter?(char)
    ("A".."z").include? char || char == "_"
  end

  def digit?(char)
    ("0".."9").include? char
  end
end
