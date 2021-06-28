Protocol.define(:duck) do
  define_status_codes(
    600 => 'You are an ugly duckling',
  )

  request.path do |message|
    /in (?<path>.+)/.match(message)[:path]
  end

  request.http_method do |message|
    case message.scan(/quack/).size
    when 2 then 'GET'
    else 'CRY'
    end
  end

  app.call do |env|
    case env['REQUEST_METHOD']
    when 'GET'
      case env['PATH_INFO']
      when '/posts'
        [
          200,
          { 'Content-Type' => 'text/html' },
          ["quack quack, quack quack, quack, quack"]
        ]
      when '/'
        [
          200,
          { 'Content-Type' => 'text/html' },
          ["Hello, This app is running on Ruby like protocol."]
        ]
      end
    when 'CRY'
      [
        600,
        { 'Content-Type' => 'text/html' },
        ["You are an ugly duckling"]
      ]
    end
  end
end
