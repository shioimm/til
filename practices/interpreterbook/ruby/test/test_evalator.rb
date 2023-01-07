require "minitest"
require_relative "../lib/lexer"
require_relative "../lib/token"
require_relative "../lib/parser"
require_relative "../lib/evaluator"
require_relative "../lib/environment"

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

  def test_if_else_expression
    tests = [
      { input: "if (true) { 10 }",  output: 10 },
      { input: "if (false) { 10 }", output: nil },
      { input: "if (1) { 10 }",     output: 10 },
      { input: "if (1 < 2) { 10 }", output: 10 },
      { input: "if (1 > 2) { 10 }", output: nil },
      { input: "if (1 < 2) { 10 } else { 20 }", output: 10 },
      { input: "if (1 > 2) { 10 } else { 20 }", output: 20 },
    ]

    tests.each do |test|
      evaluated = test_eval(test[:input])
      if evaluated
        test_integer_object(evaluated, test[:output])
      else
        test_null_object(evaluated)
      end
    end
  end

  def test_return_statements
    tests = [
      { input: "return 10;",          output: 10 },
      { input: "return 10; 9",        output: 10 },
      { input: "return 2 * 5; 9;",    output: 10 },
      { input: "9; return 2 * 5; 9;", output: 10 },
      { input: "if (10 > 1) { if (10 > 1) { return 10; } return 1; }", output: 10 }
    ]

    tests.each do |test|
      evaluated = test_eval(test[:input])
      test_integer_object(evaluated, test[:output])
    end
  end

  def test_error_handling
    tests = [
      { input: "5 + true;",                     output: "type mismatch: INTEGER + BOOLEAN" },
      { input: "5 + true; 5;",                  output: "type mismatch: INTEGER + BOOLEAN" },
      { input: "-true;",                        output: "unknown operator: -BOOLEAN" },
      { input: "true + false;",                 output: "unknown operator: BOOLEAN + BOOLEAN" },
      { input: "5; true + false; 5;",           output: "unknown operator: BOOLEAN + BOOLEAN" },
      { input: "if (10 > 1) { true + false; }", output: "unknown operator: BOOLEAN + BOOLEAN" },
      { input: "if (10 > 1) { if (10 > 1) { true + false; } return 1; }", output: "unknown operator: BOOLEAN + BOOLEAN" },
      { input: "foobar", output: "identifier not found: foobar" }
    ]

    tests.each do |test|
      evaluated = test_eval(test[:input])
      assert_equal test[:output], evaluated.message
    end
  end

  def test_let_statements
    tests = [
      { input: "let a = 5; a",             output: 5 },
      { input: "let a = 5 * 5; a;",        output: 25 },
      { input: "let a = 5; let b = a; b;", output: 5 },
      { input: "let a = 5; let b = a; let c = a + b + 5; c;", output: 15 }
    ]

    tests.each do |test|
      evaluated = test_eval(test[:input])
      test_integer_object(evaluated, test[:output])
    end
  end

  def test_function_object
    input = "fn(x) { x + 2; };"

    evaluated = test_eval(input)

    assert_equal 1, evaluated.params.size
    assert_equal "x", evaluated.params.first.to_s
    assert_equal "(x + 2)", evaluated.body.to_s
  end

  def test_function_application
    tests = [
      { input: "let identity = fn(x) { x; }; identity(5);",          output: 5 },
      { input: "let identity = fn(x) { return x; }; identity(5)",    output: 5 },
      { input: "let double = fn(x) { x * 2; }; double(5);",          output: 10 },
      { input: "let add = fn(x, y) { x + y }; add(5, 5);",             output: 10 },
      { input: "let add = fn(x, y) { x + y }; add(5 + 5, add(5, 5));", output: 20 },
      { input: "fn(x) { x; }(5); ", output: 5 },
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
    env = ObjectSystem::Environment.new
    Eval.execute!(program, env)
  end

  def test_integer_object(actual, expected)
    assert_equal Integer, actual.value.class
    assert_equal expected, actual.value
  end

  def test_boolean_object(actual, expected)
    assert_equal [TrueClass, FalseClass].include?(actual.value.class), true
    assert_equal expected, actual.value
  end

  def test_null_object(actual)
    assert_nil actual
  end
end
