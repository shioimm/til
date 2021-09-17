# 参照: dRubyによる分散・Webプログラミング
require 'erb'
require 'drb/drb'

class ReminderWriter
  include ERB::Util

  def initialize(reminder)
    @reminder = reminder
    @erb = ERB.new(erb_src)
  end

  def erb_src
    <<EOS
<ul>
<% @reminder.to_a.each do |k, v| %>
<li><%= k %>: <%=h v %></li>
<% end %>
</ul>
EOS
  end

  def to_html
    @erb.result(binding)
  end
end

def main
  DRb.start_service
  there = DRbObject.new_with_uri('druby://localhost:12345')

  writer = ReminderWriter.new(there)
  puts writer.to_html
end

main
