require "minitest"
require_relative "../lib/lexer"
require_relative "../lib/token"

MiniTest::Unit.autorun

class TestLexer < MiniTest::Unit::TestCase
  def test_next_token
    input = "let one = 1;
             let two = 2;
             let add = fn(x, y) {
               x + y;
             };
             let result = add(one, two);"

    tests = [
      { type: Token::LET,       literal: "let" },
      { type: Token::IDENT,     literal: "one" },
      { type: Token::ASSIGN,    literal: "=" },
      { type: Token::INT,       literal: "1" },
      { type: Token::SEMICOLON, literal: ";" },

      { type: Token::LET,       literal: "let" },
      { type: Token::IDENT,     literal: "two" },
      { type: Token::ASSIGN,    literal: "=" },
      { type: Token::INT,       literal: "2" },
      { type: Token::SEMICOLON, literal: ";" },

      { type: Token::LET,       literal: "let" },
      { type: Token::IDENT,     literal: "add" },
      { type: Token::ASSIGN,    literal: "=" },
      { type: Token::FUNCTION,  literal: "fn" },
      { type: Token::LPAREN,    literal: "(" },
      { type: Token::IDENT,     literal: "x" },
      { type: Token::COMMA,     literal: "," },
      { type: Token::IDENT,     literal: "y" },
      { type: Token::RPAREN,    literal: ")" },
      { type: Token::LBRACE,    literal: "{" },
      { type: Token::IDENT,     literal: "x" },
      { type: Token::PLUS,      literal: "+" },
      { type: Token::IDENT,     literal: "y" },
      { type: Token::SEMICOLON, literal: ";" },
      { type: Token::RBRACE,    literal: "}" },
      { type: Token::SEMICOLON, literal: ";" },

      { type: Token::LET,       literal: "let" },
      { type: Token::IDENT,     literal: "result" },
      { type: Token::ASSIGN,    literal: "=" },
      { type: Token::IDENT,     literal: "add" },
      { type: Token::LPAREN,    literal: "(" },
      { type: Token::IDENT,     literal: "one" },
      { type: Token::COMMA,     literal: "," },
      { type: Token::IDENT,     literal: "two" },
      { type: Token::RPAREN,    literal: ")" },
      { type: Token::SEMICOLON, literal: ";" },

      { type: Token::EOF,       literal: "" },
    ]

    l = Lexer.new(input)

    tests.each do |test|
      token = l.next_token
      assert_equal test[:type],    token.type
      assert_equal test[:literal], token.literal
    end
  end
end
