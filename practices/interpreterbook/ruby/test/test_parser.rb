require "minitest"
require_relative "../lib/lexer"
require_relative "../lib/token"
require_relative "../lib/parser"

MiniTest::Unit.autorun

class TestParser < MiniTest::Unit::TestCase
  def test_let_statement
    input = "let x = 1;
             let y = 2;
             let foobar = 838383;"

    l = Lexer.new(input)
    p = Parser.new(l)
    program = p.parse_program

    assert_equal program.statements.size, 3

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

  def test_return_statement
    input = "return 1;
             return 2;
             return 838383;"

    l = Lexer.new(input)
    p = Parser.new(l)
    program = p.parse_program

    assert_equal program.statements.size, 3

    tests = [
      { return_value: "1" },
      { return_value: "2" },
      { return_value: "838383"},
    ]

    tests.each_with_index do |test, i|
      stmt = program.statements[i]
      assert_equal "return", stmt.token_literal
      # TODO
      # assert_equal test[:return_value], stmt.return_value
      # assert_equal test[:return_value], stmt.token_literal
    end
  end

  def test_indentifier_expression
    input = "foobar;"

    l = Lexer.new(input)
    p = Parser.new(l)
    program = p.parse_program

    assert_equal program.statements.size, 1

    tests = [
      { value: "foobar" }
    ]

    tests.each_with_index do |test, i|
      stmt = program.statements[i]
      ident = stmt.expression
      assert_equal test[:value], ident.value
      assert_equal test[:value], ident.token_literal
    end
  end

  def test_integer_literal_expression
    input = "5;"

    l = Lexer.new(input)
    p = Parser.new(l)
    program = p.parse_program

    assert_equal program.statements.size, 1

    tests = [
      { value: 5 }
    ]

    tests.each_with_index do |test, i|
      stmt = program.statements[i]
      literal = stmt.expression
      assert_equal test[:value].to_i, literal.value
      assert_equal test[:value].to_s, literal.token_literal
    end
  end
end
