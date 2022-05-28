class WSTree
  ENC_BIG_ENDIAN  = nil # C側で実装
  FORMAT_ADD_ITEM = nil # C側で実装

  def initialize(name:, depth:)
    @name     = name
    @depth    = depth
    @nodes    = []
    @subtrees = []
  end

  def node(items)
    @nodes = items
  end

  def subtree(name, &block)
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
