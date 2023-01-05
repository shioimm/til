module AST
  class Program
    attr_accessor :statements

    def initialize(statements = [])
      @statements = statements
    end

    def token_literal
      statements.size > 0 ? statements.first.token_literal : ""
    end

    def to_s
      @statements.map(&:to_s).join
    end
  end

  class LetStatement
    attr_accessor :token, :name, :value

    def initialize(token: nil, name: nil, value: nil)
      @token = token
      @name = name
      @value = value
    end

    def token_literal
      token.literal
    end

    def to_s
      "#{token_literal} #{@name} = #{@value.to_s};"
    end
  end

  class Identifier
    attr_accessor :token, :value

    def initialize(token: nil, value: nil)
      @token = token
      @value = value
    end

    def token_literal
      token.literal
    end

    def to_s
      @value
    end
  end

  class ReturnStatement
    attr_accessor :token, :return_value

    def initialize(token: nil, return_value: nil)
      @token = token
      @return_value = return_value
    end

    def token_literal
      token.literal
    end

    def to_s
      "#{token_literal} #{@return_value.to_s};"
    end
  end

  class ExpressionStatement
    attr_accessor :token, :expression

    def initialize(token: nil, expression: nil)
      @token = token
      @expression = expression
    end

    def to_s
      @expression.to_s
    end
  end

  class IntegerLiteral
    attr_accessor :token, :value

    def initialize(token: nil, value: nil)
      @token = token
      @value = value
    end

    def token_literal
      @token.literal
    end

    def to_s
      @token.literal
    end
  end

  class PrefixExpression
    attr_accessor :token, :operator, :right

    def initialize(token: nil, operator: nil, right: nil)
      @token = token
      @operator = operator
      @right = right
    end

    def token_literal
      @token.literal
    end

    def to_s
      "(#{@operator}#{@right.to_s})"
    end
  end

  class InfixExpression
    attr_accessor :token, :left, :operator, :right

    def initialize(token: nil, left: nil, operator: nil, right: nil)
      @token = token
      @left = left
      @operator = operator
      @right = right
    end

    def token_literal
      @token.literal
    end

    def to_s
      "(#{@left.to_s} #{@operator} #{@right.to_s})"
    end
  end

  class Boolean
    attr_accessor :token, :value

    def initialize(token: nil, value: nil)
      @token = token
      @value = value
    end

    def token_literal
      @token.literal
    end

    def to_s
      @token.literal
    end
  end
end
