require "minitest"
require_relative "../lib/token"
require_relative "../lib/ast"

MiniTest::Unit.autorun

class TestAst < MiniTest::Unit::TestCase
  def test_to_s
    let_token    = Token.new(type: Token::LET, literal: "let")
    ident_token1 = Token.new(type: Token::IDENT, literal: "var1")
    ident_token2 = Token.new(type: Token::IDENT, literal: "var2")

    program = ::AST::Program.new([
      ::AST::LetStatement.new(token: let_token,
                              name:  ::AST::Identifier.new(token: ident_token1, value: "var1"),
                              value: ::AST::Identifier.new(token: ident_token2, value: "var2"))
    ])

    assert_equal program.to_s, "let var1 = var2;"
  end
end
