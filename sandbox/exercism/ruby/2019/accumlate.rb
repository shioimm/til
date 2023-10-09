# Accumlate from https://exercism.io

class Array
  def accumulate
    block_given? ? map { |s| yield s } : map
  end
end
