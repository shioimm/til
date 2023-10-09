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
  Statements []Statement // プログラム内部
}

// LetStatementノード
type LetStatement struct {
  Token token.Token // letトークン
  Name *Identifier  // 識別子 (変数名)
  Value Expression  // 右辺の式
}

// Identifierノード
type Identifier struct {
  Token token.Token // 識別子トークン
  Value string      // 識別子名
}

// ReturnStatementノード
type ReturnStatement struct {
  Token token.Token      // returnトークン
  ReturnValue Expression // 返り値
}

// ExpressionStatementノード
type ExpressionStatement struct {
  Token toke.Token      // 式トークン
  Expression Expression // 式内部
}

// IntegerLiteralノード
type IntegerLiteral struct {
  Token token.Token // 整数値トークン
  Value int64       // 数値
}

// PrefixExpressionノード
type PrefixExpression struct {
  Token    token.Token // 前置トークン
  Operator string      // 演算子
  Right    Expression  // 右辺
}

// InfixExpressionノード
type InfixExpression struct {
  Token    token.Token // 中置トークン
  Left     Expression  // 左辺
  Operator string      // 演算子
  Right    Expression  // 右辺
}

// Booleanノード
type Boolean struct {
  Token token.Token // 真偽値トークン
  Value bool        // 真偽値
}

type IfExpression struct {
  Token       token.Token     // ifトークン
  Condition   Expression      // 条件
  Consequence *BlockStatement // 真の場合の処理
  Alternative *BlockStatement // 偽の場合の処理
}

// FunctionLiteralノード
type FunctionLiteral struct {
  Token      token.Token     // fnトークン
  Parameters []*Identifier   // 識別子 (関数名)
  Body       *BlockStatement // 関数内部
}

// BlockStatementノード
type BlockStatement struct {
  Token      token.Token // {トークン
  Statements []Statement // ブロック内部
}

// CallExpressionノード
type CallExpression struct {
  Token     token.Token  // (トークン
  Function  Expression   // 呼び出し関数
  Arguments []Expression // 引数
}

// 一般
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

// LetStatement
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

// Identifier
func (i *Identifier) expressionNode() {
}

func (i *Identifier) TokenLiteral() string {
  return i.Token.Literal
}

func (i *Identifier) String() string {
  return i.Value
}

// ReturnStatement
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

// ExpressionStatement
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

// IntegerLiteral
func (il *IntegerLiteral) expressionNode() {
}

func (il *IntegerLiteral) TokenLiteral() string {
  return il.Token.Literal
}

func (il *IntegerLiteral) String() string {
  return il.Token.Literal
}

// PrefixExpression
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

// InfixExpression
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

// Boolean
func (b *Boolean) expressionNode() {
}

func (b *Boolean) TokenLiteral() string {
  return b.Token.Literal
}

func (b *Boolean) String() string {
  return b.Token.Literal
}

// IfExpression
func (ie *IfExpression) expressionNode() {
}

func (ie *IfExpression) TokenLiteral() string {
  return ie.Token.Literal
}

func (ie *IfExpression) String() string {
  var out bytes.Buffer

  out.WriteString("if")
  out.WriteString(ie.Condition.String())
  out.WriteString(" ")
  out.WriteString(ie.Consequence.String())

  if ie.Alternative != nil {
    out.WriteString("else ")
    out.WriteString(ie.Alternative.String())
  }

  return out.String()
}

// FunctionLiteral
func (fl *FunctionLiteral) expressionNode() {
}

func (fl *FunctionLiteral) TokenLiteral() string {
  return fl.Token.Literal
}

func (fl *FunctionLiteral) String() string {
  var out bytes.Buffer

  params := []string{}
  for _, p := range fl.Parameters {
    params = append(params, p.String())
  }

  out.WriteString(fl.TokenLiteral())
  out.WriteString("(")
  out.WriteString(strings.Join(params, ", "))
  out.WriteString(") ")
  out.WriteString(fl.Body.String())

  return out.String()
}

// BlockStatement
func (bs *BlockStatement) statementNode() {
}

func (bs *BlockStatement) TokenLiteral() string {
  return bs.Token.Literal
}

func (bs *BlockStatement) String() string {
  var out bytes.Buffer

  for _, s := range bs.Statements {
    out.WriteString(s.String())
  }

  return out.String()
}

// CallExpression
func (ce *CallExpression) expressionNode() {
}

func (ce *CallExpression) TokenLiteral() string {
  return ce.Token.Literal
}

func (ce *CallExpression) String() string {
  var out bytes.Buffer

  args := []string{}
  for _, a := range ce.Arguments {
    args = append(args, a.String())
  }

  out.WriteString(ce.Function.String())
  out.WriteString("(")
  out.WriteString(strings.Join(args, ", "))
  out.WriteString(")")

  return out.String()
}
