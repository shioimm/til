module ObjectSystem
  class Environment
    attr_accessor :store

    def self.new_closed_environment(outer)
      new(outer: outer)
    end

    def initialize(store: {}, outer: nil)
      @store = store
      @outer = outer
    end

    def get(key)
      val = @store[key]

      if val.nil? && !@outer.nil?
        val = @outer.get(key)
      end

      val
    end

    def set(key, val)
      @store[key] = val
    end
  end
end
