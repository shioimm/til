Protocol.define(:rubylike) do
  define_status_codes(
    600 => 'Are you a Ruby programmer',
  )

  request.path do |message|
    message[/['"].+['"]/].gsub(/['"]/, '')
  end

  request.http_method do |message|
    case message[/\.get/]
    when '.get' then 'GET'
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
