module Ruby
  class Parser
    def parse(message)
      message.chomp!
      { method: method(message), path: path(message) }
    end

    def method(message)
      case message[/\.get/]
      when '.get' then 'GET'
      else 'OTHER'
      end
    end

    def path(message)
      message[/['"].+['"]/].gsub(/['"]/, '')
    end
  end
end
