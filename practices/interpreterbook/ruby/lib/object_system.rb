module ObjectSystem
  INTEGER_OBJ = "INTEGER"
  BOOLEAN_OBJ = "BOOLEAN"
  NULL_OBJ    = "NULL"

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
end
