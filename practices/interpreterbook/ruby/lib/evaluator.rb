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

    def native_bool_to_boolean_object(bool)
      bool.is_a?(TrueClass) ? TRUE_OBJ : FALSE_OBJ
    end
  end
end
