require_relative "token"
require_relative "lexer"
require_relative "ast"

class Parser
  LOWEST      = 0
  EQUALS      = 1
  LESSGREATER = 2
  SUM         = 3
  PRODUCT     = 4
  PREFIX      = 5
  CALL        = 6

  def initialize(lexer)
    @lexer            = lexer
    @current_token    = nil
    @next_token       = nil
    @prefix_parse_fns = {}
    @infix_parse_fns  = {}

    @prefix_parse_fns[Token::IDENT] = self.method(:parse_indentifier)

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
    when Token::RETURN
      parse_return_statement!
    else
      parse_expression_statement!
    end
  end

  def parse_let_statement!
    stmt = ::AST::LetStatement.new(token: @current_token)

    return nil if !expect_peek(Token::IDENT)

    stmt.name = ::AST::Identifier.new(token: @current_token, value: @current_token.literal)

    return nil if !expect_peek(Token::ASSIGN)

    next_token while !current_token?(Token::SEMICOLON) # TODO
    stmt
  end

  def parse_return_statement!
    stmt = ::AST::ReturnStatement.new(token: @current_token)
    next_token
    next_token while !current_token?(Token::SEMICOLON) # TODO
    stmt
  end

  def parse_expression_statement!
    stmt = ::AST::ExpressionStatement.new(token: @current_token)
    stmt.expression = parse_expression!(LOWEST)
    next_token if next_token?(Token::SEMICOLON)
    stmt
  end

  def parse_expression!(precedence)
    prefix = @prefix_parse_fns[@current_token.type]

    return nil if prefix.nil?

    return prefix.call
  end

  def parse_indentifier
    ::AST::Identifier.new(token: @current_token, value: @current_token.literal)
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

  def register_prefix(token_type, &fn)
    @prefix_parse_fns[token_type] = fn
  end

  def register_infix(token_type, &fn)
    @infix_parse_fns[token_type] = fn
  end
end