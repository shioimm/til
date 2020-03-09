# List Ops from https://exercism.io

class ListOps
  class << self
    def arrays(arr, acc = 0)
      func(arr, 0) { |element, acc| acc += 1 }
    end

    def reverser(arr, acc = [])
      func(arr, []) { |element, acc| acc.unshift element }
    end

    def concatter(acc, arr)
      func(arr, acc) { |element, acc| acc << element }
    end

    def mapper(arr, acc = [])
      func(arr, []) { |element, acc| acc << yield(element) }
    end

    def filterer(arr, acc = [])
      func(arr, []) { |element, acc| yield(element) ? acc << element : acc }
    end

    def sum_reducer(arr)
      func(arr, 0) { |element, acc| acc += element }
    end

    def factorial_reducer(arr)
      func(arr, 1) { |element, acc| acc *= element }
    end

    private

      def func(arr, acc)
        arr.each { |element| acc = yield(element, acc) }.then { acc }
      end
  end
end
