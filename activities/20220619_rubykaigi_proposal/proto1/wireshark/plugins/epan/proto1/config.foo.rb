require_relative 'ws_protocol'

WSProtocol.configure("ProtoFoo") do |config|
  config.transport :tcp
  config.port      4567
  config.filter    "proto_foo"

  config.fields [
                  { name:      :foo_pdu_type,
                    label:     "FOO PDU Type",
                    filter:    "foo.type",
                    cap_type:  WSProtocol::FT_UINT8,
                    disp_type: WSProtocol::BASE_DEC,
                    desc:      nil }
                ]

  config.dissector do |d|
    d.items [
              { field:  :foo_pdu_type,
                size:   1,
                offset: 0,
                endian: WSDissector::ENC_BIG_ENDIAN,
                format: { type: WSDissector::FORMAT_ADD_ITEM } }
             ]

    d.sub("Foo subtree") do |ds|
      ds.items [
                 { field:  :foo_pdu_type,
                   size:   1,
                   offset: 0,
                   endian: WSDissector::ENC_BIG_ENDIAN,
                   format: { type: WSDissector::FORMAT_ADD_ITEM } }
               ]
    end
  end
end
