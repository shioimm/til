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

  def filter(filter_name = nil)
    @filter = filter_name || @name.downcase
  end

  def fields(header_fields)
    @header_fields = header_fields
  end

  def dissector(&block)
    trunk = WSDissector.new(name: @name, depth: 1)
    block.call trunk
    @dissect_fields = trunk
  end

  def dissector_depth
    @dissect_fields.max_depth + 1
  end

  def register!
    # C側で実装
  end

  def dissect!
    # C側で実装
  end
end
