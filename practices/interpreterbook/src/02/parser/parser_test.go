// Go言語で作るインタプリタ 2
package parser

import (
  "fmt"
  "monkey/ast"
  "monkey/lexer"
  "testing"
)

func TestLetStatements(t *testing.T) {
  input := `
    let x = 5;
    let y = 10;
    let foobar = 838383;
  `

  l := lexer.New(input)
  p := New(l)

  program := p.ParseProgram()
  checkParserErrors(t, p)

  if program == nil {
    t.Fatalf("ParseProgram() returned nil")
  }
  if len(program.Statements) != 3 {
    t.Fatalf("program.Statements does not contain 3 statements. got %d", len(program.Statements))
  }

  test := []struct {
    expectedIdentifier string
  }{
    {"x"}
    {"y"}
    {"foobar"}
  }

  for i, tt:= range tests {
    stmt := program.Statements[i]

    if !testLetStatement(t, stmt, tt.expectedIdentifier) {
      return
    }
  }
}

func TestLetStatement(t *testing.T, s ast.Statement, name string) bool {
  if s.TokenLiteral() != "let" {
    t.Errorf("s.TokenLiteral not 'let'. got %q", s.TokenLiteral)
    return false
  }

  letStmt, ok := s.(*ast.LetStatement)

  if !ok {
    t.errorf("s not *ast.letstatement. got %t", s)
      return false
  }

  if letStmt.Name.Value != name {
    t.errorf("letStmt.Name not %s. got %s", letStmt.Name.Value)
    return false
  }

  if letStmt.Name.TokenLiteral() != name {
    t.errorf("letStmt.Name.TokenLiteral() not %s. got %s", letStmt.Name.TokenLiteral())
    return false
  }

  return true
}

func TestReturnStatements(t *testing.T) {
  tests := []struct {
    input         string
    expectedValue interface{}
  }{
    {"return 5;", 5},
    {"return true;", true},
    {"return foobar;", "foobar"},
  }

  for _, tt := range tests {
    l := lexer.New(tt.input)
    p := New(l)
    program := p.ParseProgram()
    checkParserErrors(t, p)

    if len(program.Statements) != 1 {
      t.Fatalf("program.Statements does not contain 1 statements. got=%d",
        len(program.Statements))
    }

    stmt := program.Statements[0]
    returnStmt, ok := stmt.(*ast.ReturnStatement)
    if !ok {
      t.Fatalf("stmt not *ast.returnStatement. got=%T", stmt)
    }
    if returnStmt.TokenLiteral() != "return" {
      t.Fatalf("returnStmt.TokenLiteral not 'return', got %q",
        returnStmt.TokenLiteral())
    }
    if testLiteralExpression(t, returnStmt.ReturnValue, tt.expectedValue) {
      return
    }
  }
}

func TestIdentifierExpression(t *testing.T) {
  input := "foobar;"

  l := lexer.New(input)
  p := New(l)
  program := p.ParseProgram()
  checkParserErrors(t, p)

  if len(program.Statements) != 1 {
    t.Fatalf("program has not enough statements. got=%d",
      len(program.Statements))
  }
  stmt, ok := program.Statements[0].(*ast.ExpressionStatement)
  if !ok {
    t.Fatalf("program.Statements[0] is not ast.ExpressionStatement. got=%T",
      program.Statements[0])
  }

  ident, ok := stmt.Expression.(*ast.Identifier)
  if !ok {
    t.Fatalf("exp not *ast.Identifier. got=%T", stmt.Expression)
  }
  if ident.Value != "foobar" {
    t.Errorf("ident.Value not %s. got=%s", "foobar", ident.Value)
  }
  if ident.TokenLiteral() != "foobar" {
    t.Errorf("ident.TokenLiteral not %s. got=%s", "foobar",
      ident.TokenLiteral())
  }
}

func TestIntegerLiteralExpression(t *testing.T) {
  input := "5;"

  l := lexer.New(input)
  p := New(l)
  program := p.ParseProgram()
  checkParserErrors(t, p)

  if len(program.Statements) != 1 {
    t.Fatalf("program has not enough statements. got=%d",
      len(program.Statements))
  }
  stmt, ok := program.Statements[0].(*ast.ExpressionStatement)
  if !ok {
    t.Fatalf("program.Statements[0] is not ast.ExpressionStatement. got=%T",
      program.Statements[0])
  }

  literal, ok := stmt.Expression.(*ast.IntegerLiteral)
  if !ok {
    t.Fatalf("exp not *ast.IntegerLiteral. got=%T", stmt.Expression)
  }
  if literal.Value != 5 {
    t.Errorf("literal.Value not %d. got=%d", 5, literal.Value)
  }
  if literal.TokenLiteral() != "5" {
    t.Errorf("literal.TokenLiteral not %s. got=%s", "5",
      literal.TokenLiteral())
  }
}

func TestParsingPrefixExpressions(t *testing.T) {
  prefixTests := []struct {
    input    string
    operator string
    value    interface{}
  }{
    {"!5;", "!", 5},
    {"-15;", "-", 15},
    {"!foobar;", "!", "foobar"},
    {"-foobar;", "-", "foobar"},
    {"!true;", "!", true},
    {"!false;", "!", false},
  }

  for _, tt := range prefixTests {
    l := lexer.New(tt.input)
    p := New(l)
    program := p.ParseProgram()
    checkParserErrors(t, p)

    if len(program.Statements) != 1 {
      t.Fatalf("program.Statements does not contain %d statements. got=%d\n",
        1, len(program.Statements))
    }

    stmt, ok := program.Statements[0].(*ast.ExpressionStatement)
    if !ok {
      t.Fatalf("program.Statements[0] is not ast.ExpressionStatement. got=%T",
        program.Statements[0])
    }

    exp, ok := stmt.Expression.(*ast.PrefixExpression)
    if !ok {
      t.Fatalf("stmt is not ast.PrefixExpression. got=%T", stmt.Expression)
    }
    if exp.Operator != tt.operator {
      t.Fatalf("exp.Operator is not '%s'. got=%s",
        tt.operator, exp.Operator)
    }
    if !testLiteralExpression(t, exp.Right, tt.value) {
      return
    }
  }
}

func TestParsingInfixExpressions(t *testing.T) {
  infixTests := []struct {
    input      string
    leftValue  interface{}
    operator   string
    rightValue interface{}
  }{
    {"5 + 5;", 5, "+", 5},
    {"5 - 5;", 5, "-", 5},
    {"5 * 5;", 5, "*", 5},
    {"5 / 5;", 5, "/", 5},
    {"5 > 5;", 5, ">", 5},
    {"5 < 5;", 5, "<", 5},
    {"5 == 5;", 5, "==", 5},
    {"5 != 5;", 5, "!=", 5},
    {"foobar + barfoo;", "foobar", "+", "barfoo"},
    {"foobar - barfoo;", "foobar", "-", "barfoo"},
    {"foobar * barfoo;", "foobar", "*", "barfoo"},
    {"foobar / barfoo;", "foobar", "/", "barfoo"},
    {"foobar > barfoo;", "foobar", ">", "barfoo"},
    {"foobar < barfoo;", "foobar", "<", "barfoo"},
    {"foobar == barfoo;", "foobar", "==", "barfoo"},
    {"foobar != barfoo;", "foobar", "!=", "barfoo"},
    {"true == true", true, "==", true},
    {"true != false", true, "!=", false},
    {"false == false", false, "==", false},
  }

  for _, tt := range infixTests {
    l := lexer.New(tt.input)
    p := New(l)
    program := p.ParseProgram()
    checkParserErrors(t, p)

    if len(program.Statements) != 1 {
      t.Fatalf("program.Statements does not contain %d statements. got=%d\n",
        1, len(program.Statements))
    }

    stmt, ok := program.Statements[0].(*ast.ExpressionStatement)
    if !ok {
      t.Fatalf("program.Statements[0] is not ast.ExpressionStatement. got=%T",
        program.Statements[0])
    }

    if !testInfixExpression(t, stmt.Expression, tt.leftValue,
      tt.operator, tt.rightValue) {
      return
    }
  }
}

// ヘルパー関数
func checkParserErrors(t *testing.T, p *Parser) {
  errors := p.Errors()
  if len(errors) == 0 {
    return
  }

  t.Errorf("parser has %d errors", len(errors))
  for _, msg := range errors {
    t.Errorf("parser error: %q", msg)
  }
  t.FailNow()
}

func testIntegerLiteral(t *testing.T, il ast.Expression, value int64) bool {
  integ, ok := il.(*ast.IntegerLiteral)
  if !ok {
    t.Errorf("il not *ast.IntegerLiteral. got=%T", il)
    return false
  }

  if integ.Value != value {
    t.Errorf("integ.Value not %d. got=%d", value, integ.Value)
    return false
  }

  if integ.TokenLiteral() != fmt.Sprintf("%d", value) {
    t.Errorf("integ.TokenLiteral not %d. got=%s", value,
      integ.TokenLiteral())
    return false
  }

  return true
}

func TestOperatorPrecedenceParsing(t *testing.T) {
  tests := []struct {
    input    string
    expected string
  }{
    {
      "-a * b",
      "((-a) * b)",
    },
    {
      "!-a",
      "(!(-a))",
    },
    {
      "a + b + c",
      "((a + b) + c)",
    },
    {
      "a + b - c",
      "((a + b) - c)",
    },
    {
      "a * b * c",
      "((a * b) * c)",
    },
    {
      "a * b / c",
      "((a * b) / c)",
    },
    {
      "a + b / c",
      "(a + (b / c))",
    },
    {
      "a + b * c + d / e - f",
      "(((a + (b * c)) + (d / e)) - f)",
    },
    {
      "3 + 4; -5 * 5",
      "(3 + 4)((-5) * 5)",
    },
    {
      "5 > 4 == 3 < 4",
      "((5 > 4) == (3 < 4))",
    },
    {
      "5 < 4 != 3 > 4",
      "((5 < 4) != (3 > 4))",
    },
    {
      "3 + 4 * 5 == 3 * 1 + 4 * 5",
      "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))",
    },
    {
      "true",
      "true",
    },
    {
      "false",
      "false",
    },
    {
      "3 > 5 == false",
      "((3 > 5) == false)",
    },
    {
      "3 < 5 == true",
      "((3 < 5) == true)",
    },
    {
      "1 + (2 + 3) + 4",
      "((1 + (2 + 3)) + 4)",
    },
    {
      "(5 + 5) * 2",
      "((5 + 5) * 2)",
    },
    {
      "2 / (5 + 5)",
      "(2 / (5 + 5))",
    },
    {
      "(5 + 5) * 2 * (5 + 5)",
      "(((5 + 5) * 2) * (5 + 5))",
    },
    {
      "-(5 + 5)",
      "(-(5 + 5))",
    },
    {
      "!(true == true)",
      "(!(true == true))",
    },
    {
      "a + add(b * c) + d",
      "((a + add((b * c))) + d)",
    },
    {
      "add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))",
      "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))",
    },
    {
      "add(a + b + c * d / f + g)",
      "add((((a + b) + ((c * d) / f)) + g))",
    },
  }

  for _, tt := range tests {
    l := lexer.New(tt.input)
    p := New(l)
    program := p.ParseProgram()
    checkParserErrors(t, p)

    actual := program.String()
    if actual != tt.expected {
      t.Errorf("expected=%q, got=%q", tt.expected, actual)
    }
  }
}
