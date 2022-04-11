plugin = Plugin.new('FOO', :tcp, 30000)

plugin.dissect { |subtree|
  subtree.field label:      'FOO PDU Type',
                filter:     'foo.type',
                field_type: 'FT_UINT8',
                int_type:   'BASE_DEC'
  subtree.field label:      'FOO PDU Flags',
                filter:     'foo.flags',
                field_type: 'FT_UINT8',
                int_type:   'BASE_HEX'
  subtree.field label:      'FOO PDU Sequence Number',
                filter:     'foo.seqn',
                field_type: 'FT_UINT16',
                int_type:   'BASE_DEC'
  subtree.field label:      'FOO PDU Initial IP',
                filter:     'foo.initialip',
                field_type: 'FT_IPv4',
                int_type:   'BASE_NONE'
}
