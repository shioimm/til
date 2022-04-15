plugin = Plugin.new('FOO', :tcp, 30000)

plugin.dissect { |subtree|
  subtree.field label:      'FOO PDU Type',
                filter:     'foo.type',
                field_type: 'FT_UINT8',
                int_type:   'BASE_DEC',
                size:       1
  subtree.field label:      'FOO PDU Flags',
                filter:     'foo.flags',
                field_type: 'FT_UINT8',
                int_type:   'BASE_HEX',
                size:       1
  subtree.field label:      'FOO PDU Sequence Number',
                filter:     'foo.seqn',
                field_type: 'FT_UINT16',
                int_type:   'BASE_DEC',
                size:       2
  subtree.field label:      'FOO PDU Initial IP',
                filter:     'foo.initialip',
                field_type: 'FT_IPv4',
                int_type:   'BASE_NONE',
                size:       4
}
