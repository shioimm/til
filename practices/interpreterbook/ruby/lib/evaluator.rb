require_relative "ast"
require_relative "object_system"

class Eval
  class << self
    def execute!(node)
      case node
      when ::AST::Program
        eval_statements!(node.statements)
      when ::AST::ExpressionStatement
        execute!(node.expression)
      when ::AST::IntegerLiteral
        ObjectSystem::IntegerObject.new(value: node.value)
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
  end
end
