require "minitest"
require_relative "../lib/lexer"
require_relative "../lib/token"
require_relative "../lib/parser"
require_relative "../lib/evaluator"

MiniTest::Unit.autorun

class TestEvaluator < MiniTest::Unit::TestCase
  def test_eval_integer_expression
    tests = [
      { input: "5",   output: 5 },
      { input: "10",  output: 10 },
      { input: "-5",  output: -5 },
      { input: "-10", output: -10 },
      { input: "5 + 5 + 5 + 5 - 10", output: 10 },
      { input: "2 * 2 * 2 * 2 * 2",  output: 32 },
      { input: "-50 + 100 + -50",    output: 0 },
      { input: "5 * 2 + 10",         output: 20 },
      { input: "5 + 2 * 10",         output: 25 },
      { input: "20 + 2 * -10",       output: 0 },
      { input: "50 / 2 * 2 + 10",    output: 60 },
      { input: "2 * (5 + 10)",       output: 30 },
      { input: "3 * 3 * 3 + 10",     output: 37 },
      { input: "3 * (3 * 3) + 10",   output: 37 },
      { input: "(5 + 10 * 2 + 15 / 3) * 2 + -10", output: 50 },
    ]

    tests.each do |test|
      evaluated = test_eval(test[:input])
      test_integer_object(evaluated, test[:output])
    end
  end

  def test_eval_boolean_expression
    tests = [
      { input: "true",   output: true },
      { input: "false",  output: false },
      { input: "1 < 2",  output: true },
      { input: "1 > 2",  output: false },
      { input: "1 < 1",  output: false },
      { input: "1 > 1",  output: false },
      { input: "1 == 1", output: true },
      { input: "1 != 1", output: false },
      { input: "1 == 2", output: false },
      { input: "1 != 2", output: true },
      { input: "true == true",     output: true },
      { input: "false == false",   output: true },
      { input: "true == false",    output: false },
      { input: "true != false",    output: true },
      { input: "(1 < 2) == true",  output: true },
      { input: "(1 < 2) == false", output: false },
      { input: "(1 > 2) == true",  output: false },
      { input: "(1 > 2) == false", output: true },
    ]

    tests.each do |test|
      evaluated = test_eval(test[:input])
      test_boolean_object(evaluated, test[:output])
    end
  end

  def test_bang_operator
    tests = [
      { input: "!true",   output: false },
      { input: "!false",  output: true },
      { input: "!5",      output: false },
      { input: "!!true",  output: true },
      { input: "!!false", output: false },
      { input: "!!5",     output: true },
    ]

    tests.each do |test|
      evaluated = test_eval(test[:input])
      test_boolean_object(evaluated, test[:output])
    end
  end

  private

  def test_eval(input)
    l = Lexer.new(input)
    p = Parser.new(l)
    program = p.parse_program
    Eval.execute!(program)
  end

  def test_integer_object(actual, expected)
    assert_equal Integer, actual.value.class
    assert_equal expected, actual.value
  end

  def test_boolean_object(actual, expected)
    assert_equal [TrueClass, FalseClass].include?(actual.value.class), true
    assert_equal expected, actual.value
  end
end
