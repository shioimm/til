WSProtocol.configure("dRuby") do
  transport :tcp
  port      8080
  filter    "druby"

  headers [
            { name:    :hf_druby_size,
              label:   "Size",
              filter:  "druby.size",
              type:    WSProtocol::FT_UINT32,
              display: WSProtocol::BASE_DEC,
              dict:    nil },
            { name:    :hf_druby_type,
              label:   "Type",
              filter:  "druby.type",
              type:    WSProtocol::FT_UINT8,
              display: WSProtocol::BASE_HEX,
              dict:    druby_types },
          ]

  druby_types = {
    '0' => "nil",
    'T' => "true",
    'F' => "false",
    'i' => "Integer",
    ':' => "Symbol",
    '"' => "String",
    'I' => "Instance variable",
    '[' => "Array",
    '{' => "Hash",
    'f' => "Double",
    'c' => "Class",
    'm' => "Module",
    'S' => "Struct",
    '/' => "Regexp",
    'o' => "Object",
    'C' => "UserClass",
    'e' => "Extended_object",
    ';' => "Symbol link",
    '@' => "Object link",
    'u' => "DRb::DRbObject",
    ',' => "DRb address",
  }

  dissectors do
    sub("Success") do
      items [
              { header: :hf_druby_size,
                size:   4,
                offset: 0,
                endian: WSDissector::ENC_BIG_ENDIAN },
              { header: :hf_druby_type,
                size:   1,
                offset: 6,
                endian: WSDissector::ENC_BIG_ENDIAN },
            ]
    end
  end
end
