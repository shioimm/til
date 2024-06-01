class CollatzConjecture
  class << self
    def steps(n)
      raise ArgumentError if 0 >= n

      (0..).each do |step|
        return step if n == 1
        n = n.odd? ? (n * 3 + 1) : n / 2
      end
    end
  end
end
