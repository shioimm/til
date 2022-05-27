# require_relative 'ws_tree'

class WSProtocol
  FT_UINT8 = nil # C側で実装
  BASE_DEC = nil # C側で実装

  def self.configure
    # C側で実装
  end

  def initialize
    # C側で実装
  end

  def transport(transport_protocol)
    @transport = transport_protocol
  end

  def port(port_number)
    @port = port_number
  end

  def filter(filter_name)
    @filter = filter_name
  end

  def fields(header_fields)
    @header_fields = header_fields
  end

  def tree(&block)
    tree = WSTree.new
    block.call tree
    @dissect_fields = tree
  end

  def register!
    # C側で実装
  end

  def dissect!
    # C側で実装
  end
end
