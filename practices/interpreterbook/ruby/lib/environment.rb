module ObjectSystem
  class Environment
    attr_accessor :store

    def initialize(store: {})
      @store = store
    end

    def get(key)
      @store[key]
    end

    def set(key, val)
      @store[key] = val
    end
  end
end
