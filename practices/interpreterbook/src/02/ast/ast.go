// Go言語で作るインタプリタ 2
package ast

import (
  "bytes"
  "monkey/token"
  "strings"
)

type Node interface {
  TokenLiteral() string
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

// Returnノード
type ReturnStatement struct {
  Token token.Token // token.RETURN
  ReturnValue Expression
}

func (p *Program) TokenLiteral() string {
  if len(p.Statements) > 0 {
    return p.Statements[0].TokenLiteral()
  } else {
    return ""
  }
}

func (ls *LetStatement) statementNode() {
}

func (ls *LetStatement) TokenLiteral() string {
  return ls.Token.Literal
}

func (i *Identifier) expressionNode() {
}

func (i *Identifier) TokenLiteral() string {
  return i.Token.Literal
}

func (rs *ReturnStatement) statementNode() {
}

func (rs *ReturnStatement) TokenLiteral() string {
  return rs.Token.Literal
}
