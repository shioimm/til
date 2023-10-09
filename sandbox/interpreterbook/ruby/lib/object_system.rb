require_relative './ast'

module ObjectSystem
  INTEGER_OBJ       = "INTEGER"
  BOOLEAN_OBJ       = "BOOLEAN"
  NULL_OBJ          = "NULL"
  RETURN_VALUE_OBJ  = "RETURN_OBJ"
  ERROR_OBJ         = "ERROR"
  FUNCTION_OBJ      = "FUNCTION"

  class Object
    attr_accessor :evaluated

    def initialize(evaluated: nil)
      @evaluated = evaluated
    end
  end

  class IntegerObject
    attr_accessor :value

    def initialize(value: nil)
      @value = value
    end

    def object_type
      INTEGER_OBJ
    end

    def inspect
      @value.to_s
    end
  end

  class BooleanObject
    attr_accessor :value

    def initialize(value: nil)
      @value = value
    end

    def object_type
      BOOLEAN_OBJ
    end

    def inspect
      @value.to_s
    end
  end

  class NullObject
    attr_reader :value

    def initialize
      @value = nil
    end

    def object_type
      NULL_OBJ
    end

    def inspect
      "null"
    end
  end

  class ReturnValueObject
    attr_accessor :value

    def initialize(value: nil)
      @value = value
    end

    def object_type
      RETURN_VALUE_OBJ
    end

    def inspect
      @value.inspect
    end
  end

  class ErrorObject
    attr_accessor :message

    def initialize(message: nil)
      @message = message
    end

    def object_type
      ERROR_OBJ
    end

    def inspect
      "[ERROR] #{@message}"
    end
  end

  class FunctionObject
    attr_accessor :params, :body, :env

    def initialize(params: [], body: nil, env: nil)
      @params = params
      @body = body
      @env = env
    end

    def object_type
      FUNCTION_OBJ
    end

    def inspect
      "fn(#{@params.join(', ')}) {\n  #{@body.to_s}\n}"
    end
  end
end
