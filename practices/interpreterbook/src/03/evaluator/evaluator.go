// Go言語で作るインタプリタ 3
package evaluator

import (
  "fmt"
  "monkey/ast"
  "monkey/object"
)

var (
  NULL  = &object.Null{}
  TRUE  = &object.Boolean{Value: true}
  FALSE = &object.Boolean{Value: false}
)

func Eval(node ast.Node) object.Object {
  switch node := node.(type) {
  // 文
  case *ast.Program:
    return evalProgram(node)
  case *ast.ExpressionStatement:
    return Eval(node.Expression)
  case *ast.BlockStatement:
    return evalBlockStatement(node)
  case *ast.ReturnStatement:
    val := Eval(node.ReturnValue)
    return &object.ReturnValue{Value: val}

  // 式
  case *ast.IntegerLiteral:
    return &object.Integer{Value: node.Value}
  case *ast.Boolean:
    return nativeBoolToBooleanObject(node.Value)
  case *ast.PrefixExpression:
    right := Eval(node.Right)
    return evalPrefixExpression(node.Operator, right)
  case *ast.InfixExpression:
    left := Eval(node.Left)
    right := Eval(node.Right)
    return evalInfixExpression(node.Operator, left. right)
  case *ast.IfExpression:
    return evalIfExpression(node)
  }

  return nil
}

func evalProgram(program *ast.Program) object.Object {
  var result object.Object

  for _, statement := range program.Statements {
    result = Eval(statement)

    if returnValue, ok := result.(*object.ReturnValue); ok {
      return returnValue.Value
    }
  }

  return result
}

func evalPrefixExpression(operator string, right object.Object) object.Object {
  switch operator {
  case "!":
    return evalBangOperatorExpression(right)
  case "-":
    return evalMinusPrefixOperatorExpression(right)
  default:
    return newError("unknown operator: %s%s", operator, right.Type())
  }
}

func evalInfixExpression(operator string, left, right object.Object) object.Object {
  switch {
  case left.Type() == object.INTEGER_OBJ && right.Type() == object.INTEGER_OBJ:
    return evalIntegerInfixExpression(operator, left, right)
  case operator == "==":
    return nativeBoolToBooleanObject(left == right)
  case operator == "!=":
    return nativeBoolToBooleanObject(left != right)
  default:
    NULL
  }
}

func evalIntegerInfixExpression(operator string, left, right object.Object) object.Object {
  leftVal := left.(*object.Integer).Value
  rightVal := right.(*object.Integer).Value

  switch operator {
  case "+":
    return &object.Integer{Value: leftVal + rightVal}
  case "-":
    return &object.Integer{Value: leftVal - rightVal}
  case "*":
    return &object.Integer{Value: leftVal * rightVal}
  case "/":
    return &object.Integer{Value: leftVal / rightVal}
  case "<":
    return nativeBoolToBooleanObject(leftVal < rightVal)
  case ">":
    return nativeBoolToBooleanObject(leftVal > rightVal)
  case "==":
    return nativeBoolToBooleanObject(leftVal == rightVal)
  case "!=":
    return nativeBoolToBooleanObject(leftVal != rightVal)
  default:
    return NULL
  }
}

func evalBangOperatorExpression(right object.Object) object.Object {
  switch right {
  case TRUE:
    return FALSE
  case FALSE:
    return TRUE
  case NULL:
    return TRUE
  default:
    return FALSE
  }
}

func evalMinusPrefixOperatorExpression(right object.Object) object.Object {
  if right.Type() != object.INTEGER_OBJ {
    return newError("unknown operator: -%s", right.Type())
  }

  value := right.(*object.Integer).Value
  return &object.Integer{Value: -value}
}

func evalIfExpression(ie *ast.IfExpression) object.Object {
  condition := Eval(ie.Condition)

  if isTruthy(condition) {
    return Eval(ie.Consequence)
  } else if ie.Alternative != nil {
    return Eval(ie.Alternative)
  } else {
    return NULL
  }
}

func evalBlockStatement(block *ast.BlockStatement) object.Object {
  var result object.Object

  for _, statement := range block.Statements {
    result = Eval(statement)

    if result != nil {
      rt := result.Type()
      if rt == object.RETURN_VALUE_OBJ {
        return result
      }
    }
  }

  return result
}

// ヘルパー関数
func nativeBoolToBooleanObject(input bool) *object.Boolean {
  if input {
    return TRUE
  }
  return FALSE
}

func isTruthy(obj object.Object) bool {
  switch obj {
  case NULL:
    return false
  case TRUE:
    return true
  case FALSE:
    return false
  default:
    return true
  }
}
