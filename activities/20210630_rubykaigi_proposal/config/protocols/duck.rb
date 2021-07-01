Protocol.define(:duck) do
  define_status_codes(
    600 => 'You are an ugly duckling',
  )

  request.path do |message|
    /(?<path>\/\w*)/.match(message)[:path]
  end

  request.query do |message|
    if query = /\?.+/.match(message)
      query
    end
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
        if URI.decode_www_form_component(env['QUERY_STRING']) == "user_id=1"
          return [
            200,
            { 'Content-Type' => 'text/html' },
            ["quack quack, I am the No.1 duck"]
          ]
        end
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
