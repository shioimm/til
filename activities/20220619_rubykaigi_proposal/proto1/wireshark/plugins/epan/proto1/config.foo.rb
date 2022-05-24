require_relative 'ws_protocol'

WSProtocol.configure("Foo") do |config|
  config.transport :tcp
  config.port      30000
  config.filter    "foo"

  config.field name:      :foo_pdu_type,
               label:     "FOO PDU Type",
               filter:    "FOO PDU Type",
               cap_type:  WSProtocol::FT_UINT8,
               disp_type: WSProtocol::BASE_DEC,
               desc:      nil

  config.tree do |t|
    t.node [
             { field:  :foo_pdu_type,
               size:   1,
               offset: 0,
               endian: WSTree::ENC_BIG_ENDIAN,
               format: { type: WSTree::FORMAT_ADD_ITEM } }
           ]

    t.subtree("Foo subtree") do |st|
      st.node [
                { field:  :foo_pdu_type,
                  size:   1,
                  offset: 0,
                  endian: WSTree::ENC_BIG_ENDIAN,
                  format: { type: WSTree::FORMAT_ADD_ITEM } }
              ]
    end
  end
end
