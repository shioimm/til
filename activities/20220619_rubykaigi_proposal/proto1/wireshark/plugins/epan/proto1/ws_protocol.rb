class WSProtocol
  FT_UINT8 = nil # C側で実装
  BASE_DEC = nil # C側で実装

  def self.configure(name, &block)
    wsp = self.new(name)
    block.call wsp
    wsp.dissect!
  end

  def initialize(name)
    @name               = name
    @transport_protocol = nil
    @port_number        = nil
    @filter_name        = nil
    @fields             = []
  end

  def transport(transport_protocol)
    @transport_protocol = transport_protocol
  end

  def port(port_number)
    @port_number = port_number
  end

  def filter(filter_name)
    @filter_name = filter_name
  end

  def field(header_field)
    @fields << header_field
  end

  def tree(&block)
    block.call WSTree.new
  end

  def dissect!
    # C側で実装
  end
end
