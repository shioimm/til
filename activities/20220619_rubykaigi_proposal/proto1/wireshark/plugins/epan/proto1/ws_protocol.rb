# require_relative 'ws_tree'

class WSProtocol
  FT_UINT8 = nil # C側で実装
  BASE_DEC = nil # C側で実装

  def self.configure(name, &block)
    wsp = self.new(name)
    block.call wsp
    wsp.dissect!
  end

  def initialize(name)
    @name           = name
    @transport      = nil
    @port           = nil
    @filter         = nil
    @header_fields  = []
    @dissect_fields = nil
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

  def dissect!
    # C側で実装
  end
end
