class Stack
  MAXIMUM = 100

  attr_reader :container

  def initialize
    @top = 0
    @container = []
  end

  def empty?
    top.zero?
  end

  def filled?
    top >= MAXIMUM - 1
  end

  def push(x)
    raise if filled?

    @top += 1
    container[top] = x
  end

  def pop
    raise if empty?

    @top -= 1
    container.delete_at(top + 1)
  end

  private

    attr_reader :top
end

polish = '1 2 + 3 4 - *'.split

stack = Stack.new

polish.each do |element|
  if element.match?(/\d/)
    stack.push(element.to_i)
  elsif element.match?(/\W/)
    number1, number2 = stack.pop, stack.pop
    stack.push(number2.send(element, number1))
  end
end

p stack.container.last
