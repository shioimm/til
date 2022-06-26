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

  def packet(offset, type, endian = nil)
    endian ? @protocol.packet(offset, type, endian) : @protocol.packet(offset, type)
  end
end
