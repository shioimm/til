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

  PRECEDENCES = {
    Token::EQ       => EQUALS,
    Token::NOT_EQ   => EQUALS,
    Token::LT       => LESSGREATER,
    Token::GT       => LESSGREATER,
    Token::PLUS     => SUM,
    Token::MINUS    => SUM,
    Token::SLASH    => PRODUCT,
    Token::ASTERISK => PRODUCT,
    Token::LPAREN   => CALL,
  }

  class ParseError < StandardError
  end

  def initialize(lexer)
    @lexer            = lexer
    @current_token    = nil
    @next_token       = nil
    @prefix_parse_fns = {}
    @infix_parse_fns  = {}

    @prefix_parse_fns[Token::IDENT] = self.method(:parse_indentifier!)
    @prefix_parse_fns[Token::INT]   = self.method(:parse_integer_literal!)
    @prefix_parse_fns[Token::BANG]  = self.method(:parse_prefix_expression!)
    @prefix_parse_fns[Token::MINUS] = self.method(:parse_prefix_expression!)

    @infix_parse_fns[Token::PLUS]     = self.method(:parse_infix_expression!)
    @infix_parse_fns[Token::MINUS]    = self.method(:parse_infix_expression!)
    @infix_parse_fns[Token::ASTERISK] = self.method(:parse_infix_expression!)
    @infix_parse_fns[Token::SLASH]    = self.method(:parse_infix_expression!)
    @infix_parse_fns[Token::EQ]       = self.method(:parse_infix_expression!)
    @infix_parse_fns[Token::NOT_EQ]   = self.method(:parse_infix_expression!)
    @infix_parse_fns[Token::LT]       = self.method(:parse_infix_expression!)
    @infix_parse_fns[Token::GT]       = self.method(:parse_infix_expression!)

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

    left_exp = prefix.call

    while !next_token?(Token::SEMICOLON) && precedence < peek_precedence
      infix = @infix_parse_fns[@next_token.type]
      return left_exp if infix.nil?

      next_token
      left_exp = infix.call(left_exp)
    end

    return left_exp
  end

  def parse_indentifier!
    ::AST::Identifier.new(token: @current_token, value: @current_token.literal)
  end

  def parse_integer_literal!
    lit = ::AST::IntegerLiteral.new(token: @current_token)
    raise ParseError unless @current_token.literal.respond_to? :to_i
    lit.value = @current_token.literal.to_i
    lit
  end

  def parse_prefix_expression!
    expression = ::AST::PrefixExpression.new(token: @current_token, operator: @current_token.literal)
    next_token
    expression.right = parse_expression!(PREFIX)
    expression
  end

  def parse_infix_expression!(left)
    expression = ::AST::InfixExpression.new(token: @current_token,
                                            operator: @current_token.literal,
                                            left: left)
    precedence = peek_precedence
    next_token
    expression.right = parse_expression!(precedence)
    expression
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

  def peek_precedence
    PRECEDENCES[@next_token.type]  || LOWEST
  end

  def current_precedence
    PRECEDENCES[@current_token.type] || LOWEST
  end

  def register_prefix(token_type, &fn)
    @prefix_parse_fns[token_type] = fn
  end

  def register_infix(token_type, &fn)
    @infix_parse_fns[token_type] = fn
  end
end
