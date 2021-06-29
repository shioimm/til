Protocol.define(:rubylike) do
  define_status_codes(
    600 => 'Are you a Ruby programmer',
  )

  define_request_methods 'OTHER'

  request.path do |message|
    /['"](?<path>.+)['"]/.match(message)[:path]
  end

  request.http_method do |message|
    case /\.(?<method>[A-z]+)/.match(message)&.captures&.first
    when 'get' then 'GET'
    else 'OTHER'
    end
  end

  app.call do |env|
    case env['REQUEST_METHOD']
    when 'GET'
      [
        200,
        { 'Content-Type' => 'text/html' },
        ["Hello, This app is running on Ruby like protocol."]
      ]
    when 'OTHER'
      [
        600,
        { 'Content-Type' => 'text/html' },
        ["I'm afraid you are not a Ruby programmer..."]
      ]
    end
  end
end
