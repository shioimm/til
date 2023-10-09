// Go言語で作るインタプリタ 1
package lexer

import "monkey/token"

type Lexer struct {
  input        string
  position     int
  readPosition int
  ch           byte
}

func New(input string) *Lexer {
  l := &Lexer{input: input}
  l.readChar()
  return l
}

func (l *Lexer) NextToken() token.Token {
  var tok token.Token

  l.skipWhitespace()

  switch l.ch {
  case '!':
    if l.peekChar() == '=' {
      ch := l.ch
      l.readChar()
      literal := string(ch) + string(l.ch)
      tok = token.Token{Type: token.NOT_EQ, Literal: literal}
    } else {
      tok = newToken(token.BANG, l.ch)
    }
  case '=':
    if l.peekChar() == '=' {
      ch := l.ch
      l.readChar()
      literal := string(ch) + string(l.ch)
      tok = token.Token{Type: token.EQ, Literal: literal}
    } else {
      tok = newToken(token.ASSIGN, l.ch)
    }
  case '+':
    tok = newToken(token.PLUS, l.ch)
  case '-':
    tok = newToken(token.MINUS, l.ch)
  case '*':
    tok = newToken(token.ASTERISK, l.ch)
  case '/':
    tok = newToken(token.SLASH, l.ch)
  case '<':
    tok = newToken(token.LT, l.ch)
  case '>':
    tok = newToken(token.GT, l.ch)
  case ',':
    tok = newToken(token.COMMA, l.ch)
  case ';':
    tok = newToken(token.SEMICOLON, l.ch)
  case '(':
    tok = newToken(token.LPAREN, l.ch)
  case ')':
    tok = newToken(token.RPAREN, l.ch)
  case '{':
    tok = newToken(token.LBRACE, l.ch)
  case '}':
    tok = newToken(token.RBRACE, l.ch)
  case '0':
    tok.Literal = ""
    tok.Type = token.EOF
  default:
    if isLetter(l.ch) {
      tok.Literal = l.readIdentifier()
      tok.Type = token.LookupIdent(tok.Literal)
      return tok
    } else if isDigit(l.ch) {
      tok.Type = token.INT
      tok.Literal = l.readNumber()
      return tok
    } else {
      tok = newToken(token.ILLEGAL, l.ch)
    }
  }

  l.readChar()
  return tok
}

func newToken(tokenType token.TokenType, ch byte) token.Token {
  return token.Token{Type: tokenType, Literal: string(ch)}
}

// ホワイトスペースを読み飛ばす
func (l *Lexer) skipWhitespace() {
  for l.ch == ' ' || l.ch == '\t' || l.ch == '\n' || l.ch == '\r' {
    l.readChar()
  }
}

// 次の1文字を読み、入力値の現在位置を1つ進める
func (l *Lexer) readChar() {
  if l.readPosition >= len(l.input) { // 終端
    l.ch = 0
  } else {
    l.ch = l.input[l.readPosition] // 次の文字をセット
  }

  l.position = l.readPosition
  l.readPosition += 1
}

// 次の1文字を読む
func (l *Lexer) peekChar() byte {
  if l.readPosition >= len(l.input) {
    return 0
  } else {
    return l.input[l.readPosition]
  }
}

// 入力値を読み込み、ひとかたまりの英字の値を返す
func (l *Lexer) readIdentifier() string {
  position := l.position
  for isLetter(l.ch) {
    l.readChar()
  }
  return l.input[position:l.position]
}

// 入力値を読み込み、ひとかたまりの整数の値を返す
func (l *Lexer) readNumber() string {
  position := l.position
  for isDigit(l.ch) {
    l.readChar()
  }
  return l.input[position:l.position]
}

// 英字?
func isLetter(ch byte) bool {
  return 'a' <= ch && ch <= 'z' || 'A' <= ch && ch <= 'Z' || ch == '_'
}

// 整数?
func isDigit(ch byte) bool {
  return '0' <= ch && ch <= '9'
}
