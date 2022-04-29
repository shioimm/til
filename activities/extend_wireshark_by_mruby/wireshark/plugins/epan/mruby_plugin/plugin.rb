plugin = Plugin.new('FOO', :tcp, 30000)

plugin.dissect { |subtree|
  subtree.field label:      'FOO PDU Type',
                filter:     'foo.type',
                field_type: 'FT_UINT8',
                int_type:   'BASE_DEC',
                size:       1,
                desc:       { initialise: 1, terminate: 2, data: 3 },
                col_info:   'Type: '
  subtree.field label:      'FOO PDU Flags',
                filter:     'foo.flags',
                field_type: 'FT_UINT8',
                int_type:   'BASE_HEX',
                size:       1,
                bitmask:    [
                              {
                                label:      'FOO PDU Start Flags',
                                filter:     'foo.flags.start',
                                field_type: 'FT_BOOLEAN',
                                int_type:   'BASE_HEX',
                                bitmask:    0x01,
                              },
                              {
                                label:      'FOO PDU End Flags',
                                filter:     'foo.flags.end',
                                field_type: 'FT_BOOLEAN',
                                int_type:   'BASE_HEX',
                                bitmask:    0x02,
                              },
                              {
                                label:      'FOO PDU Priority Flags',
                                filter:     'foo.flags.priority',
                                field_type: 'FT_BOOLEAN',
                                int_type:   'BASE_HEX',
                                bitmask:    0x04,
                              },
                            ]
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
