class WSProtocol
  FT_UINT8 = nil # Implemented in ws_protocol.c
  BASE_DEC = nil # Implemented in ws_protocol.c

  def self.configure
    # Implemented in ws_protocol.c
  end

  def initialize
    # Implemented in ws_protocol.c
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

  def headers(header_fields)
    @headers = header_fields
  end

  def dissectors(&block)
    trunk = WSDissector.new(name: @name, depth: 1, protocol: self)
    trunk.instance_eval(&block)
    @dissectors = trunk
  end

  def dissector_depth
    @dissectors.max_depth + 1
  end

  def register!
    # Implemented in ws_protocol.c
  end

  def dissect!
    # Implemented in ws_protocol.c
  end

  def packet(offset, type)
    # Implemented in ws_protocol.c
  end
end
