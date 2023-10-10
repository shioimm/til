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
  NULL_OBJ         = "NULL"
  BOOLEAN_OBJ      = "BOOLEAN"
  INTEGER_OBJ      = "INTEGER"
  RETURN_VALUE_OBJ = "RETURN_VALUE"
  FUNCTION_OBJ     = "FUNCTION"
  ERROR_OBJ        = "ERROR"
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

// ReturnValueオブジェクト
type ReturnValue struct {
  Value Object
}

// Functionオブジェクト
type Function struct {
  Parameters []*ast.Identifier
  Body       *ast.BlockStatement
  Env        *Environment
}

// Errorオブジェクト
type Error struct {:
  Message string
}

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

// ReturnValue
func (rv *ReturnValue) Type() ObjectType {
  return RETURN_VALUE_OBJ
}

func (rv *ReturnValue) Inspect() string  {
  return rv.Value.Inspect()
}

// Function
func (f *Function) Type() ObjectType {
  return FUNCTION_OBJ
}

func (f *Function) Inspect() string {
  var out bytes.Buffer

  params := []string{}
  for _, p := range f.Parameters {
    params = append(params, p.String())
  }

  out.WriteString("fn")
  out.WriteString("(")
  out.WriteString(strings.Join(params, ", "))
  out.WriteString(") {\n")
  out.WriteString(f.Body.String())
  out.WriteString("\n}")

  return out.String()
}

// Error
func (e *Error) Type() ObjectType {
  return ERROR_OBJ
}

func (e *Error) Inspect() string  {
  return "ERROR: " + e.Message
}
