class WSDissector
  def initialize(name:, depth:, protocol:)
    @name     = name
    @depth    = depth
    @protocol = protocol
    @items    = []
    @subtrees = []
  end

  def items(dissecting_items)
    @items = dissecting_items
  end

  def sub(name, &block)
    subtree = self.class.new(name: name, depth: @depth + 1, protocol: @protocol)
    subtree.instance_eval(&block)
    @subtrees << subtree
  end

  def max_depth
    if @subtrees.empty?
      0
    else
      @subtrees.map(&:max_depth).max + 1
    end
  end

  def value_at(offset, type = nil, endian = nil)
    if endian
      @protocol.value_at(offset, type, endian)
    elsif type
      @protocol.value_at(offset, type)
    else
      @protocol.value_at(offset)
    end
  end
end
