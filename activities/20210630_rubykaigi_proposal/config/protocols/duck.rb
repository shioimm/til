module Config
  DEFINED_REQUEST_METHODS = {
    'CRY' => 'CRY',
  }

  DEFINED_STATUS_CODES = {
    600 => 'You are an ugly duckling',
  }

  module Parseable
    def parse_request_method!(message)
      case message.scan(/quack/).size
      when 2 then 'GET'
      else 'CRY'
      end
    end

    def parse_request_path!(message)
      message[/in .+/].delete('in ')
    end
  end
end
