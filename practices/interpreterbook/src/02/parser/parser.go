// Go言語で作るインタプリタ 2↲
package parser

import (
  "fmt"
  "monkey/ast"
  "monkey/lexer"
  "monkey/token"
  "strconv"
)

const (
  _ int = iota
  LOWEST
  EQUALS      // ==
  LESSGREATER // > or <
  SUM         // +
  PRODUCT     // *
  PREFIX      // -X or !X
  CALL        // myFunction(X)
)

// トークンタイプに優先順を関連づける
var precedences = map[token.TokenType]int{
  token.EQ:       EQUALS,
  token.NOT_EQ:   EQUALS,
  token.LT:       LESSGREATER,
  token.GT:       LESSGREATER,
  token.PLUS:     SUM,
  token.MINUS:    SUM,
  token.SLASH:    PRODUCT,
  token.ASTERISK: PRODUCT,
  token.LPAREN:   CALL,
}

type (
  prefixParseFn func() ast.Expression
  infixParseFn  func(ast.Expression) ast.Expression
)

type Parser struct {
  l *lexer.Lexer        // 字句解析器インスタンスへのポインタ
  curToken token.Token  // 現在のトークン
  peekToken token.Token // 次のトークン
  errors []string

  // token.TokenTypeに関連づけられた構文解析関数を中置・前置のマップに収集する
  prefixParseFns map[token.TokenType]prefixParseFn
  infixParseFns  map[token.TokenType]infixParseFn
}

func New(l *lexer.Lexer) *Parser { // 初期化処理
  p := &Parser{l: l, errors: []string{}}

  // prefixParseFnsマップの初期化
  // (token.***に対して構文解析関数p.parse***を登録)
  p.prefixParseFns = make(map[token.TokenType]prefixParseFn)
  p.registerPrefix(token.IDENT, p.parseIdentifier)
  p.registerPrefix(token.INT, p.parseIntegerLiteral)
  p.registerPrefix(token.BANG, p.parsePrefixExpression)
  p.registerPrefix(token.MINUS, p.parsePrefixExpression)

  p.infixParseFns = make(map[token.TokenType]infixParseFn)
  p.registerInfix(token.PLUS, p.parseInfixExpression)
  p.registerInfix(token.MINUS, p.parseInfixExpression)
  p.registerInfix(token.SLASH, p.parseInfixExpression)
  p.registerInfix(token.ASTERISK, p.parseInfixExpression)
  p.registerInfix(token.EQ, p.parseInfixExpression)
  p.registerInfix(token.NOT_EQ, p.parseInfixExpression)
  p.registerInfix(token.LT, p.parseInfixExpression)
  p.registerInfix(token.GT, p.parseInfixExpression)
  p.registerInfix(token.LPAREN, p.parseCallExpression)

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
    return p.parseExpressionStatement()
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

func (p *Parser) parseExpressionStatement() *ast.ExpressionStatement {
  // RETURNトークンに基づいてExpressionStatementノードを構築
  stmt := &ast.ExpressionStatement{Token: p.curToken}

  stmt.Expression = p.parseExpression(LOWEST)

  if p.peekTokenIs(token.SEMICOLON) {
    p.nextToken()
  }

  return stmt
}

func (p *Parser) parseExpression(precedence int) ast.Expression {
  // p.curToken.Typeの前置に関連づけられた構文解析関数があるかを確認
  prefix := p.prefixParseFns[p.curToken.Type]
  if prefix == nil {
    p.noPrefixParseFnError(p.curToken.Type)
    return nil
  }
  // p.curToken.Typeの前置に関連づけられた構文解析関数を実行
  // 返ってきた*ast.***Literalを左辺に代入
  leftExp := prefix()

  for !p.peekTokenIs(token.SEMICOLON) && precedence < p.peekPrecedence() {
    infix := p.infixParseFns[p.peekToken.Type]
    if infix == nil {
      return leftExp
    }

    p.nextToken()

    leftExp = infix(leftExp)
  }

  return leftExp
}

func (p *Parser) parseIdentifier() ast.Expression {
  return &ast.Identifier{Token: p.curToken, Value: p.curToken.Literal}
}

func (p *Parser) parseIntegerLiteral() ast.Expression {
  lit := &ast.IntegerLiteral{Token: p.curToken}

  value, err := strconv.ParseInt(p.curToken.Literal, 0, 64)
  if err != nil {
    msg := fmt.Sprintf("could not parse %q as integer", p.curToken.Literal)
    p.errors = append(p.errors, msg)
    return nil
  }

  lit.Value = value

  return lit
}

func (p *Parser) parsePrefixExpression() ast.Expression {
  expression := &ast.PrefixExpression{
    Token:    p.curToken,
    Operator: p.curToken.Literal,
  }

  // 前置演算子の右側までトークンを進める
  p.nextToken()

  expression.Right = p.parseExpression(PREFIX)

  return expression
}

func (p *Parser) parseInfixExpression(left ast.Expression) ast.Expression {
  expression := &ast.InfixExpression{
    Token:    p.curToken,
    Operator: p.curToken.Literal,
    Left:     left,
  }

  precedence := p.curPrecedence()
  p.nextToken()
  expression.Right = p.parseExpression(precedence)

  return expression
}

// ヘルパー関数
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

func (p *Parser) registerPrefix(tokenType token.TokenType, fn prefixParseFn) {
  p.prefixParseFns[tokenType] = fn
}

func (p *Parser) registerInfix(tokenType token.TokenType, fn infixParseFn) {
  p.infixParseFns[tokenType] = fn
}

func (p *Parser) noPrefixParseFnError(t token.TokenType) {
  msg := fmt.Sprintf("no prefix parse function for %s found", t)
  p.errors = append(p.errors, msg)
}

// 次のトークンのトークンタイプに対応している優先順を返す
func (p *Parser) peekPrecedence() int {
  if p, ok := precedences[p.peekToken.Type]; ok {
    return p
  }

  return LOWEST
}

// 現在のトークンのトークンタイプに対応している優先順を返す
func (p *Parser) curPrecedence() int {
  if p, ok := precedences[p.curToken.Type]; ok {
    return p
  }

  return LOWEST
}
