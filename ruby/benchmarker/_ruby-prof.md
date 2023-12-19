# ruby-prof
- [ruby-prof](https://ruby-prof.github.io/)

```ruby
require 'ruby-prof'

result = RubyProf.profile do
  N.times do
    # 計測したいコードを書く
  end
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
````
