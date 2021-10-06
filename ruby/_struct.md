# Struct
```ruby
# ref: https://github.com/ruby/ruby/blob/d53493715cd1a1463b98291e0ad92e2723236698/ext/ripper/lib/ripper/lexer.rb

Klass = Struct.new(:arg1, :arg2) do
  def initialize(arg1)
    super(arg1, 'arg2')
  end
end

Klass.new(:arg1)
# => #<struct Klass arg1=:arg1, arg2="arg2">

Klass.new
# => ArgumentError (wrong number of arguments (given 0, expected 1))

Klass.new(:arg1, :arg2)
# => ArgumentError (wrong number of arguments (given 2, expected 1))
```
