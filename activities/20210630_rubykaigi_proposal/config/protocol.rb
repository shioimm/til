module Config
  DEFINED_REQUEST_METHODS = {
    '.get' => 'GET',
    nil    => 'OTHER',
  }

  DEFINED_STATUS_CODES = {
    600 => 'Are you a Ruby programmer',
  }

  module Parseable
    def parse_request_method!(message)
      message[/\.get/]
    end

    def parse_request_path!(message)
      message[/['"].+['"]/].gsub(/['"]/, '')
    end
  end
end
