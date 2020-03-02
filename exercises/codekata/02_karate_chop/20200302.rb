# 引用: [Kata02: Karate Chop](http://codekata.com/kata/kata02-karate-chop/)

def chop(int, array_of_int)
  min = 0
  max = array_of_int.length

  loop do
    mid = (min + max) / 2

    if int == array_of_int[mid]
      return array_of_int.index(array_of_int[mid])
    elsif array_of_int[min] ==  array_of_int[mid] || array_of_int[max] == array_of_int[mid]
      return -1
    elsif int > array_of_int[mid]
      min = mid
    elsif int < array_of_int[mid]
      max = mid
    end
  end
end

require 'minitest/autorun'

class ChopTest < Minitest::Test
  def test_chop
    assert_equal(-1, chop(3, []))
    assert_equal(-1, chop(3, [1]))
    assert_equal(0,  chop(1, [1]))

    assert_equal(0,  chop(1, [1, 3, 5]))
    assert_equal(1,  chop(3, [1, 3, 5]))
    assert_equal(2,  chop(5, [1, 3, 5]))
    assert_equal(-1, chop(0, [1, 3, 5]))
    assert_equal(-1, chop(2, [1, 3, 5]))
    assert_equal(-1, chop(4, [1, 3, 5]))
    assert_equal(-1, chop(6, [1, 3, 5]))

    assert_equal(0,  chop(1, [1, 3, 5, 7]))
    assert_equal(1,  chop(3, [1, 3, 5, 7]))
    assert_equal(2,  chop(5, [1, 3, 5, 7]))
    assert_equal(3,  chop(7, [1, 3, 5, 7]))
    assert_equal(-1, chop(0, [1, 3, 5, 7]))
    assert_equal(-1, chop(2, [1, 3, 5, 7]))
    assert_equal(-1, chop(4, [1, 3, 5, 7]))
    assert_equal(-1, chop(6, [1, 3, 5, 7]))
    assert_equal(-1, chop(8, [1, 3, 5, 7]))
  end
end
