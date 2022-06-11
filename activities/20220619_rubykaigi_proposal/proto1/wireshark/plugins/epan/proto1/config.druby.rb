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
          ]

  dissectors do
    sub("Success") do
      items [
              { header: :hf_druby_size,
                size:   4,
                offset: 0,
                endian: WSDissector::ENC_BIG_ENDIAN },
            ]
    end
  end
end
