# 参照: dRubyによる分散・Webプログラミング

require 'cgi'
require 'erb'
require 'drb/drb'
require 'nkf'

class BGColor
  def initialize
    @colors = ['#eeeeff', 'bbbbff']
    @count = -1
  end
  attr_accessor :colors

  def next_bgcolor
    @count += 1
    @count = 0 if @colors.size <= @count
    "bgcolor='#{@colors[@count]}'"
  end
  alias :to_s :next_bgcolor
end

class ReminderPage
  include ERB::Util

  def initialize(reminder)
    @reminder = reminder
  end

  def script_name(cgi)
    cgi.script_name
  end

  def make_param(hash)
    hash.collect { |k, v| "#{u(k)}=#{u(v)}" }.join(';')
  end

  def anchor(cgi, hash)
    %Q[<a href="#{script_name(cgi)}?#{make_param(hash)}">]
  end
  alias :a :anchor

  def a_delete(cgi, key)
    anchor(cgi, { 'cmd' => 'delete', 'key' => key })
  end

  @erb_src = <<EOS
<% bg = BGColor.new %>
<table border="0" cellspacing="0">
<% @reminder.to_a.each do |k, v| %>
<tr <%= bg %>>
  <td><%= k %></td>
  <td><%=h v %></td>
  <td>[<%= a_delete(cgi, k) %>x</a>]</td>
</tr>
<% end %>
<form action="<%= script_name(cgi) %>" method="post">
  <input type="hidden" name="cmd" value="add" />
  <tr <%= bg %>>
    <td><input type="submit" value="add" /></td>
    <td><input type="text" name="item" value="" size="30" /></td>
    <td>&nbsp;</td>
  </tr>
</form>
</table>
EOS

  ERB.new(@erb_src).def_method(self, 'build_page(cgi)')

  def to_html(cgi)
    build_page(cgi)
  rescue DRb::DRbConnError
    %Q[<p>It seems that the Reminder server is downed.</p>]
  end

  def kconv(str)
    NKF.nkf('-edXm0', str.to_s)
  end

  def add(cgi)
    item, _ = cgi['item']
    return if item.nil? || item.empty?
    @reminder.add(kconv(item))
  end

  def delete(cgi)
    key, _ = cgi['key']
    return if key.nil? || key.empty?
    @reminder.delete(key.to_i)
  end

  def do_request(cgi)
    cmd, _ = cgi['cmd']

    case cmd
    when 'add'    then add
    when 'delete' then delete
    end
  end
end

if __FILE__ == $0
  there = DRbObject.new_with_uri('druby://localhost:12345')
  front = ReminderPage.new(there)
  DRb.start_service('druby://localhost:12346')
  puts DRb.uri
  DRb.thread.join
end
