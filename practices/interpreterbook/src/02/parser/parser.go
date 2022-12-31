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
  p.registerPrefix(token.INT,   p.parseIntegerLiteral)
  p.registerPrefix(token.BANG,  p.parsePrefixExpression)
  p.registerPrefix(token.MINUS, p.parsePrefixExpression)
  // infixParseFnsマップの初期化
  // (token.***に対して構文解析関数p.parse***を登録)
  p.infixParseFns = make(map[token.TokenType]infixParseFn)
  p.registerInfix(token.PLUS,     p.parseInfixExpression)
  p.registerInfix(token.MINUS,    p.parseInfixExpression)
  p.registerInfix(token.SLASH,    p.parseInfixExpression)
  p.registerInfix(token.ASTERISK, p.parseInfixExpression)
  p.registerInfix(token.EQ,       p.parseInfixExpression)
  p.registerInfix(token.NOT_EQ,   p.parseInfixExpression)
  p.registerInfix(token.LT,       p.parseInfixExpression)
  p.registerInfix(token.GT,       p.parseInfixExpression)
  p.registerInfix(token.LPAREN,   p.parseCallExpression)

  p.nextToken() // curTokenに値を確保
  p.nextToken() // peekToken、curTokenに値を確保
  return p
}

func (p *Parser) ParseProgram() *ast.Program {
  program := &ast.Program{} // ルートノードを生成
  program.Statements = []ast.Statement{}

  // EOFに達するまで入力のトークンを読み込む
  for p.curToken.Type != token.EOF {
    stmt := p.parseStatement()
    if stmt != nil {
      // ルートノードに取得したノードを追加していく
      program.Statements = append(program.Statements, stmt)
    }
    p.nextToken()
  }

  return program
}

func (p *Parser) parseStatement() ast.Statement {
  // p.curToken.Typeに応じて構文解析を行い、ノードを返す
  switch p.curToken.Type {
  case token.LET:
    return p.parseLetStatement()
  case token.RETURN:
    return p.parseReturnStatement()
  default:
    return p.parseExpressionStatement()
}

func (p *Parser) parseLetStatement() *ast.LetStatement {
  stmt := &ast.LetStatement{Token: p.curToken} // LetStatementノードを構築

  if !p.expectPeek(token.IDENT) { // letに続くトークンがIDENTでない場合はnilを返す
    return nil
  }

  // p.curToken.LiteralをValueに持つIdentifierノードを構築し、LetStatementノードに登録
  stmt.Name = &ast.Identifier{Token: p.curToken, Value: p.curToken.Literal}

  if !p.expectPeek(token.ASSIGN) { // 識別子に続くトークンがASSIGNでない場合はnilを返す
    return nil
  }

  p.nextToken() // トークンを進める

  // 式を優先度LOWESTで解析し、結果をLetStatementノードに登録
  stmt.Value = p.parseExpression(LOWEST)

  if p.peekTokenIs(token.SEMICOLON) {
    p.nextToken()
  }

  return stmt // LetStatementノードを返す
}

func (p *Parser) parseReturnStatement() *ast.ReturnStatement {
  stmt := &ast.ReturnStatement{Token: p.curToken} // ReturnStatementノードを構築

  p.nextToken()

  for !p.curTokenIs(token.SEMICOLON) {
    p.nextToken()
  }

  return stmt // ReturnStatementノードを返す
}

func (p *Parser) parseExpressionStatement() *ast.ExpressionStatement {
  stmt := &ast.ExpressionStatement{Token: p.curToken} // ExpressionStatementノードを構築

  // 式を優先度LOWESTで解析し、結果をExpressionStatementノードに登録
  stmt.Expression = p.parseExpression(LOWEST)

  if p.peekTokenIs(token.SEMICOLON) {
    p.nextToken()
  }

  return stmt // ExpressionStatementノードを返す
}

func (p *Parser) parseIdentifier() ast.Expression {
  // Identifierノードを構築し返す
  return &ast.Identifier{Token: p.curToken, Value: p.curToken.Literal}
}

func (p *Parser) parseIntegerLiteral() ast.Expression {
  // IntegerLiteralノードを構築
  lit := &ast.IntegerLiteral{Token: p.curToken}

  value, err := strconv.ParseInt(p.curToken.Literal, 0, 64)
  if err != nil {
    msg := fmt.Sprintf("could not parse %q as integer", p.curToken.Literal)
    p.errors = append(p.errors, msg)
    return nil
  }

  lit.Value = value // ParseIntの結果をIntegerLiteralノードに登録

  return lit // IntegerLiteralノードを返す
}

func (p *Parser) parsePrefixExpression() ast.Expression {
  // PrefixExpressionノードを構築
  expression := &ast.PrefixExpression{Token: p.curToken, Operator: p.curToken.Literal,}

  p.nextToken() // 前置演算子の右側までトークンを進める

  // 式を優先度PREFIXで解析し、結果をPrefixExpressionノードに登録
  expression.Right = p.parseExpression(PREFIX)

  return expression // PrefixExpressionノードを返す
}

func (p *Parser) parseInfixExpression(left ast.Expression) ast.Expression {
  // InfixExpressionノードを構築
  expression := &ast.InfixExpression{Token: p.curToken, Operator: p.curToken.Literal, Left: left,}

  precedence := p.curPrecedence() // 現在のprecedenceを取得
  p.nextToken() // トークンを次へ進める

  // 式を優先度precedenceで解析し、結果をInfixExpressionノードに登録
  expression.Right = p.parseExpression(precedence)

  return expression // InfixExpressionノードを返す
}

func (p *Parser) parseExpression(precedence int) ast.Expression {
  // p.curToken.Typeの前置に関連づけられた構文解析関数が存在するかを確認
  prefix := p.prefixParseFns[p.curToken.Type]
  if prefix == nil {
    p.noPrefixParseFnError(p.curToken.Type)
    return nil
  }
  // p.curToken.Typeの前置に関連づけられた構文解析関数を実行
  // 返ってきた*ast.***LiteralをleftExpに束縛
  leftExp := prefix()

  // 次のトークンが;でなく、現在のprecedenceが次のprecedenceよりも優先される場合
  for !p.peekTokenIs(token.SEMICOLON) && precedence < p.peekPrecedence() {
    // p.peekToken.Typeの中置に関連づけられた構文解析関数が存在するかを確認
    infix := p.infixParseFns[p.peekToken.Type]
    if infix == nil { // 存在しない場合はleftExpを返す
      return leftExp
    }

    p.nextToken() // 存在する場合は次のトークンへ進む

    // 構文解析関数にleftExpを渡して実行し、返り値をleftExpに束縛
    leftExp = infix(leftExp)
  }

  return leftExp
}

// ヘルパー関数
func (p *Parser) nextToken() { // パーサのcurToken・peekTokenを進める
  p.curToken = p.peekToken
  p.peekToken = p.l.NextToken()
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

// Parserインスタンス更新用
// prefixParseFnsにTokenTypeとprefixParseFnの組み合わせを登録
func (p *Parser) registerPrefix(tokenType token.TokenType, fn prefixParseFn) {
  p.prefixParseFns[tokenType] = fn
}

// infixParseFnsにTokenTypeとinfixParseFnの組み合わせを登録
func (p *Parser) registerInfix(tokenType token.TokenType, fn infixParseFn) {
  p.infixParseFns[tokenType] = fn
}

// エラーハンドリング用
func (p *Parser) Errors() []string {
  return p.errors
}

func (p *Parser) peekError(t token.TokenType) {
  msg := fmt.Sprintf("expected next token to be %s, got %s instead", t, p.peekToken.Type)
  p.errors = append(p.errors, msg)
}

func (p *Parser) noPrefixParseFnError(t token.TokenType) {
  msg := fmt.Sprintf("no prefix parse function for %s found", t)
  p.errors = append(p.errors, msg)
}
