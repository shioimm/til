// Go言語で作るインタプリタ 2
package ast

import (
  "bytes"
  "monkey/token"
  "strings"
)

type Node interface {
  TokenLiteral() string
  String() string
}

type Statement interface {
  Node
  statementNode()
}

type Expression interface {
  Node
  expressionNode()
}

// ルートノード
type Program struct {
  Statements []Statement
}

// LetStatementノード
type LetStatement struct { // Statementインターフェース
  Token token.Token // token.LET
  Name *Identifier  // 束縛の識別子の名前を保持する
  Value Expression  // 値を生成する式を保持する
}

// Identifierノード
type Identifier struct {
  Token token.Token // token.IDENT
  Value string      // 束縛の識別子の名前の値を保持する
}

// ReturnStatementノード
type ReturnStatement struct {
  Token token.Token // token.RETURN
  ReturnValue Expression
}

// ExpressionStatementノード
type ExpressionStatement struct {
  Token toke.Token // 式の最初のトークン
  Expression Expression
}

// IntegerLiteralノード
type IntegerLiteral struct {
  Token token.Token
  Value int64
}

// PrefixExpressionノード
type PrefixExpression struct {
  Token    token.Token // 前置トークン
  Operator string
  Right    Expression
}

// InfixExpressionノード
type InfixExpression struct {
  Token    token.Token // The operator token, e.g. +
  Left     Expression
  Operator string
  Right    Expression
}

// -----

func (p *Program) TokenLiteral() string {
  if len(p.Statements) > 0 {
    return p.Statements[0].TokenLiteral()
  } else {
    return ""
  }
}

func (p *Program) String() string {↲
  var out bytes.Buffer

  for _, s := range p.Statements {
    out.WriteString(s.String())
  }

  return out.String()
}

func (ls *LetStatement) statementNode() {
}

func (ls *LetStatement) TokenLiteral() string {
  return ls.Token.Literal
}

func (ls *LetStatement) String() string {
  var out bytes.Buffer

  out.WriteString(ls.TokenLiteral() + " ")
  out.WriteString(ls.Name.String())
  out.WriteString(" = ")

  if ls.Value != nil {
    out.WriteString(ls.Value.String())
  }

  out.WriteString(";")

  return out.String()
}

func (i *Identifier) expressionNode() {
}

func (i *Identifier) TokenLiteral() string {
  return i.Token.Literal
}

func (i *Identifier) String() string {
  return i.Value
}

func (rs *ReturnStatement) statementNode() {
}

func (rs *ReturnStatement) TokenLiteral() string {
  return rs.Token.Literal
}

func (rs *ReturnStatement) String() string {
  var out bytes.Buffer

  out.WriteString(rs.TokenLiteral() + " ")

  if rs.ReturnValue != nil {
    out.WriteString(rs.ReturnValue.String())
  }

  out.WriteString(";")

  return out.String()
}

func (es *ExpressionStatement) statementNode() {
}

func (es *ExpressionStatement) TokenLiteral() string {
  return es.Token.Literal
}

func (es *ExpressionStatement) String() string {
  if es.Expression != nil {
    return es.Expression.String()
  }
  return ""
}

func (il *IntegerLiteral) expressionNode() {
}

func (il *IntegerLiteral) TokenLiteral() string {
  return il.Token.Literal
}

func (il *IntegerLiteral) String() string {
  return il.Token.Literal
}

func (pe *PrefixExpression) expressionNode() {
}

func (pe *PrefixExpression) TokenLiteral() string {
  return pe.Token.Literal
}

func (pe *PrefixExpression) String() string {
  var out bytes.Buffer

  out.WriteString("(")
  out.WriteString(pe.Operator)
  out.WriteString(pe.Right.String())
  out.WriteString(")")

  return out.String()
}

func (oe *InfixExpression) expressionNode() {
}

func (oe *InfixExpression) TokenLiteral() string {
  return oe.Token.Literal
}

func (oe *InfixExpression) String() string {
  var out bytes.Buffer

  out.WriteString("(")
  out.WriteString(oe.Left.String())
  out.WriteString(" " + oe.Operator + " ")
  out.WriteString(oe.Right.String())
  out.WriteString(")")

  return out.String()
}
