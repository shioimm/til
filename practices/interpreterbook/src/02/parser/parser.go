// Go言語で作るインタプリタ 2↲
package parser

import (
  "fmt"
  "monkey/ast"
  "monkey/lexer"
  "monkey/token"
  "strconv"
)

type Parser struct {
  l *lexer.Lexer        // 字句解析器インスタンスへのポインタ
  curToken token.Token  // 現在のトークン
  peekToken token.Token // 次のトークン
  errors []string
}

func New(l *lexer.Lexer) *Parser {
  // 初期化処理
  p := &Parser{l: l}
  p.nextToken() // curTokenに値を確保
  p.nextToken() // peekToken、curTokenに値を確保
  return p
}

// パーサのcurToken・peekTokenを進める
func (p *Parser) nextToken() {
  p.curToken = p.peekToken
  p.peekToken = p.l.NextToken()
}

func (p *Parser) ParseProgram() *ast.Program {
  program := &ast.Program{} // ルートノードを生成
  program.Statements = []ast.Statement{}

  // EOFに達するまで入力のトークンを読み込む
  for p.curToken.Type != token.EOF {
    stmt := p.parseStatement()
    if stmt != nil {
      program.Statements = append(program.Statements, stmt)
    }
    p.nextToken()
  }

  return program
}

func (p *Parser) parseStatement() ast.Statement {
  switch p.curToken.Type {
  case token.LET:
    return p.parseLetStatement()
  case token.RETURN:
    return p.parseReturnStatement()
  default:
    return nil
}

func (p *Parser) parseLetStatement() *ast.LetStatement {
  // LETトークンに基づいてLetStatementノードを構築
  stmt := &ast.LetStatement{Token: p.curToken}

  if !p.expectPeek(token.IDENT) {
    return nil
  }

  // IDENTトークンに基づいてIdentifierノードを構築
  stmt.Name = &ast.Identifier{Token: p.curToken, Value: p.curToken.Literal}

  if !p.expectPeek(token.ASSIGN) {
    return nil
  }

  for !p.curTokenIs(token.SEMICOLON) {
    p.nextToken()
  }

  // 文を返す
  return stmt
}

func (p *Parser) parseReturnStatement() *ast.ReturnStatement {
  // RETURNトークンに基づいてReturnStatementノードを構築
  stmt := &ast.ReturnStatement{Token: p.curToken}

  p.nextToken()

  for !p.curTokenIs(token.SEMICOLON) {
    p.nextToken()
  }

  return stmt
}

func (p *Parser) curTokenIs(t token.TokenType) bool {
  return p.curToken.Type == t
}

func (p *Parser) peekTokenIs(t token.TokenType) bool {
  return p.peekToken.Type == t
}

func (p *Parser) expectPeek(t token.TokenType) bool {
  // 次のトークンの型をチェックし、正しい場合は次のトークンを読み込む
  if p.peekTokenIs(t) {
    p.nextToken()
    return true
  } else {
    p.peekError(t)
    return false
  }
}

func (p *Parser) Errors() []string {
  return p.errors
}

func (p *Parser) peekError(t token.TokenType) {
  msg := fmt.Sprintf("expected next token to be %s, got %s instead", t, p.peekToken.Type)
  p.errors = append(p.errors, msg)
}
