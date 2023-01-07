require "minitest"
require_relative "../lib/lexer"
require_relative "../lib/token"
require_relative "../lib/parser"
require_relative "../lib/evaluator"

MiniTest::Unit.autorun

class TestEvaluator < MiniTest::Unit::TestCase
  def test_eval_integer_expression
    tests = [
      { input: "5",  output: 5 },
      { input: "10", output: 10 },
    ]

    tests.each do |test|
      evaluated = test_eval(test[:input])
      test_integer_object(evaluated, test[:output])
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
    assert_equal actual.value.class, Integer
    assert_equal actual.value, expected
  end
end
