require_relative "ast"
require_relative "object_system"

class Eval
  TRUE_OBJ  ||= ObjectSystem::BooleanObject.new(value: true)
  FALSE_OBJ ||= ObjectSystem::BooleanObject.new(value: false)
  NULL_OBJ  ||= ObjectSystem::NullObject.new

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
      when ::AST::InfixExpression
        left = execute!(node.left)
        right = execute!(node.right)
        eval_infix_expression!(node.operator, left, right)
      when ::AST::BlockStatement
        eval_statements!(node.statements)
      when ::AST::IfExpression
        eval_if_expression!(node)
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
      when "!"
        eval_bang_operator_expression!(right)
      when "-"
        eval_minus_prefix_operator_expression!(right)
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

    def eval_minus_prefix_operator_expression!(right)
      return nil if !right.value.is_a? Integer

      ObjectSystem::IntegerObject.new(value: -right.value)
    end

    def eval_infix_expression!(operator, left, right)
      case
      when left.object_type == ObjectSystem::INTEGER_OBJ && right.object_type == ObjectSystem::INTEGER_OBJ
        eval_integer_infix_expression!(operator, left, right)
      when operator == "=="
        native_bool_to_boolean_object(left.value == right.value)
      when operator == "!="
        native_bool_to_boolean_object(left.value != right.value)
      else
        nil
      end
    end

    def eval_integer_infix_expression!(operator, left, right)
      left_val = left.value
      right_val = right.value

      case operator
      when "+"
        ObjectSystem::IntegerObject.new(value: left_val + right_val)
      when "-"
        ObjectSystem::IntegerObject.new(value: left_val - right_val)
      when "*"
        ObjectSystem::IntegerObject.new(value: left_val * right_val)
      when "/"
        ObjectSystem::IntegerObject.new(value: left_val / right_val)
      when "<"
        ObjectSystem::IntegerObject.new(value: left_val < right_val)
      when ">"
        ObjectSystem::IntegerObject.new(value: left_val > right_val)
      when "=="
        ObjectSystem::IntegerObject.new(value: left_val == right_val)
      when "!="
        ObjectSystem::IntegerObject.new(value: left_val != right_val)
      else
        nil
      end
    end

    def eval_if_expression!(node)
      condition = execute!(node.condition)

      if truthy?(condition)
        execute!(node.consequence)
      elsif !node.alternative.nil?
        execute!(node.alternative)
      else
        nil
      end
    end

    def native_bool_to_boolean_object(bool)
      bool.is_a?(TrueClass) ? TRUE_OBJ : FALSE_OBJ
    end

    def truthy?(obj)
      case obj.value
      when NULL_OBJ.value  then false
      when TRUE_OBJ.value  then true
      when FALSE_OBJ.value then false
      else
        true
      end
    end
  end
end
