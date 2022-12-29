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
