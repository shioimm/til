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

  def test_parsing_prefix_expressions
    input = "!5;
             -15;
             !true;
             !false:"

    l = Lexer.new(input)
    p = Parser.new(l)
    program = p.parse_program

    assert_equal program.statements.size, 5

    tests = [
      { operator: "!", value: 5 },
      { operator: "-", value: 15 },
      { operator: "!", value: true },
      { operator: "!", value: false },
    ]

    tests.each_with_index do |test, i|
      stmt = program.statements[i]
      exp = stmt.expression
      assert_equal test[:operator], exp.operator
      assert_equal test[:value], exp.right.value
      assert_equal test[:value].to_s, exp.right.token_literal
    end
  end

  def test_parsing_infix_expressions
    input = "5 + 5;
             5 - 5;
             5 * 5;
             5 / 5;
             5 > 5;
             5 < 5;
             5 == 5;
             5 != 5;
             true == true;
             true != false;
             false == false;"

    l = Lexer.new(input)
    p = Parser.new(l)
    program = p.parse_program

    assert_equal program.statements.size, 11

    tests = [
      { left: 5,     operator: "+",  right: 5 },
      { left: 5,     operator: "-",  right: 5 },
      { left: 5,     operator: "*",  right: 5 },
      { left: 5,     operator: "/",  right: 5 },
      { left: 5,     operator: ">",  right: 5 },
      { left: 5,     operator: "<",  right: 5 },
      { left: 5,     operator: "==", right: 5 },
      { left: 5,     operator: "!=", right: 5 },
      { left: true,  operator: "==", right: true },
      { left: true,  operator: "!=", right: false },
      { left: false, operator: "==", right: false },
    ]

    tests.each_with_index do |test, i|
      stmt = program.statements[i]
      exp = stmt.expression
      assert_equal test[:left], exp.left.value
      assert_equal test[:left].to_s, exp.left.token_literal
      assert_equal test[:operator], exp.operator
      assert_equal test[:right], exp.right.value
      assert_equal test[:right].to_s, exp.right.token_literal
    end
  end

  def test_boolean
    input = "true;
             false;"

    l = Lexer.new(input)
    p = Parser.new(l)
    program = p.parse_program

    assert_equal program.statements.size, 2

    tests = [
      { value: true },
      { value: false }
    ]

    tests.each_with_index do |test, i|
      stmt = program.statements[i]
      ident = stmt.expression
      assert_equal test[:value], ident.value
      assert_equal test[:value].to_s, ident.token_literal
    end
  end

  def test_operator_precedence_parsing
    tests = [
      { input: "-a * b",                     expected: "((-a) * b)" },
      { input: "!-a",                        expected: "(!(-a))" },
      { input: "a + b + c",                  expected: "((a + b) + c)" },
      { input: "a + b - c",                  expected: "((a + b) - c)" },
      { input: "a * b * c",                  expected: "((a * b) * c)" },
      { input: "a * b / c",                  expected: "((a * b) / c)" },
      { input: "a + b / c",                  expected: "(a + (b / c))" },
      { input: "a + b * c + d / e - f",      expected: "(((a + (b * c)) + (d / e)) - f)" },
      { input: "3 + 4; -5 * 5",              expected: "(3 + 4)((-5) * 5)" },
      { input: "5 > 4 == 3 < 4",             expected: "((5 > 4) == (3 < 4))" },
      { input: "5 < 4 != 3 > 4",             expected: "((5 < 4) != (3 > 4))" },
      { input: "3 + 4 * 5 == 3 * 1 + 4 * 5", expected: "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))" },
      { input: "true",                       expected: "true" },
      { input: "false",                      expected: "false" },
      { input: "3 > 5 == false",             expected: "((3 > 5) == false)" },
      { input: "3 < 5 == true",              expected: "((3 < 5) == true)" },
      { input: "1 + (2 + 3) + 4",            expected: "((1 + (2 + 3)) + 4)" },
      { input: "(5 + 5) * 2",                expected: "((5 + 5) * 2)" },
      { input: "2 / (5 + 5)",                expected: "(2 / (5 + 5))" },
      { input: "-(5 + 5)",                   expected: "(-(5 + 5))" },
      { input: "!(true == true)",            expected: "(!(true == true))" },
    ]

    tests.each do |test|
      l = Lexer.new(test[:input])
      p = Parser.new(l)
      program = p.parse_program
      assert_equal test[:expected], program.to_s
    end
  end
end
