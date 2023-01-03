require "minitest"
require_relative "../lib/lexer"
require_relative "../lib/token"
require_relative "../lib/parser"

MiniTest::Unit.autorun

class TestAst < MiniTest::Unit::TestCase
  def test_let_statement
    input = "let x = 1;
             let y = 2;
             let foobar = 838383;"

    l = Lexer.new(input)
    p = Parser.new(l)
    program = p.parse_program

    tests = [
      { name: "x",      value: "1" },
      { name: "y",      value: "2" },
      { name: "foobar", value: "838383"},
    ]

    tests.each_with_index do |test, i|
      stmt = program.statements[i]
      assert_equal "let", stmt.token_literal
      assert_equal test[:name], stmt.name.value
      assert_equal test[:name], stmt.name.token_literal
    end
  end
end
