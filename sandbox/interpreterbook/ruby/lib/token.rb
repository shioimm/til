class Token
  ILLEGAL   = "ILLEGAL"
  EOF       = "EOF"
  IDENT     = "IDENT"
  INT       = "INT"
  BANG      = "!"
  ASSIGN    = "="
  PLUS      = "+"
  MINUS     = "-"
  ASTERISK  = "*"
  SLASH     = "/"
  LT        = "<"
  GT        = ">"
  EQ        = "=="
  NOT_EQ    = "!="
  COMMA     = ","
  SEMICOLON = ";"
  LPAREN    = "("
  RPAREN    = ")"
  LBRACE    = "{"
  RBRACE    = "}"
  FUNCTION  = "FUNCTION"
  LET       = "LET"
  TRUE      = "TRUE"
  FALSE     = "FALSE"
  IF        = "IF"
  ELSE      = "ELSE"
  RETURN    = "RETURN"


  class << self
    def lookup_identifier(ident)
      keywords.fetch(ident, IDENT)
    end

    private

    def keywords
      {
        "fn"     => FUNCTION,
        "let"    => LET,
        "true"   => TRUE,
        "false"  => FALSE,
        "if"     => IF,
        "else"   => ELSE,
        "return" => RETURN,
      }
    end
  end

  attr_accessor :type, :literal

  def initialize(type: nil, literal: nil)
    @type = type
    @literal = literal
  end
end
