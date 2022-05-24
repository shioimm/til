class WSTree
  ENC_BIG_ENDIAN  = nil # C側で実装
  FORMAT_ADD_ITEM = nil # C側で実装

  def initialize(name = nil)
    @name     = name
    @nodes    = []
    @subtrees = []
  end

  def node(items)
    @nodes = items
  end

  def subtree(name, &block)
    subtree = self.class.new(name)
    block.call subtree
    @subtrees << subtree
  end

  def value_at(position, byte)
    # tvb_get_guint
  end

  def step(byte)
    # offset +=
  end
end
