// Go言語で作るインタプリタ 3
package object

import (
  "bytes"
  "fmt"
  "monkey/ast"
  "strings"
)

type ObjectType string

const (
  NULL_OBJ    = "NULL"
  BOOLEAN_OBJ = "BOOLEAN"
  INTEGER_OBJ = "INTEGER"
)

type Object interface {
  Type() ObjectType
  Inspect() string
}

// Integerオブジェクト
type Integer struct {
  Value int64
}

// Booleanオブジェクト
type Boolean struct {
  bool
}

// Nullオブジェクト
type Null struct{}

// Integer
func (i *Integer) Type() ObjectType {
  return INTEGER_OBJ
}

func (i *Integer) Inspect() string  {
  return fmt.Sprintf("%d", i.Value)
}

// Boolean
func (b *Boolean) Type() ObjectType {
  return BOOLEAN_OBJ
}

func (b *Boolean) Inspect() string  {
  return fmt.Sprintf("%t", b.Value)
}

// Null
func (n *Null) Type() ObjectType {
  return NULL_OBJ
}

func (n *Null) Inspect() string  {
  return "null"
}
