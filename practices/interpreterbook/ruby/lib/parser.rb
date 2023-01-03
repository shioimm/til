require_relative "token"
require_relative "lexer"
require_relative "ast"

class Parser
  def initialize(lexer)
    @lexer = lexer
    @current_token = nil
    @next_token = nil

    next_token
    next_token
  end

  def parse_program
    program = ::AST::Program.new

    while @current_token.type != Token::EOF
      stmt = parse_statement!
      program.statements << stmt if !stmt.nil?
      next_token
    end

    program
  end

  private

  def parse_statement!
    case @current_token.type
    when Token::LET
      parse_let_statement!
    else
      nil
    end
  end

  def parse_let_statement!
    stmt = ::AST::LetStatement.new(token: @current_token)

    return nil if !expect_peek(Token::IDENT)

    stmt.name = ::AST::Identifier.new(token: @current_token, value: @current_token.literal)

    return nil if !expect_peek(Token::ASSIGN)

    next_token while current_token?(Token::SEMICOLON)
    stmt
  end

  def next_token
    @current_token = @next_token
    @next_token = @lexer.next_token
  end

  def current_token?(token_type)
    @current_token.type == token_type
  end

  def next_token?(token_type)
    @next_token.type == token_type
  end

  def expect_peek(token_type)
    if next_token? token_type
      next_token
      true
    else
      puts "Expected next token is #{token_type}, got #{@next_token.type} instead."
      false
    end
  end
end
