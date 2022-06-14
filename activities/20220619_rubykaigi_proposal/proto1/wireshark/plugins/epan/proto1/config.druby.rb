WSProtocol.configure("dRuby") do
  transport :tcp
  port      8080
  filter    "druby"

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

  protocol =  self

  if packet(6, :gint8) == "54" || packet(6, :gint8) == "46" # Response
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

      sub("Result") do
        items [
                { header: :hf_druby_size,
                  size:   4,
                  offset: 7,
                  endian: WSDissector::ENC_BIG_ENDIAN },
                { header: :hf_druby_type,
                  size:   1,
                  offset: 14,
                  endian: WSDissector::ENC_BIG_ENDIAN },
                { header: :hf_druby_string,
                  size:   protocol.packet(7, :gint32, WSDissector::ENC_BIG_ENDIAN).hex - 10,
                  offset: 16,
                  endian: WSDissector::ENC_NA },
                # WIP
              ]
      end
    end
  else # Request
    dissectors do
      sub("Success") do
        items [
                { header: :hf_druby_size,
                  size:   4,
                  offset: 0,
                  endian: WSDissector::ENC_BIG_ENDIAN },
                # WIP
              ]
      end
    end
  end
end
