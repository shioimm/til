def convert_form_to_int(n)
  n = n ^ 128 - 128

  if n == 0 then 0
  elsif n >= 4 then n - 5
  elsif n < -6 then n + 5
  elsif ( 1.. 3).include? n
    # WIP
  elsif (-5..-1).include? n
    # WIP
  end
end

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
            { name:    :hf_druby_string,
              label:   "Value",
              filter:  "druby.string",
              type:    WSProtocol::FT_STRING,
              display: WSProtocol::BASE_NONE,
              dict:    nil },
            { name:    :hf_druby_integer,
              label:   "Value",
              filter:  "druby.integer",
              type:    WSProtocol::FT_INT32,
              display: WSProtocol::BASE_DEC,
              dict:    nil },
          ]

  if packet(6, :gint8) == "54" || packet(6, :gint8) == "46" # Response
    dissectors do
      sub("Success") do
        items [
                { header: :hf_druby_size,
                  offset: 0,
                  endian: WSDissector::ENC_BIG_ENDIAN },
                { header: :hf_druby_type,
                  offset: 6,
                  endian: WSDissector::ENC_BIG_ENDIAN },
              ]
      end

      sub("Result") do
        result_type  = druby_types[packet(13, :gint8).hex.chr]
        result_items = [{ header: :hf_druby_size,
                          offset: 7,
                          endian: WSDissector::ENC_BIG_ENDIAN }]

        if result_type == "Instance variable"
          result_value_size = packet(7, :gint32, WSDissector::ENC_BIG_ENDIAN)
          result_items.push({ header: :hf_druby_type,
                              offset: 14,
                              endian: WSDissector::ENC_BIG_ENDIAN })
          result_items.push({ header: :hf_druby_string,
                              size:   result_value_size.hex - 10,
                              offset: 16,
                              endian: WSDissector::ENC_NA })
        elsif result_type == "Integer"
          result_items.push({ header: :hf_druby_type,
                              offset: 13,
                              endian: WSDissector::ENC_BIG_ENDIAN })

          result_int_value = packet(14, :gint8)
          result_items.push({ header: :hf_druby_integer,
                              size: result_value_size ? result_value_size.hex - 3 : 0,
                              offset: 14,
                              display: :formatted_int,
                              format: "%d",
                              value:  result_int_value ? convert_form_to_int(result_int_value.to_i) : 0 })
        end

        items result_items
      end
    end
  else # Request
    dissectors do
      offset = 0

      sub("Ref") do
        items [
                { header: :hf_druby_size,
                  offset: offset,
                  endian: WSDissector::ENC_BIG_ENDIAN },
                { header: :hf_druby_string,
                  size:   1,
                  offset: offset += 6,
                  endian: WSDissector::ENC_NA },
              ]

        offset += 1
      end

      sub("Message") do
        message_value_size     = packet(offset, :gint32, WSDissector::ENC_BIG_ENDIAN)
        message_value_size_int = message_value_size ? message_value_size.hex - 10 : 0

        items [
                { header: :hf_druby_size,
                  offset: offset,
                  endian: WSDissector::ENC_BIG_ENDIAN },
                { header: :hf_druby_type,
                  offset: offset += 7,
                  endian: WSDissector::ENC_BIG_ENDIAN },
                { header: :hf_druby_string,
                  size:   message_value_size_int,
                  offset: offset += 2,
                  endian: WSDissector::ENC_NA },
              ]

        offset += message_value_size_int
        offset += 5
      end

      args_size_value_offset = offset + 7
      args_size_value        = packet(args_size_value_offset, :gint8)

      sub("Args size") do
        args_size_value_size     = packet(offset, :gint32, WSDissector::ENC_BIG_ENDIAN)
        args_size_value_size_int = args_size_value_size ? args_size_value_size.hex - 3 : 0

        items [
                { header:  :hf_druby_size,
                  offset:  offset,
                  endian:  WSDissector::ENC_BIG_ENDIAN },
                { header:  :hf_druby_integer,
                  size:    args_size_value_size_int,
                  offset:  args_size_value_offset,
                  display: :formatted_int,
                  format: "%d",
                  value:   args_size_value ? convert_form_to_int(args_size_value.to_i) : 0 },
              ]

        offset = args_size_value_offset
        offset += 1
      end

      if args_size_value
        args_value_size = packet(offset, :gint32, WSDissector::ENC_BIG_ENDIAN)

        sub("Args") do
          convert_form_to_int(args_size_value.to_i).times do |n|
            sub("Arg (#{n + 1})") do
              items [
                { header: :hf_druby_size,
                  offset: offset,
                  endian: WSDissector::ENC_BIG_ENDIAN },
                { header: :hf_druby_string,
                  size:   args_value_size ? args_value_size.hex - 10 : 0,
                  offset: offset += 9,
                  endian: WSDissector::ENC_NA },
              ]
            end
          end
        end
      end

      sub("Block") do
        items [
                { header: :hf_druby_size,
                  offset: offset += 10,
                  endian: WSDissector::ENC_BIG_ENDIAN },
                { header: :hf_druby_type,
                  offset: offset += 6,
                  endian: WSDissector::ENC_BIG_ENDIAN },
              ]
      end
    end
  end
end
