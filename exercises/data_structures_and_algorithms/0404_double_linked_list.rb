class Node
  attr_accessor :prv, :key, :nxt

  def initialize
    @prv = nil
    @key  = nil
    @nxt = nil
  end
end

class DounbleLinkedList
  attr_reader :container

  def initialize
    @container = [Node.new]
  end

  def insert(n)
    element = Node.new
    element.key = n
    if @container.first.key.nil?
      @container.delete @container.first
    else
      element.nxt = @container.first
      @container.first.prv = element
    end
    @container.unshift element
  end

  def delete(n)
    element = @container.find { |element| element.key.eql? n }
    prv = element.prv
    nxt = element.nxt
    @container.delete element
    prv.nxt = nxt
    nxt&.prv = prv
  end

  def keys
    @container.map(&:key)
  end
end

double_linked_list = DounbleLinkedList.new

double_linked_list.insert 5
double_linked_list.insert 2
double_linked_list.insert 3
double_linked_list.insert 1
double_linked_list.delete 3
double_linked_list.insert 6
double_linked_list.delete 5

pp double_linked_list.keys
