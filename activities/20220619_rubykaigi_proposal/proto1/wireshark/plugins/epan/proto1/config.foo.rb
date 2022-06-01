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
                    desc:      true }, # WIP: 実装中
                  { name:      :foo_pdu_flag,
                    label:     "FOO PDU Flags",
                    filter:    "foo.flags",
                    cap_type:  WSProtocol::FT_UINT8,
                    disp_type: WSProtocol::BASE_HEX,
                    desc:      nil },
                  { name:      :foo_pdu_seqn,
                    label:     "FOO PDU Sequence Number",
                    filter:    "foo.seqn",
                    cap_type:  WSProtocol::FT_UINT16,
                    disp_type: WSProtocol::BASE_DEC,
                    desc:      nil },
                  { name:      :foo_pdu_initialip,
                    label:     "FOO PDU Initial IP",
                    filter:    "foo.initialip",
                    cap_type:  WSProtocol::FT_IPv4,
                    disp_type: WSProtocol::BASE_NONE,
                    desc:      nil },
                ]

  config.dissector do |d|
    d.items [
              { field:  :foo_pdu_type,
                size:   1,
                offset: 0,
                endian: WSDissector::ENC_BIG_ENDIAN,
                format: { type: WSDissector::FORMAT_ADD_ITEM } },
              { field:  :foo_pdu_flag,
                size:   1,
                offset: 1,
                endian: WSDissector::ENC_BIG_ENDIAN,
                format: { type: WSDissector::FORMAT_ADD_ITEM } },
              { field:  :foo_pdu_seqn,
                size:   2,
                offset: 2,
                endian: WSDissector::ENC_BIG_ENDIAN,
                format: { type: WSDissector::FORMAT_ADD_ITEM } },
              { field:  :foo_pdu_initialip,
                size:   4,
                offset: 4,
                endian: WSDissector::ENC_BIG_ENDIAN,
                format: { type: WSDissector::FORMAT_ADD_ITEM } },
            ]

    d.sub("Foo subtree upper") do |ds|
      ds.items [
                 { field:  :foo_pdu_type,
                   size:   1,
                   offset: 0,
                   endian: WSDissector::ENC_BIG_ENDIAN,
                   format: { type: WSDissector::FORMAT_ADD_ITEM } },
                 { field:  :foo_pdu_flag,
                   size:   1,
                   offset: 1,
                   endian: WSDissector::ENC_BIG_ENDIAN,
                   format: { type: WSDissector::FORMAT_ADD_ITEM } },
                 { field:  :foo_pdu_seqn,
                   size:   2,
                   offset: 2,
                   endian: WSDissector::ENC_BIG_ENDIAN,
                   format: { type: WSDissector::FORMAT_ADD_ITEM } },
                 { field:  :foo_pdu_initialip,
                   size:   4,
                   offset: 4,
                   endian: WSDissector::ENC_BIG_ENDIAN,
                   format: { type: WSDissector::FORMAT_ADD_ITEM } },
               ]

      ds.sub("Foo subtree inner") do |ids|
        ids.items [
                    { field:  :foo_pdu_type,
                      size:   1,
                      offset: 0,
                      endian: WSDissector::ENC_BIG_ENDIAN,
                      format: { type: WSDissector::FORMAT_ADD_ITEM } },
                    { field:  :foo_pdu_flag,
                      size:   1,
                      offset: 1,
                      endian: WSDissector::ENC_BIG_ENDIAN,
                      format: { type: WSDissector::FORMAT_ADD_ITEM } },
                    { field:  :foo_pdu_seqn,
                      size:   2,
                      offset: 2,
                      endian: WSDissector::ENC_BIG_ENDIAN,
                      format: { type: WSDissector::FORMAT_ADD_ITEM } },
                    { field:  :foo_pdu_initialip,
                      size:   4,
                      offset: 4,
                      endian: WSDissector::ENC_BIG_ENDIAN,
                      format: { type: WSDissector::FORMAT_ADD_ITEM } },
                 ]
      end
    end

    d.sub("Foo subtree lower") do |ds|
      ds.items [
                 { field:  :foo_pdu_type,
                   size:   1,
                   offset: 0,
                   endian: WSDissector::ENC_BIG_ENDIAN },
                 { field:  :foo_pdu_flag,
                   size:   1,
                   offset: 1,
                   endian: WSDissector::ENC_BIG_ENDIAN },
                 { field:  :foo_pdu_seqn,
                   size:   2,
                   offset: 2,
                   endian: WSDissector::ENC_BIG_ENDIAN },
                 { field:  :foo_pdu_initialip,
                   size:   4,
                   offset: 4,
                   endian: WSDissector::ENC_BIG_ENDIAN },
               ]
    end
  end
end
