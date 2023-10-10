require_relative "ast"
require_relative "object_system"

class Eval
  TRUE_OBJ  ||= ObjectSystem::BooleanObject.new(value: true)
  FALSE_OBJ ||= ObjectSystem::BooleanObject.new(value: false)
  NULL_OBJ  ||= ObjectSystem::NullObject.new

  class << self
    def execute!(node, env)
      case node
      when ::AST::Program
        eval_program!(node, env)
      when ::AST::ExpressionStatement
        execute!(node.expression, env)
      when ::AST::IntegerLiteral
        ObjectSystem::IntegerObject.new(value: node.value)
      when ::AST::Boolean
        native_bool_to_boolean_object(node.value)
      when ::AST::PrefixExpression
        right = execute!(node.right, env)
        return right if error?(right)
        eval_prefix_expression!(node.operator, right)
      when ::AST::InfixExpression
        left = execute!(node.left, env)
        return left if error?(left)
        right = execute!(node.right, env)
        return right if error?(right)
        eval_infix_expression!(node.operator, left, right)
      when ::AST::BlockStatement
        eval_block_statement!(node, env)
      when ::AST::IfExpression
        eval_if_expression!(node, env)
      when ::AST::ReturnStatement
        val = execute!(node.return_value, env)
        return val if error?(val)
        ObjectSystem::ReturnValueObject.new(value: val)
      when ::AST::LetStatement
        val = execute!(node.value, env)
        return val if error?(val)
        env.set(node.name.value, val)
      when ::AST::Identifier
        eval_identifier!(node, env)
      when ::AST::FunctionLiteral
        params = node.params
        body = node.body
        ObjectSystem::FunctionObject.new(params: params, body: body, env: env)
      when ::AST::CallExpression
        function = execute!(node.function, env)
        return function if error?(function)
        args = eval_expressions!(node.args, env)
        return args if args.first && error?(args.first)
        apply_function(function, args)
      else
        nil
      end
    end

    private

    def eval_program!(program, env)
      result = nil
      program.statements.each do |stmt|
        result = execute!(stmt, env)

        case result
        when ObjectSystem::ReturnValueObject
          return result.value
        when ObjectSystem::ErrorObject
          return result
        end
      end
      result
    end

    def eval_prefix_expression!(operator, right)
      case operator
      when "!"
        eval_bang_operator_expression!(right)
      when "-"
        eval_minus_prefix_operator_expression!(right)
      else
        new_error("unknown operator: #{operator}#{right.object_type}")
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
      return new_error("unknown operator: -#{right.object_type}") if !right.value.is_a? Integer

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
      when left.class != right.class
        new_error("type mismatch: #{left.object_type} #{operator} #{right.object_type}")
      else
        new_error("unknown operator: #{left.object_type} #{operator} #{right.object_type}")
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
        new_error("unknown operator: #{left.object_type} #{operator} #{right.object_type}")
      end
    end

    def eval_if_expression!(node, env)
      condition = execute!(node.condition, env)
      return condition if error?(condition)

      if truthy?(condition)
        execute!(node.consequence, env)
      elsif !node.alternative.nil?
        execute!(node.alternative, env)
      else
        nil
      end
    end

    def eval_block_statement!(block, env)
      result = nil
      block.statements.each do |stmt|
        result = execute!(stmt, env)
        return result if [ObjectSystem::RETURN_VALUE_OBJ, ObjectSystem::ERROR_OBJ].include? result.object_type
      end
      result
    end

    def eval_identifier!(node, env)
      val = env.get(node.value)
      return new_error("identifier not found: #{node.value}") if val.nil?
      val
    end

    def eval_expressions!(exps, env)
      exps.each_with_object([]) do |exp, result|
        evaluated = execute!(exp, env)
        return ObjectSystem::Object.new(evaluated: evaluated) if error?(evaluated)
        result << evaluated
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

    def error?(obj)
      obj.object_type == ObjectSystem::ErrorObject
    end

    def new_error(messages)
      ObjectSystem::ErrorObject.new(message: Array(messages).join(", "))
    end

    def apply_function(function, args)
      extended_env = extended_function_env(function, args)
      evaluated = execute!(function.body, extended_env)
      unwrap_return_value(evaluated)
    end

    def extended_function_env(function, args)
      env = ObjectSystem::Environment.new_closed_environment(function.env)
      function.params.each_with_index do |param, i|
        env.set(param.value, args[i])
      end
      env
    end

    def unwrap_return_value(obj)
      obj.return_value if obj.respond_to?(:return_value)
      obj
    end
  end
end
