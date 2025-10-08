# httpx 現地調査 (202510時点)
https://gitlab.com/os85/httpx

```ruby
module HTTPX
  module Chainable
    %w[head get post put delete trace options connect patch].each do |meth|
      class_eval(<<-MOD, __FILE__, __LINE__ + 1)
        def #{meth}(*uri, **options)                # def get(*uri, **options)
          request("#{meth.upcase}", uri, **options) #   request("GET", uri, **options)
        end                                         # end
      MOD
    end

    def request(*args, **options)
      branch(default_options).request(*args, **options)
    end
    # ...
  end
  # ...
end
```
