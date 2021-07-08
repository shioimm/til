Protoycol::Protocol.define(:rubylike) do
  define_status_codes(
    600 => 'Are you a Ruby programmer',
  )

  additional_request_methods 'OTHER'

  request.path do |message|
    /['"](?<path>.+)['"]/.match(message)[:path]
  end

  request.http_method do |message|
    case /\.(?<method>[A-z]+)/.match(message)&.captures&.first
    when 'get' then 'GET'
    else 'OTHER'
    end
  end
end
