class WSDissector
  ENC_BIG_ENDIAN  = nil # C側で実装
  FORMAT_ADD_ITEM = nil # C側で実装

  def initialize(name:, depth:)
    @name     = name
    @depth    = depth
    @items    = []
    @subtrees = []
  end

  def items(dissecting_items)
    @items = dissecting_items
  end

  def sub(name, &block)
    subtree = self.class.new(name: name, depth: @depth + 1)
    block.call subtree
    @subtrees << subtree
  end

  def max_depth
    if @subtrees.empty?
      0
    else
      @subtrees.map(&:max_depth).max + 1
    end
  end

  def value_at(position, byte)
    # tvb_get_guint
  end

  def step(byte)
    # offset +=
  end
end