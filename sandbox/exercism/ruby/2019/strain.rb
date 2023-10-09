# Strain from https://exercism.io

class Array
  def keep
    each_with_object([]) { |s, arr| arr << s if yield s }
  end

  def discard
    each_with_object([]) { |s, arr| arr << s unless yield s }
  end
end
