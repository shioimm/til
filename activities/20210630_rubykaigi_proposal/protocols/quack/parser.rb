module Quack
  class Parser
    def parse(message)
      message.chomp!
      { method: method(message), path: path(message) }
    end

    def method(message)
      case message.scan(/quack/).size
      when 2 then 'GET'
      else 'OTHER'
      end
    end

    def path(message)
      message[/in .+/].delete('in ')
    end
  end
end
