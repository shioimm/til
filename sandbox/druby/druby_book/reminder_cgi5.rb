#!~/.rbenv/shims/ruby
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

class ReminderCGI
  include ERB::Util

  def initialize(reminder, cgi)
    @reminder = reminder
    @cgi      = cgi
    @erb      = ERB.new(erb_src)
    @bg       = BGColor.new
  end

  def script_name
    @cgi.script_name
  end

  def make_param(hash)
    hash.collect { |k, v| "#{u(k)}=#{u(v)}" }.join(';')
  end

  def anchor(hash)
    %Q[<a href="#{script_name}?#{make_param(hash)}">]
  end
  alias :a :anchor

  def a_delete(key)
    anchor({ 'cmd' => 'delete', 'key' => key })
  end

  def erb_src
    <<EOS
<table border="0" cellspacing="0">
<% @reminder.to_a.each do |k, v| %>
<tr <%= @bg %>>
  <td><%= k %></td>
  <td><%=h v %></td>
  <td>[<%= a_delete(k) %>x</a>]</td>
</tr>
<% end %>
<form action="<%= script_name %>" method="post">
  <input type="hidden" name="cmd" value="add" />
  <tr <%= @bg %>>
    <td><input type="submit" value="add" /></td>
    <td><input type="text" name="item" value="" size="30" /></td>
    <td>&nbsp;</td>
  </tr>
</form>
</table>
EOS
  end

  def to_html
    @erb.result(binding)
  rescue DRb::DRbConnError
    %Q[<p>It seems that the Reminder server is downed.</p>]
  end

  def kconv(str)
    NKF.nkf('-edXm0', str.to_s)
  end

  def add
    item, _ = @cgi['item']
    return if item.nil? || item.empty?
    @reminder.add(kconv(item))
  end

  def delete
    key, _ = @cgi['key']
    return if key.nil? || key.empty?
    @reminder.delete(key.to_i)
  end

  def do_request
    cmd, _ = @cgi['cmd']

    case cmd
    when 'add'    then add
    when 'delete' then delete
    end
  end
end

class UnknownErrorPage
  include ERB::Util

  def initialize(error=$!, info=$@)
    @erb   = ERB.new(erb_src)
    @error = error
    @info  = info
  end

  def erb_src
    <<EOS
<p><%= h @error %> = <%= h @error.class %></p>
<ul>
<% info.each do |line| %>
<li><%= h line %></li>
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
  cgi = CGI.new('html5')
  reminder = ReminderCGI.new(there, cgi)
  reminder.do_request

  begin
    content = reminder.to_html
  rescue
    content = UnknownErrorPage.new($!, $@).to_html
  end

  cgi.out({ 'charset' => 'utf-8' }) {
    cgi.html {
      cgi.head {
        cgi.title { 'Reminder' }
      } + cgi.body { content }
    }
  }
end

main
