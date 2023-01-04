module AST
  class Program
    attr_accessor :statements

    def initialize
      @statements = []
    end

    def token_literal
      statements.size > 0 ? statements.first.token_literal : ""
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
  end
end
