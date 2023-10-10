// Go言語で作るインタプリタ 1
package token

type TokenType string

type Token struct {
  Type    TokenType
  Literal string
}

var keywords = map[string]TokenType{
  "fn":     FUNCTION,
  "let":    LET
  "true":   TRUE,
  "false":  FALSE,
  "if":     IF,
  "else":   ELSE,
  "return": RETURN,
}

// identがキーワードの場合: TokenTypeトークン
// そうでない場合: IDENTトークン
func LookupIdent(ident string) TokenType {
  if tok, ok := keywords[ident]; ok {
    return tok
  }
  return IDENT
}

const (
  ILLEGAL = "ILLEGAL"
  EOF     = "EOF"

  // 識別子・リテラル
  IDENT = "IDENT"
  INT   = "INT"

  // 演算子
  BANG     = "!"
  ASSIGN   = "="
  PLUS     = "+"
  MINUS    = "-"
  ASTERISK = "*"
  SLASH    = "/"

  LT = "<"
  GT = ">"

  EQ     = "=="
  NOT_EQ = "!="

  // デリミタ
  COMMA     = ","
  SEMICOLON = ";"

  LPARAN = "("
  RPARAN = ")"
  LBRACE = "{"
  RBRACE = "}"

  // キーワード
  FUNCTION = "FUNCTION"
  LET      = "LET"
)
