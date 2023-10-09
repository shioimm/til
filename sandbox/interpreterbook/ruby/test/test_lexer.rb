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
             let result = add(one, two);

             !-/*1;
             1 < 2 > 1;

             if (1 < 2) {
               return true;
             } else {
               return false;
             }

             1 == 1;
             1 != 2;"

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

      { type: Token::BANG,      literal: "!" },
      { type: Token::MINUS,     literal: "-" },
      { type: Token::SLASH,     literal: "/" },
      { type: Token::ASTERISK,  literal: "*" },
      { type: Token::INT,       literal: "1" },
      { type: Token::SEMICOLON, literal: ";" },

      { type: Token::INT,       literal: "1" },
      { type: Token::LT,        literal: "<" },
      { type: Token::INT,       literal: "2" },
      { type: Token::GT,        literal: ">" },
      { type: Token::INT,       literal: "1" },
      { type: Token::SEMICOLON, literal: ";" },

      { type: Token::IF,        literal: "if" },
      { type: Token::LPAREN,    literal: "(" },
      { type: Token::INT,       literal: "1" },
      { type: Token::LT,        literal: "<" },
      { type: Token::INT,       literal: "2" },
      { type: Token::RPAREN,    literal: ")" },
      { type: Token::LBRACE,    literal: "{" },
      { type: Token::RETURN,    literal: "return" },
      { type: Token::TRUE,      literal: "true" },
      { type: Token::SEMICOLON, literal: ";" },
      { type: Token::RBRACE,    literal: "}" },
      { type: Token::ELSE,      literal: "else" },
      { type: Token::LBRACE,    literal: "{" },
      { type: Token::RETURN,    literal: "return" },
      { type: Token::FALSE,     literal: "false" },
      { type: Token::SEMICOLON, literal: ";" },
      { type: Token::RBRACE,    literal: "}" },

      { type: Token::INT,       literal: "1" },
      { type: Token::EQ,        literal: "==" },
      { type: Token::INT,       literal: "1" },
      { type: Token::SEMICOLON, literal: ";" },

      { type: Token::INT,       literal: "1" },
      { type: Token::NOT_EQ,    literal: "!=" },
      { type: Token::INT,       literal: "2" },
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
