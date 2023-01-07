require_relative "ast"
require_relative "object_system"

class Eval
  TRUE_OBJ  = ObjectSystem::BooleanObject.new(value: true)
  FALSE_OBJ = ObjectSystem::BooleanObject.new(value: false)
  NULL_OBJ  = ObjectSystem::NullObject.new

  class << self
    def execute!(node)
      case node
      when ::AST::Program
        eval_statements!(node.statements)
      when ::AST::ExpressionStatement
        execute!(node.expression)
      when ::AST::IntegerLiteral
        ObjectSystem::IntegerObject.new(value: node.value)
      when ::AST::Boolean
        native_bool_to_boolean_object(node.value)
      when ::AST::PrefixExpression
        right = execute!(node.right)
        eval_prefix_expression!(node.operator, right)
      else
        nil
      end
    end

    private

    def eval_statements!(statements)
      result = nil
      statements.each { |stmt| result = execute!(stmt) }
      result
    end

    def eval_prefix_expression!(operator, right)
      case operator
      when "!" then eval_bang_operator_expression!(right)
      else
        nil
      end
    end

    def eval_bang_operator_expression!(right)
      case right.value
      when true  then FALSE_OBJ
      when false then TRUE_OBJ
      when nil   then TRUE_OBJ
      else
        FALSE_OBJ
      end
    end

    def native_bool_to_boolean_object(bool)
      bool.is_a?(TrueClass) ? TRUE_OBJ : FALSE_OBJ
    end
  end
end
