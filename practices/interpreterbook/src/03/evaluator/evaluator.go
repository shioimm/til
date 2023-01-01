// Go言語で作るインタプリタ 3
package evaluator

import (
  "fmt"
  "monkey/ast"
  "monkey/object"
)

func Eval(node ast.Node, env *object.Environment) object.Object {
  switch node := node.(type) {
  // 分
  case *ast.Program:
    return evalProgram(node, env)
  case *ast.ExpressionStatement:
    return Eval(node.Expression, env)

  // 式
  case *ast.IntegerLiteral:
    return &object.Integer{Value: node.Value}
  }

  return nil
}

func evalStatements(stmts []ast.Statement) object.Object {
  var result object.Object

  for _, statement := range stmts {
    result = Eval(statement)
  }

  return result
}
