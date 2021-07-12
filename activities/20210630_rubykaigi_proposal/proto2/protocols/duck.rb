Toycol::Protocol.define(:duck) do
  define_status_codes(
    600 => 'You are an ugly duckling',
  )
  additional_request_methods 'CRY'

  request.path do |message|
    /(?<path>\/\w*)/.match(message)[:path]
  end

  request.query do |message|
    /\?(?<query>.+)/.match(message) { |m| m[:query] }
  end

  request.http_method do |message|
    case message.scan(/quack/).size
    when 2 then 'GET'
    else 'CRY'
    end
  end
end
